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
