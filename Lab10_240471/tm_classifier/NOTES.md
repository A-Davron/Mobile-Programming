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
