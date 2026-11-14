# Lab 9 — One Cart, Four Ways: lab notes

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
