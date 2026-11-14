# Lab 9 — One Cart, Four Ways: lab notes

## Part 1 — Setup and shared code (P1-SHARED)

### Why is `CartLine` immutable with a `copyWith` instead of a mutable `qty` field?

Every state holder in this lab decides whether listeners should be notified by
comparing the old state with the new one. If `qty` were mutable, a mutation would
change the object that the previous state still points at, so "old" and "new"
would be the same instance and compare equal. The notification would be skipped,
and any code that kept a reference to the earlier state (undo history, a test
expectation, a `BlocListener` comparing `previous` and `current`) would silently
observe the new value instead of the old one.

Only the `setState` version would still appear to work with mutation, because
`setState` does not compare anything: it marks the element dirty unconditionally,
so `build` re-runs and reads the mutated list. That is the trap — the mutable
model passes in Part 2 and then fails in Riverpod, Cubit and Bloc, where
`state = ...` with an equal (or identical) value notifies nobody. The same bug
also breaks undo in all four styles, since the history entries alias one list.

### Why does `CartBody` take callbacks rather than importing a provider or a bloc directly?

Because the shared UI must stay style-independent. If `CartBody` imported
`cartProvider` it would only render inside a `ProviderScope`, could not be reused
by the Cubit or Bloc pages, and would need a Riverpod container in every widget
test. Taking `lines` plus `onAdd` / `onRemove` keeps it a pure function of its
arguments: each of the four pages wires its own state holder to the same dumb
widget, which is exactly what makes the four implementations comparable. It also
makes the widget cheap to test on its own and keeps the only difference between
the four parts in *where state lives, how it mutates, and how the UI subscribes*.

### Checkpoint

- `flutter analyze` — no issues.
- `flutter test` — no failures (per-part test files are placeholders until T6).
- Home page shows four `FilledButton`s; each pushes its stub page
  (verified with a temporary widget test: four buttons, all four routes open).

## Part 2 — Baseline: setState (P2-SETSTATE)

### T3 — why storing `total` would be a bug waiting to happen

A stored `total` is a second source of truth for something that is already fully
determined by `lines` and `coupon`. Every future mutation then has to remember to
recompute it, and the one that forgets leaves the UI showing a total that no
longer matches the cart. The compiler cannot help, because a stale `double` is
still a perfectly valid `double`. As a getter, `total` cannot drift: it is
recomputed from the current state every time it is read, so adding a line or
applying a coupon updates it with no extra code. Storing it would also make
equality lie — two `CartState`s with the same lines but different cached totals
would compare unequal.

### T4 — what happens without `if (!mounted) return;`

`CheckoutApi.submit` takes 1500 ms. If the user pops the page during that wait,
the `State` object is unmounted but the `await` still resumes and the `catch`
still runs. Calling `setState` then throws
"setState() called after dispose()", and `ScaffoldMessenger.of(context)` looks up
an element that is no longer in the tree. The `mounted` check makes the result of
a request whose page is gone a no-op. Note the messenger is captured into a local
*before* the `await` as well, so no `BuildContext` is used across the gap.

### After T4, how would a second page (an order history) read the cart?

It cannot, as written. `_state` is a private field on `_SetStateCartPageState`,
reachable only from inside that `State` object and destroyed when the page pops.
To share it I would have to lift the state above both pages and pass it down:
hoist `CartState` into a common ancestor `StatefulWidget` and thread it (plus
every callback) through each intermediate widget as constructor arguments, or
wrap it in an `InheritedWidget`/`InheritedNotifier` so descendants can look it up
by context. Either way the owner must sit above the `Navigator` that hosts both
pages, which means the state's lifetime stops matching the page's. That is
exactly the problem Parts 3-5 remove by putting the cart in a provider or a bloc,
where any widget can subscribe without being a descendant of the cart page.

### After T5, where does `_history` live, and hot restart versus hot reload?

`_history` is a field on the same `State` object as `_state`, so it lives on the
heap for as long as that element stays in the tree, and it is thrown away when
the page pops — undo does not survive navigation.

- **Hot reload** keeps the running isolate and reuses existing `State` objects,
  re-running only `build`. `_history` and `_state` survive, so the cart and the
  undo stack are still there. `initState` and field initialisers do not re-run,
  which is why a changed initial value does not show up on a reload.
- **Hot restart** tears down the isolate and rebuilds the widget tree from
  `main()`. Both `_state` and `_history` are recreated empty — cart cleared, undo
  disabled. Nothing is persisted anywhere.

### T6 — how much of the test is about finding widgets

Nearly all of it: four of the five statements locate widgets
(`find.text('Keyboard · 49')` twice, `find.byType(TextField)`,
`find.widgetWithText(OutlinedButton, 'Apply')`), plus `pump` calls to let frames
settle. Exactly one line asserts cart behaviour (`find.text('88.20')`), and even
that reads the number off the rendered summary card rather than from the state.
The pricing rule it checks (49 × 2 = 98, minus 10 % = 88.20) is pure logic that a
plain unit test on `CartState` could cover with no widget tree at all. That is
the cost of state living inside the widget: the only way in is through the UI.

### Checkpoint

- T1-T5 verified in widget tests: `−` at `qty == 1` removes the line; a bad
  coupon shows "Unknown coupon code"; undo is disabled on an empty history and
  re-disables after the last undo; a 597.00 checkout shows the `MaterialBanner`
  "Card declined" and keeps `× 3` in the cart; a 25.00 checkout shows the
  "Order ORD-…" `SnackBar` and empties the cart.
- T6 (`test/setstate_cart_test.dart`) passes; `flutter analyze` reports no issues.

## Part 3 — Riverpod: Notifier and NotifierProvider (P3-RIVERPOD)

### Name the three `ref.read`s and the two `ref.watch`es, and justify each

**`ref.read`**

1. `ref.read(cartProvider.notifier)` in `RiverpodCartPage.build` — a one-off
   lookup for method handles (`add`, `remove`, `changeQty`, `applyCoupon`,
   `checkout`, `undo`). The notifier instance never changes, so subscribing to
   it would buy nothing; `ref.watch` here would be the classic bug of rebuilding
   for a reference that is already stable.
2. `ref.read(checkoutApiProvider)` inside `CartNotifier.checkout` — the API is a
   stateless dependency used once per call. Watching it inside a method is not
   even meaningful: `ref.watch` belongs in `build`, not in a callback.
3. `ref.read(cartProvider)` inside the `ref.listen` callback in the page — the
   listener fires on a status change and then needs `orderId` / `checkoutError`
   off the current state. The callback runs outside `build`, so a read is the
   correct access, and the value is already known to be fresh.
   (`ref.read(cartProvider.notifier).canUndo` inside `canUndoProvider` is the
   same pattern: the subscription there is the `ref.watch` on the state, the
   `read` only reaches the notifier object.)

**`ref.watch`**

1. `ref.watch(cartProvider)` in the page — the page renders the list, the coupon
   error and the checkout button, all of which come off `CartState`, so it wants
   every change.
2. `ref.watch(canUndoProvider)` in the page — the `AppBar` action needs one
   `bool`. Going through the derived provider means the button's enabled state
   follows the history without the page knowing the history exists.
   The summary card adds four more, all narrowed:
   `ref.watch(cartProvider.select((s) => s.total))` and the same for `subtotal`,
   `discount` and `itemCount`.
   Inside `canUndoProvider`, `ref.watch(cartProvider)` is what makes the provider
   recompute at all — `canUndo` reads a private `_history` field that Riverpod
   cannot observe, so the state change is the only available trigger.

### Why does the summary card rebuild less often than the `setState` version?

Two reasons, and both are needed.

1. **It subscribes to projections, not to the state.** `select` compares the
   projected value, so a change to `couponError`, `status`, `orderId` or
   `checkoutError` leaves `total`, `subtotal`, `discount` and `itemCount` equal
   and the card is not rebuilt. In Part 2 there is no projection to compare:
   `setState` marks the whole element dirty and the entire subtree re-runs,
   summary included, for every state change of any kind.
2. **The page passes a `const RiverpodSummaryCard()`.** When the page rebuilds,
   Flutter sees the identical widget instance in the same slot and skips the
   child's `build` entirely. So a page rebuild does not drag the summary with it;
   only the card's own watched values can rebuild it.

Measured in a widget test (`debugPrint` captured): applying an unknown coupon
rebuilt the page, showed "Unknown coupon code", and produced **zero** summary
rebuilds; the next quantity change produced exactly **one**. During a failed
checkout the status went `submitting` → `failure` and the banner appeared with no
summary rebuild at all.

### T2 — does `state = state.copyWith(coupon: code)` notify when the code is unchanged?

Before overriding `==`: yes, always. `copyWith` returns a new instance, and a
plain class compares by identity, so `updateShouldNotify` sees two different
objects and every assignment notifies — the UI rebuilds for a no-op.

After overriding `==` and `hashCode` on `CartState`: no. Riverpod compares old
and new with `==`, finds them equal and notifies nobody. Asserted in
`test/riverpod_cart_test.dart` ("re-applying the same coupon does not notify"):
the first `applyCoupon('SAVE10')` produces one notification, the second produces
none, and a following `changeQty` produces one again.

`CartLine` needed `==` too (comparing `product.id` and `qty`), because
`CartState ==` compares `lines` element-wise — `List ==` is identity-based, so
without it two states with equal contents would still compare unequal and the
override would never fire.

### T4 — why no `mounted` check is needed here

`mounted` guards a `State` object that can be disposed while an `await` is in
flight. Here the `await` is inside `CartNotifier`, which lives in the
`ProviderContainer` owned by the root `ProviderScope`, not in the widget tree.
Popping the page destroys the subscriber, not the notifier: `cartProvider` is not
`autoDispose`, so the notifier survives, the assignment to `state` is valid, and
the result lands in state that the page will show again when it is reopened. The
page's side effects are in `ref.listen`, which Riverpod cancels automatically
when the element is unmounted, so nothing touches a dead `BuildContext` either.

If `cartProvider` *were* `autoDispose`, the notifier could be disposed mid-flight
and assigning `state` afterwards would throw — that is when you would need the
Riverpod equivalent of the `mounted` check.

### T5 — `cartProvider` as `autoDispose`: what happened to the history, and why?

Verified with `NotifierProvider(CartNotifier.new, isAutoDispose: true)`: after
adding two lines and then dropping the last listener, the state read back as an
empty cart and `canUndo` was `false` — both the cart and the undo stack were
gone.

`autoDispose` destroys the provider's element as soon as its listener count hits
zero. Popping the page removes the only subscriber, so the `CartNotifier`
instance is thrown away along with its private `_history` list; reading the
provider afterwards constructs a *new* notifier and calls `build()` again, which
returns `const CartState()`. The history is not special here — it is ordinary
instance state on a disposed object. The final code keeps `cartProvider`
non-`autoDispose`, matching the sample's promise that the cart survives a pop.

### Checkpoint

- Feature parity with Part 2 confirmed in a widget test: stepper (`× 3` → `× 2`),
  coupon error, 597.00 checkout showing the "Card declined" `MaterialBanner`
  while the cart is kept, undo restoring the previous state, and undo disabled on
  an empty history.
- Summary card rebuild counts measured as above (0 on coupon error, 1 on
  quantity change).
- `test/riverpod_cart_test.dart`: 4 tests pass with no widgets — total 88.2,
  mocked failing `checkoutApiProvider` leaving `status == failure` with lines
  intact, the `==` notification check, and undo through `canUndoProvider`.
- `flutter analyze`: no issues. Full `flutter test`: 5 tests, all passing.

## Part 4 — Cubit: methods that emit (P4-CUBIT)

### T2 — the second identical coupon emit is dropped

`CartCubit.onChange` prints every accepted change. Applying `SAVE10` twice in a
row logs `[CartCubit] onChange → total=88.2` exactly once: the second
`emit` receives a state that is `==` the current one, so bloc never pushes it
through the stream and `onChange` is not called at all. This is the same `==`
override on `CartState` (and `CartLine`) that Part 3 needed; without it a cubit
would rebuild the whole page for a no-op, because `copyWith` always returns a
fresh instance. Asserted in `test/cubit_cart_test.dart`
("re-applying the same coupon is dropped"): one state emitted, not two.

`_mutate` also checks the candidate before pushing onto `_history`, so a dropped
emit does not leave a phantom entry that `undo` would later restore to the same
state.

### T4 — what `emit` does after `close()`, and the guard

`BlocProvider` calls `close()` when the page is popped. A `checkout()` that is
still awaiting the 1500 ms API call resumes afterwards and calls `emit` on a
closed cubit, which throws `StateError: Cannot emit new states after calling
close`. The guard is `if (isClosed) return;` immediately after the `await`,
before both the success and the failure `emit`. It is the Cubit counterpart of
the `setState` version's `if (!mounted) return;` — the difference is only *what*
died: there, the `State` object; here, the cubit itself.

### T5 — why `bool get canUndo` on the cubit is not enough

`BlocBuilder` rebuilds when a *state* is emitted; it has no way to observe a
plain getter that reads a private `_history` field, so the Undo button would
keep whatever enabled/disabled value it had at its last rebuild and only
accidentally correct itself when something else changed. The fix is to make it
part of the state: `CartState.canUndo` is emitted like every other field, so
`BlocBuilder` with `buildWhen: (p, c) => p.canUndo != c.canUndo` rebuilds the
`IconButton` exactly when undo becomes possible or impossible. The history list
itself stays private — only the one observable flag it produces goes into the
state, which keeps `CartState ==` cheap (comparing a list of past states would
be recursive).

### What would break if you put `BlocProvider` inside `CartBody`?

Three things. (1) `CartBody` would stop being style-independent — it would import
`CartCubit` and could no longer be used by the `setState` and Riverpod pages.
(2) Every rebuild of the page that replaced the `CartBody` widget could create a
new cubit, so the cart would reset; a provider must sit above the widgets whose
lifetime is shorter than the state's. (3) Nothing outside `CartBody` could reach
the cubit: the `AppBar` Undo action and the `BlocListener` for the checkout
banner are siblings, not descendants, so `context.read<CartCubit>()` there would
throw `ProviderNotFoundException`. That is also why this page puts the provider
above the `Scaffold` and reads the cubit in a separate `_CubitCartView` child.

### Riverpod equivalents

| flutter_bloc | Riverpod |
| --- | --- |
| `BlocProvider` | `ProviderScope` (+ the provider declaration itself); `overrides:` for scoping |
| `BlocBuilder` | `ref.watch(provider)` in a `ConsumerWidget` |
| `BlocListener` | `ref.listen(provider, (prev, next) { … })` |
| `context.read<T>()` | `ref.read(provider.notifier)` |
| `buildWhen:` / `BlocSelector` | `ref.watch(provider.select((s) => …))` |

### Checkpoint

- Feature parity with Parts 2 and 3, verified in a widget test on
  `CubitCartPage`: stepper (`× 2` → `× 1`), `SAVE10` showing `44.10`, undo
  restoring the pre-coupon total, a 597.00 checkout showing the spinner then the
  "Card declined" `MaterialBanner` with `× 3` still in the cart.
- Dropped emit shown in the `onChange` log and asserted in the third `blocTest`.
- `test/cubit_cart_test.dart`: 3 `blocTest`s pass.

## Part 5 — Bloc: events in, states out (P5-BLOC)

### T2 — what the transition log adds over the cubit's `onChange`

`LoggingBlocObserver.onTransition` in `main.dart` prints
`currentState → event → nextState`, so the log reads
`[CartBloc] CartCouponApplied → total=88.2`. The cubit's `onChange` only has
`currentState → nextState`: it can say the total went from 98.0 to 88.2, but not
*why*. With a bloc the cause is a named, typed object, so the log tells you
whether the total changed because of a coupon, a quantity change or an undo —
which is exactly what you want when reading a bug report. A cubit cannot produce
this, because it has no event to report.

### T4 — `droppable()` with three fast taps

`on<CartCheckoutRequested>(_onCheckout, transformer: droppable())` ignores any
event that arrives while a `CartCheckoutRequested` handler is still running.
Tapping Checkout three times in quick succession therefore emits `submitting`
once and `success` once — asserted in `test/bloc_cart_test.dart`
("droppable(): three fast checkout taps submit once"). Without the transformer
the default is sequential: all three would run, one after the other, so the card
would be charged three times.

With the Cubit there is no transformer at all; `checkout()` is a plain method and
three taps start three overlapping futures. The only defences are imperative —
disable the button while `status == submitting` (which `CartBody` already does,
so the user cannot normally reach the third tap) or an `if (state.status ==
CheckoutStatus.submitting) return;` guard at the top of the method.

### T5 — which events are undoable

`isUndoable(CartEvent)` in `cart_event.dart` is an exhaustive `switch` over the
sealed hierarchy: `CartProductAdded`, `CartProductRemoved`, `CartQtyChanged` and
`CartCouponApplied` push onto the history; `CartCheckoutRequested` and
`CartUndone` do not. Checkout only moves the cart through
`submitting → success/failure`, and undoing a status is meaningless; `CartUndone`
is what consumes the history, so recording it would make undo a no-op loop. The
value of the `switch` is that it is exhaustive — adding a seventh event does not
compile until the question "is this undoable?" has been answered.

### When is the event layer worth its boilerplate?

Worth it for **checkout**. Because the tap is an object (`CartCheckoutRequested`)
rather than a method call, `droppable()` solves the triple-tap problem
declaratively in one word, retries and analytics hang off the same event, and
the observer log shows precisely which user intention produced which state.

Pure overhead for the **quantity stepper**. `CartQtyChanged(id, delta)` plus its
`on<…>` registration is three extra files' worth of indirection over
`cubit.changeQty(id, delta)` for a synchronous, one-line, always-allowed state
change that nothing else in the app cares about.

### Which style can drop duplicate taps declaratively?

Only Bloc, via `transformer: droppable()` (and the rest of `bloc_concurrency`:
`restartable`, `concurrent`, `sequential`, `debounce`). In the other three it is
imperative and hand-written: in Cubit and in the Riverpod notifier, an
`if (state.status == CheckoutStatus.submitting) return;` at the top of
`checkout()`, or holding the in-flight `Future` in a field and returning it;
in `setState`, a `bool _submitting` field checked before starting. All three also
rely on the button being disabled while submitting, which is UI state doing the
work that Bloc does in the state layer.

### Checkpoint

- Feature parity with Parts 2-4, verified in a widget test on `BlocCartPage`:
  same flow as the Cubit page, identical results.
- Transition log shows `event → nextState`; triple-tap checkout submits once.
- `test/bloc_cart_test.dart`: 3 `blocTest`s pass.
- Full suite: `flutter test` → 11 tests passing (1 setState, 4 Riverpod,
  3 Cubit, 3 Bloc). `flutter analyze`: no issues.

## Checkpoint questions

### 1. Where the state lives and when it dies

- **setState** — in the `_SetStateCartPageState` object; dies when the page is
  popped (or on hot restart). No other widget can reach it.
- **Riverpod** — in the `ProviderContainer` of the root `ProviderScope`; lives as
  long as the app, because `cartProvider` is not `autoDispose`. With
  `autoDispose` it dies when the last listener goes away.
- **Cubit** — in the `CartCubit` instance owned by `BlocProvider`; dies when that
  provider is disposed, i.e. with the page subtree it sits in. Move the provider
  above `MaterialApp` and it lives as long as the app.
- **Bloc** — identical to Cubit: the `CartBloc` instance under its
  `BlocProvider`, closed when the provider is disposed.

### 2. The single public mutation API

- **Riverpod `Notifier`** — assigning `state` (only from inside the notifier;
  outside code calls its methods via `ref.read(provider.notifier)`).
- **Cubit** — `emit(newState)`, protected, so again only the cubit's own methods.
- **Bloc** — `add(event)`; `emit` exists but is confined to the handlers, so the
  only thing the UI can do is add an event.
- **No single API: `setState`.** Any code inside the `State` object can assign
  any field and call `setState`, so there is no one place a mutation goes
  through — which is why it is the hardest of the four to audit or log.

### 3. Mapping the subscription APIs

| Riverpod | flutter_bloc | What it does |
| --- | --- | --- |
| `ref.watch(p)` | `BlocBuilder` / `context.watch` | subscribe and rebuild |
| `ref.read(p.notifier)` | `context.read<T>()` | one-off lookup, no subscription |
| `ref.listen(p, cb)` | `BlocListener` | run a side effect, no rebuild |
| `p.select(...)` | `buildWhen:` / `BlocSelector` | narrow what triggers a rebuild |

`setState` is none of them — it is the *emit* side, not the subscribe side. There
is no subscription at all: the widget that owns the state marks itself dirty, so
`setState` is closest to `emit`/`state =` with the subscription hard-wired to
exactly one widget and no way to narrow it.

### 4. Why they skip notifying on `==`, and what `CartState` needs

Rebuilding the UI for a state that is indistinguishable from the current one is
wasted work, and it also makes `previous`/`next` comparisons in listeners
meaningless, so all three compare before notifying. For that to behave correctly
`CartState` needs **(1)** a correct `operator ==` covering every field, and
**(2)** a `hashCode` consistent with it — plus, because `List ==` is identity
based, element-wise comparison of `lines` and value equality on `CartLine`
itself. `Equatable` (or a sealed/record state) does both for you. Without them
every `copyWith` notifies; with a broken `==` that is too permissive, real
changes are silently swallowed, which is the worse failure of the two.

### 5. The guard each style needed after the `await`

| Style | Guard | Why |
| --- | --- | --- |
| setState | `if (!mounted) return;` | the `State` object can be disposed while the API call is in flight; `setState` after dispose throws, and `context` is dead |
| Riverpod | none | the notifier lives in the container, not the tree; popping the page removes a listener, not the notifier (a guard *would* be needed if the provider were `autoDispose`) |
| Cubit | `if (isClosed) return;` | `BlocProvider` closes the cubit with the subtree, and `emit` after `close()` throws |
| Bloc | `if (emit.isDone) return;` | same closing problem, but the `emit` handed to a handler is also finished when the handler's event is superseded, so the per-handler flag is the precise check |

They differ because each style's state holder has a different owner and therefore
a different lifetime: a widget element, a provider container, or a stream that
can be closed.

## Comparison table

Line counts are `wc -l` over each style's own files — the sample from the lab
sheet plus everything T1-T5 added, comments included. The shared
`models/cart.dart` and `widgets/cart_body.dart` are excluded: they are written
once and reused by all four.

| Style | Files | LOC T1-T5 | Test LOC | Tests | Strength | Weakness |
| --- | --- | --- | --- | --- | --- | --- |
| setState | 1 (`cart_page_setstate.dart`) | 120 | 22 | 1 | Zero dependencies and zero concepts; everything is in one file you can read top to bottom | State dies with the page and no other widget can read it; every change rebuilds the whole subtree; only testable through the UI |
| Riverpod | 2 (`cart_notifier.dart`, `cart_page_riverpod.dart`) | 161 | 85 | 4 | State outlives the page and is reachable anywhere; `select` gives precise rebuilds; `ProviderContainer` + `overrideWithValue` make tests trivial and widget-free | Compile-time safety does not cover provider lifetimes — `autoDispose` silently discards the undo history, and `read` vs `watch` mistakes are not errors |
| Cubit | 2 (`cart_cubit.dart`, `cart_page_cubit.dart`) | 187 | 71 | 3 | Closest thing to a plain class with methods; `blocTest` asserts whole state sequences; `BlocListener`/`BlocSelector` separate effects from rebuilds cleanly | Scope is tied to the widget tree, so the cart dies with the page unless the provider is hoisted; no event means no `onTransition`, so a change cannot be traced to a cause; getters on the cubit are invisible to `BlocBuilder` |
| Bloc | 3 (`cart_event.dart`, `cart_bloc.dart`, `cart_page_bloc.dart`) | 239 | 80 | 3 | Every mutation is a named, typed, loggable event; `transformer:` solves concurrency (`droppable`) declaratively; a sealed hierarchy makes "did I handle this?" a compile-time question | The most boilerplate by a wide margin — an event class plus a registration for every one-line change that a cubit does with a method |

### Not done

- Stretch goals 1-4.
- Screen recording (to be recorded from the running app; the same flow — add,
  stepper, coupon, failed checkout, undo — works identically on all four pages).
