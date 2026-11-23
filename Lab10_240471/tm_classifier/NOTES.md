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

## Part 4 — Five screens, one design

### T14 — design credit

| | |
| --- | --- |
| Name | Material 3 Design Kit |
| Author | Material Design (Google) |
| Link | https://www.figma.com/community/file/1035203688168086460 |
| Licence | CC BY 4.0 (Figma Community) |

The same values live in `lib/theme/design_credit.dart` and are shown on the
Model screen. Values read from the kit's variables: primary `#6750A4`,
surface `#FEF7FF`, surface container `#F3EDF7` (cards, navigation bar),
surface container high `#ECE6F0`, secondary container `#E8DEF8` (chips, nav
indicator), on surface `#1D1B20`, on surface variant `#49454F`, outline variant
`#CAC4D0`; type in the M3 scale — title large 22/28 regular, title small and
label large 14/20 medium, label medium 12/16 medium, body small 12/16 — and
the kit's 12 px card corners, fully rounded buttons and pill nav indicator.

Reference frames, exported from the kit's *Examples* page:
`docs/design-1.png` is **Examples/Gallery-Mobile** (large title, tonal image
cards, navigation bar) and `docs/design-2.png` is **Examples/Library-Mobile**
(top app bar with back arrow, filter chips, thumbnail grid with title and
subtitle). Home, History and Model follow the Gallery frame; Result follows the
Library frame's top app bar and the title/subtitle pattern under thumbnails.

### T15 — one theme file

`lib/theme/app_theme.dart` holds the whole design: the palette (private to that
file), a `ColorScheme`, a `TextTheme` with every text size, and component
themes for app bar, cards, filled/outlined/text buttons, chips, the navigation
bar, progress indicators, list tiles, inputs and snack bars. Spacing (4-point
scale) and corner radii are `AppSpace` and `AppRadius` constants in the same
file. Screens and widgets read colours and text styles only through
`Theme.of(context)`: there is no `Color(0xFF…)` and no `fontSize` in
`lib/screens/` or `lib/widgets/`.

### T16 / T17 — screens and navigation

| # | Screen | File | Notes |
| --- | --- | --- | --- |
| 1 | Welcome | `screens/welcome_screen.dart` | App name, one sentence, the labels as chips, **Get started**. It is also the loading screen (progress bar, button disabled) and the start-up error screen (names the missing file and where it was expected). |
| 2 | Home | `screens/home_screen.dart` | Three separate action cards — Take a photo, Choose from gallery, Download an image — plus *Try the sample image* and the most recent result. |
| 3 | Result | `screens/result_screen.dart` | Image centred with `BoxFit.contain`, at most half the screen high; one row per label with a bar and the percentage; top row emphasised; scrolls; the source is shown as a chip in the app bar. |
| 4 | History | `screens/history_screen.dart` | Newest first: thumbnail, top label, percentage, source icon and time. Designed empty state. Tapping reopens the Result screen from the stored predictions, without running the model. |
| 5 | Model | `screens/model_screen.dart` | Labels, number of classes, input size, file names, tensor shapes, the design credit, and a button to the Part 3 smoke test. |

Navigation: *Get started* replaces Welcome with `HomeShell`
(`screens/home_shell.dart`), which has a bottom `NavigationBar` for Home,
History and Model inside an `IndexedStack`, so each tab keeps its scroll
position. Result is pushed, so the back button returns to where you came from.

`HomeShell` also owns the single classification path —
bytes → `classify` → `SessionHistory.add` → push Result — so Part 5 only adds
the three byte sources. Until then the camera, gallery and download cards show
a "not connected yet" message and *Try the sample image* classifies
`assets/model/sample.jpg` as placeholder data.

Quality bar: every screen uses `SafeArea` and the shared page padding, so text
never touches the edge; long content scrolls; buttons and cards use Material
ink, so they have a pressed state; loading (Welcome, the *Classifying…*
overlay), empty (Home "No result yet", History) and error (Welcome start-up
error, snack bar on a failed classification) states are all designed.
`test/screens_test.dart` renders Result, History and the Welcome error state on
a 320×568 screen and fails on any overflow.

### Q: Name two things in the Figma design that you changed or left out in Flutter, and why.

1. **The Roboto font is not bundled.** The kit sets every style in Roboto.
   The app keeps the M3 type scale (sizes and weights) but uses the platform
   font: Roboto on Android already, San Francisco on iOS. Bundling Roboto would
   add font files or the `google_fonts` package for no visible gain on the
   Android phone we demo on.
2. **No top app bars on the three tabs, and no FAB.** The kit's screens use a
   small top app bar plus a floating action button for the main action. Home,
   History and Model have a large page title in the body instead, and the three
   sources are equal-weight cards rather than one FAB, because the lab requires
   three *clearly separated* actions and a FAB would make one of them look more
   important than the others. The Result screen does keep the kit's top app
   bar, because it is a pushed screen that needs a back button.

### Q: The Model screen shows the labels. Does it read them from the classifier or from the file again? Defend your choice.

From the classifier: `ModelScreen` displays `classifier.labels`, the list
`Classifier.load()` parsed once at start-up.

That list is the one the model's output is actually paired with — index `i` of
the output tensor becomes `labels[i]` in `classify`. Showing that same list
means the Model screen describes exactly what the app will output, in the same
order. Reading `labels.txt` a second time would show a copy that only matches
by coincidence: it would need its own error handling for a missing file, it
would repeat the parsing, and if the two ever disagreed the screen would be
documenting something the classifier is not doing. It is also free: the list is
already in memory and the Model screen already receives the classifier by
constructor injection.

## Part 5 — Three sources, one result

`lib/services/image_sources.dart` has the three sources. Each one only delivers
a `Uint8List`; no file path leaves the class.

- **Camera (T18):** `fromCamera()` calls `pickImage(source: ImageSource.camera, maxWidth: 1024)`.
- **Gallery (T19):** `fromGallery()` is the same call with `ImageSource.gallery`.
- **Download (T20):** `fromUrl(url, onProgress:)` sends a streamed `GET`, so the
  dialog (`lib/widgets/download_dialog.dart`) shows a real progress bar when
  the server sends a `content-length`. The answer is accepted only when the
  status is `200` **and** `content-type` starts with `image/`. Every failure
  becomes an `ImageSourceException` with a sentence for the user:

  | Case | Message |
  | --- | --- |
  | Not a URL | "That is not a web address. It should start with https://" |
  | 404 / other status | "Nothing was found at that address (error 404)." / "The server answered with error N." |
  | Web page instead of a picture | "That address is a web page, not a picture. Open the image itself and copy its address." |
  | No network | "No connection to that address. Check the internet and the address." |
  | Timeout (15 s) | "The download took too long. Check the connection and try again." |

  Errors stay inside the dialog so the address can be fixed and retried.
  `test/image_sources_test.dart` covers every row with a `MockClient`.
  The other route — saving a picture from the phone's browser and picking it
  through **Choose from gallery** — needs no extra code: it is the gallery source.

Cancelling the camera, the gallery or the download dialog returns `null`, and
`HomeShell._classify` simply returns: no error, no navigation.

**One path (T21/T22).** All three sources call the same
`HomeShell._classify(origin, loadBytes)`: bytes → `Classifier.classify` →
`SessionHistory.add` → push `ResultScreen`. Result is one widget for every
source; History stores the bytes and the predictions, so tapping an entry
reopens Result without running the model again.

### T23 — evaluation

> **TODO:** fill in on the phone. Three new pictures per class (not training
> samples), using all three sources across the test.

| # | Source | Expected | Predicted | % | Correct |
| --- | --- | --- | --- | --- | --- |
| 1 | Camera | Phone | | | |
| 2 | Gallery | Phone | | | |
| 3 | Download | Phone | | | |
| 4 | Camera | Notebook | | | |
| 5 | Gallery | Notebook | | | |
| 6 | Download | Notebook | | | |
| 7 | Camera | Zayniddin | | | |
| 8 | Gallery | Zayniddin | | | |
| 9 | Download | Zayniddin | | | |
| 10 | Camera | Magic mouse | | | |
| 11 | Gallery | Magic mouse | | | |
| 12 | Download | Magic mouse | | | |
| 13 | Camera | Wallet | | | |
| 14 | Gallery | Wallet | | | |
| 15 | Download | Wallet | | | |
| 16 | Camera | Arm | | | |
| 17 | Gallery | Arm | | | |
| 18 | Download | Arm | | | |

**Overall accuracy:** __ / 18 = __ %
**Weakest class:** __

### Q: The same object scored differently from the camera and from a downloaded picture. Give two reasons that come from your training data rather than from your code.

1. **Every training sample came from one camera in one room.** All samples
   were recorded with the laptop webcam at the lab desk: the same lighting,
   white balance, background, resolution and lens. A phone photo is close to
   that; a downloaded picture usually is not — studio lighting, a white or busy
   background, a different angle, often heavy compression. The model learned
   "a wallet *on our desk under our lamp*", so anything that changes the
   scene moves the score even when the object is the same kind.
2. **We trained on our specific objects, not on the category.** The Wallet
   class is *our* wallet, the Phone class is *our* phone. A picture from the
   internet shows a different wallet of a different colour and shape. With
   only ~50 samples of one instance, the model never saw what varies inside
   the category, so a different instance scores lower or is pulled toward
   another class that happens to share its colour or shape.

### Q: `classify` runs on the UI thread. How long does it take on your phone, and what does the user see during that time?

> **TODO:** read the number on the phone — the Result screen prints
> "Classified on the phone in N ms", measured with a `Stopwatch` inside
> `Classifier.classify`.

Measured: **__ ms** on __ (phone model).

During that time the UI thread is busy, so no frame is drawn. `HomeShell`
shows the *Classifying…* overlay and waits 50 ms before calling `classify`, so
the overlay is on screen first; then the spinner **freezes** mid-turn for the
whole inference, taps are ignored, and the Result screen appears when it
finishes. Most of that time is the pure-Dart pre-processing (decode, rotate,
crop, building a 224 × 224 × 3 nested list), not the model itself. Stretch
goal 3 (`IsolateInterpreter`) would keep the spinner moving.

## Checkpoint questions

### 1. Trace one photo from the shutter button to the percentage on screen.

| Step | Data | File |
| --- | --- | --- |
| Shutter in the system camera app | JPEG on the device, shrunk to ≤ 1024 px wide | `image_picker` (native) |
| `pickImage` returns an `XFile`, `readAsBytes()` | `Uint8List` (encoded JPEG) | `lib/services/image_sources.dart` |
| `_classify(ImageOrigin.camera, …)` | same `Uint8List` | `lib/screens/home_shell.dart` |
| `img.decodeImage` | `img.Image` (decoded pixels) | `lib/services/classifier.dart` |
| `bakeOrientation` + `copyResizeCropSquare(size: 224)` | 224 × 224 `img.Image`, upright, centre square | `classifier.dart` |
| `value / 127.5 - 1` per channel | nested `List` shape `[1, 224, 224, 3]` of doubles in −1..1 | `classifier.dart` |
| `_interpreter.run` | `[[p0 … p5]]`, shape `[1, 6]`, softmax, sums to 1 | `classifier.dart` (TFLite native) |
| Pair index *i* with `labels[i]`, sort | `List<Prediction>` highest first | `classifier.dart` |
| Wrap with bytes and source | `Classification`, added to `SessionHistory` | `lib/models/classification.dart`, `lib/services/session_history.dart` |
| One row per prediction | `Prediction.percent` → `"86.4%"` next to a bar | `lib/screens/result_screen.dart`, `lib/widgets/prediction_bars.dart` |

### 2. Which three lines of `pubspec.yaml` would break the app if deleted, and what would the error be?

1. **`- assets/model/`** (under `assets:`) — the model and labels are no longer
   bundled. The build succeeds, but at start-up `Interpreter.fromAsset` fails
   with *Unable to load asset: "assets/model/model_unquant.tflite"*, which our
   Welcome screen shows as "The model file could not be loaded." plus the
   expected path.
2. **`tflite_flutter: ^0.12.1`** — the package is gone, so compilation stops at
   `classifier.dart`: *Error: Couldn't resolve the package 'tflite_flutter'*
   / *Target of URI doesn't exist: 'package:tflite_flutter/tflite_flutter.dart'*.
3. **`image: ^4.13.1`** — same kind of compile error in `classifier.dart`
   for `package:image/image.dart`, and every `img.` call becomes undefined.

(`image_picker` and `http` would break the build the same way in
`image_sources.dart`.)

### 3. Why must the pre-processing in Flutter match what Teachable Machine did during training? Name the two things that have to match.

The network's weights were fitted to one exact kind of input. It has no idea
what a "photo" is; it only sees numbers, and it gives good answers only for
numbers that look like the ones it was trained on. If Flutter prepares the
image differently, the model still runs and still returns six probabilities
— just wrong ones, with no error anywhere.

1. **Geometry:** a centred square crop resized to **224 × 224**, upright
   (EXIF rotation applied), RGB channel order.
2. **Value range:** each channel mapped from 0..255 to **−1..1**
   (`value / 127.5 − 1`) for the floating-point model.

### 4. Your model is 97 % sure that a shoe is a mug. Is that a bug? What does a percentage from this model mean, and what does it not mean?

Not a bug — it is what this kind of model does. The output is a softmax over
the six classes it knows, so the numbers always add up to 100 % across those
six. 97 % means: *of the six things I was trained on, this picture is much
closer to "mug" than to any other*. It does **not** mean "there is a 97 %
chance this is a mug in the real world", and it says nothing about objects
outside the six classes — there is no "unknown" output. The percentages are
also not calibrated: high confidence on unfamiliar input is common. A
background class, more varied training data, or a confidence threshold with
an "I'm not sure" message reduce the problem but do not remove it.

### 5. What stays on the device and what leaves it in this app? Compare with a cloud vision API.

**Stays on the device:** the model and labels (bundled assets), every photo
from the camera and gallery, the decoded pixels, the inference, the results
and the History list (in memory only, gone when the app closes). Nothing is
uploaded; classification works in airplane mode.

**Leaves the device:** only the download source makes a network request — a
`GET` to the address the user typed. That server learns the phone's IP address
and that this image was requested; the image comes *in*, nothing goes out.

**Cloud vision API:** the photo itself is uploaded to a third party. That
needs a network, adds latency, usually costs money per request, and the
provider may log or keep the image — a privacy question for photos of people
(our "Zayniddin" and "Arm" classes). In exchange it recognises thousands of
categories with a much larger model and gets better without an app update.
On-device means private, offline, free and fast, but limited to our six
classes and our phone's speed.
