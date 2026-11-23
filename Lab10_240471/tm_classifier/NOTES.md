# Lab 10 — Teach It, Ship It: lab notes

## Part 1 — Train and export the model

### Class list

Six classes, trained in Teachable Machine (Image Project, Standard image
model). The names below are the exact strings in `assets/model/labels.txt`,
and therefore the exact strings the app displays.

| Index | Label | Notes |
| --- | --- | --- |
| 0 | Phone | |
| 1 | Notebook | |
| 2 | Zayniddin | |
| 3 | Magic mouse | |
| 4 | Wallet | |
| 5 | Arm | |

Export: Floating point, `model_unquant.tflite` (2,091,932 bytes) plus
`labels.txt`, both in `assets/model/`. The model's input tensor is
`[1, 224, 224, 3]` and its output tensor is `[1, 6]`, one probability per
class.

### Q: What does the model answer when it sees an object that belongs to none of your classes? How does the background class change that?

It answers with one of the six classes anyway. The network ends in a softmax
over exactly six outputs, so the six numbers always sum to 1 and there is no
seventh "unknown" output for the model to pick. An object it has never seen is
pushed onto whichever trained class it resembles most in feature space, and the
confidence can still be high — a softmax reports how much more one class fits
than the other five, not whether any of them fit at all. A shoe can be reported
as a mug at 97 % and nothing about that is a malfunction.

A background class changes this by giving "none of these" a real output to land
on. Once empty-desk frames are a trained class, a view with no object in it has
a correct answer available instead of being forced onto a real object, and the
app can treat a high background score as "show me something". The limit is that
the class only covers what its samples look like: it absorbs empty and
near-empty views, not every unknown object. A novel object that is clearly an
object still gets misassigned to one of the five real classes.


### Q: The export dialog offers Floating point and Quantized. What differs between the two files in size, in input type and in what your Dart code would have to do?

**Size.** The floating-point file stores every weight as a float32, four bytes
each; ours is 2,091,932 bytes, about 2.0 MB. The quantized file stores weights
as uint8, one byte each, so it is roughly four times smaller — about 0.5 MB —
at the cost of some precision in the weights.

**Input type.** The floating-point model's input tensor is float32 with values
in the range −1 to 1, which is what Teachable Machine trained on. The quantized
model's input tensor is uint8, taking the raw pixel range 0 to 255 with no
normalisation at all. The output differs the same way: float32 probabilities
that sum to 1 in the first case, uint8 values from 0 to 255 in the second.

**What the Dart code would have to do.** For the floating-point model we build
a nested `List<double>` and map each channel with `value / 127.5 - 1`, then read
`output.first[i]` directly as a probability. For the quantized model that
normalisation has to be deleted, not adjusted — the pixel bytes go in
untouched. The input buffer becomes integer-typed rather than
`List<List<List<double>>>` of doubles, the output buffer becomes
`List<int>`/`Uint8List` sized to the class count, and every output value has to
be divided by 255 before it is treated as a confidence. Keeping the
normalisation in by accident would feed values near −1 to a tensor that expects
0 to 255, and the model would answer confidently and wrongly without throwing.

## Part 2 — New project, assets and dependencies

Project: `tm_classifier`, created with `flutter create tm_classifier --empty`.
`assets/model/` sits at the project root, next to `lib`, and holds
`model_unquant.tflite` and `labels.txt`.

Declared in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/model/
```

Dependencies resolved by `flutter pub add tflite_flutter image_picker image http`,
all four under `dependencies:`: `tflite_flutter ^0.12.1` (the TensorFlow Lite
interpreter), `image_picker ^1.2.4` (camera and gallery), `image ^4.13.1`
(decode, crop and resize in pure Dart) and `http ^1.6.0` (download an image from
a URL).

Platform configuration: `NSCameraUsageDescription` and
`NSPhotoLibraryUsageDescription` added to `ios/Runner/Info.plist`, and
`<uses-permission android:name="android.permission.INTERNET"/>` added to
`android/app/src/main/AndroidManifest.xml` as a direct child of `<manifest>`.
`minSdk` is left at `flutter.minSdkVersion`; it is only worth pinning if Gradle
names a number in an error.

### Q: What is the difference between listing `assets/model/` and listing `assets/`? Which files would each one bundle?

The trailing slash makes the entry a directory entry, and a directory entry in
`pubspec.yaml` is not recursive — it bundles the files sitting directly in that
one folder and nothing from any subfolder. So `assets/model/` bundles exactly
`assets/model/model_unquant.tflite` and `assets/model/labels.txt`, our two
files, and would pick up anything else later dropped beside them.

`assets/` names the parent folder instead. Because the entry is not recursive it
bundles only the files lying loose directly in `assets/` — today that is none,
since everything is one level down in `assets/model/`. The model and the labels
would **not** be bundled, and `Interpreter.fromAsset` would fail at start-up
with an "Unable to load asset" error even though the files are plainly there on
disk. To cover a tree you have to list each folder, or list the individual
files.

The practical reason to keep `assets/model/` rather than widening it later is
scope: a narrow entry bundles the model and the labels and nothing else. Once
Part 3 puts `sample.jpg` in that same folder it ships too, which is what we
want for the smoke test but is worth knowing — a directory entry silently
bundles whatever lands in the directory, and app size follows.

### Q: Why can `image` and `http` run in a plain Dart unit test while `tflite_flutter` and `image_picker` cannot?

`image` and `http` are pure Dart. All of `image`'s decoding, cropping and
resizing is Dart code doing arithmetic on byte buffers, and `http` on the VM
talks to `dart:io` sockets. Neither needs an engine, so both load and run inside
`flutter test`, or even plain `dart test`, with nothing stubbed.

`tflite_flutter` and `image_picker` are plugins: the Dart class is a thin
façade over native code. `image_picker` sends messages across a
`MethodChannel` to a platform implementation that opens the system camera or
photo-picker UI — there is no camera and no channel handler in a unit test, so
the call hangs or throws `MissingPluginException`. `tflite_flutter` is different
in kind but blocked for the same reason: it reaches the TensorFlow Lite C
library through `dart:ffi`, and `Interpreter.fromAsset` also reads through
`rootBundle`, which is the Flutter engine's asset bundle. No engine means no
asset bundle and no loaded native library.

That is the argument for the shape of `classifier.dart`. `parseLabels` is a
pure, top-level function over a `String`, so it is unit-testable with no engine,
no device and no model file — which is exactly what `test/labels_test.dart`
exercises in T13. Everything untestable is pushed behind `Classifier.load()`
and `classify`, and verified on a device instead.

## Part 3 — The classifier: bytes in, percentages out

`lib/services/classifier.dart` is the only file that knows TensorFlow Lite
exists. Screens hand it a `Uint8List` and get back a `List<Prediction>` sorted
from highest confidence to lowest; they never see a tensor.

Three decisions worth recording:

- **Normalisation is `value / 127.5 - 1`.** The exported floating-point model's
  input tensor is `[1, 224, 224, 3]` float32 in the range −1 to 1, which is what
  Teachable Machine trained on. A pixel channel is 0 to 255, so that expression
  is the mapping between them.
- **`bakeOrientation` before `copyResizeCropSquare`.** Phone cameras store the
  rotation in EXIF rather than rotating the pixels. Baking it in first means a
  portrait photo is not classified sideways; cropping to a centred 224×224
  square then repeats what Teachable Machine did during training.
- **Pair, then sort.** Index `i` of the output tensor belongs to line `i` of
  `labels.txt`, so `Prediction` objects are built first and the list is sorted
  afterwards. Sorting the raw numbers first would keep the order of the labels
  and scramble which number belongs to which.

`classify` also records `lastInference` with a `Stopwatch`, because inference
runs on the UI thread and that duration is what the user actually waits
through. The number is used again in Part 5.

### T11 — how the single instance is shared

Constructor injection, not a provider. `_TmClassifierAppState` in
`lib/main.dart` calls `Classifier.load()` once in `initState`, holds the
resulting instance in a field so `dispose` can call `close()`, and passes it
down as a required constructor argument. A `FutureBuilder` gates the whole app:
while the future is pending the loading screen shows, on failure
`_StartupErrorScreen` shows, and only on success does a screen that needs the
classifier get built.

The reason for choosing injection over a Riverpod provider here is that the
dependency is one object, created once, needed by a known set of screens, and
owned for the whole life of the app. A provider would add a container and a
lifecycle to reason about — and Lab 9 showed that `autoDispose` lifetimes are
exactly where provider mistakes hide — without removing any wiring, because the
screens would still have to read it. The cost of injection is that a new screen
deep in the tree has to be threaded the argument; if Part 4 pushes the tree
deeper than three levels, this is the decision to revisit.

### T12 — failing politely

Every failure path ends in a sentence the user can read plus a technical
detail line, carried by `ClassifierException`:

- A file that is not an image: `img.decodeImage` returns null, so `classify`
  throws "That file is not an image we can read." The smoke-test page has a
  **Classify a text file** button that feeds it `labels.txt` on purpose, and the
  result is an error card, not a red screen and not a stuck spinner.
- A missing or mistyped model path: `Classifier.load` catches the failure and
  throws "The model file could not be loaded." with the detail naming the
  expected path and the pubspec key, which `_StartupErrorScreen` shows instead
  of the app. The paths live in `Classifier.modelAsset` and
  `Classifier.labelsAsset`, so there is one place to typo and one place to fix.
- A missing asset in general: `classifyAsset` reports which asset was expected
  and that `assets/model/` is already declared, so the fix is to add the file
  and rebuild.

### T13 — what the tests found

`test/labels_test.dart` has two tests and both pass, so **no fix to
`parseLabels` was needed**. The awkward case —
`'0 Mug\r\n1 Bottle\r\n2 Car keys\r\n\r\n'` — already works because of three
things in the existing implementation: `line.trim()` removes the stray `\r`
left by splitting CRLF on `\n` alone, the `if (line.trim().isNotEmpty)` guard
drops the trailing blank line, and the regex `^\d+\s+` is anchored and applied
with `replaceFirst`, so it removes only the leading index and leaves the space
inside `Car keys` untouched.

This matters for our own data: `labels.txt` line 3 is `3 Magic mouse`, so a
label with a space is not a hypothetical edge case here.

### Q: Change the normalisation to `value / 255` and classify the sample again. What happens to the percentages, and why does nothing crash?

The percentages change and get worse, usually by collapsing most of the mass
onto one or two classes that have little to do with the picture, and the top
label is no longer reliably the right one.

Nothing crashes because nothing the interpreter checks has changed. The input
is still a float32 tensor of shape `[1, 224, 224, 3]`, which is the only thing
`run` validates; `value / 255` just puts the numbers in 0..1 instead of −1..1.
Every convolution still multiplies and adds, the final softmax still exponentiates
and divides, and a softmax always returns a valid probability distribution — six
numbers, none negative, summing to 1. So the app receives perfectly well-formed
output that happens to be wrong. The failure is statistical, not structural: the
features the network learned were measured on −1..1 inputs, and feeding it a
different range shifts every activation in the first layer, which propagates. A
wrong range is therefore the worst kind of bug in this app, because the only
symptom is confident nonsense.

### Q: Where in the whole app is the number of classes written down? What would you have to edit after retraining with a seventh class?

Nowhere in the Dart code. The count exists in exactly two artefacts, and both
are read at runtime:

1. `assets/model/labels.txt` — one line per class. `parseLabels` turns it into
   `Classifier.labels`, and `labels.length` sizes the output buffer
   (`[List<double>.filled(labels.length, 0)]`) and bounds the loop that pairs
   outputs to labels.
2. `assets/model/model_unquant.tflite` — its output tensor shape, `[1, 6]` for
   our current export, is baked into the graph.

So after retraining with a seventh class the edit is: replace both files in
`assets/model/` and rebuild. No Dart change, no constant to bump. Anything that
displays the class list, including the Model screen in Part 4, picks the new
label up for free.

The thing to be careful about is that those two files must come from the *same*
export. They are the one place the count is written down twice, and if
`labels.txt` says seven while the model still outputs six, the output buffer is
sized seven, `run` rejects the shape mismatch, and `classify` reports "The model
could not read that image." That is also the argument for loading the labels
from the same folder as the model, so the pair cannot drift apart.
