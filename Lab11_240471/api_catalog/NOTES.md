# Lab 11 — Fetch, Parse, Emit: Notes

## Part 1 — Setup and your first request

`dart run bin/peek.dart` output:

```
200
Essence Mascara Lash Princess
_Map<String, dynamic>
```

### In `product.json`, find a number, a list of strings, a nested object and a list of objects

| Kind | Field | Example |
|---|---|---|
| Number | `price` (also `rating`, `stock`, `weight`) | `9.99`; note `weight` is `4`, an integer |
| List of strings | `tags` (also `images`) | `["beauty", "mascara"]` |
| Nested object | `dimensions` (also `meta`) | `{"width": 15.14, "height": 13.08, "depth": 22.99}` |
| List of objects | `reviews` | `[{"rating": 3, "comment": "...", "date": "...", "reviewerName": "...", "reviewerEmail": "..."}, ...]` |

### What does `/products/0` return?

Status **404 Not Found**, with a JSON body:

```json
{"message":"Product with id '0' not found"}
```

The error response is still valid JSON. That is why the status code must be checked before parsing: otherwise this body would be passed to `Product.fromJson` and crash on missing keys.

## Part 2 — Models from JSON

All four models (`Dimensions`, `Product`, `Review`, `ProductPage`) are written by hand in `lib/models/`.

**Decision for missing `tags` (T6):** a missing `tags` key becomes an **empty list** (`?? const []`). "No tags" and "empty tags" mean the same thing to the UI, so the field stays a non-nullable `List<String>` and widgets never need a null check. The same rule is used for `reviews`. A missing `brand` becomes `null`, because there is no sensible default brand.

### What happens with `json['price'] as double` when the server sends `10`?

`jsonDecode` turns `10` into an `int`, and an `int` is not a `double` in Dart. The cast throws
`TypeError: type 'int' is not a subtype of type 'double' in type cast`.
The error is found at **run time**, not compile time: `json['price']` is `dynamic`, so the compiler cannot know what the server will send. It works for `9.99` and crashes only for products whose price is a whole number. The fix is `(json['price'] as num).toDouble()`, which accepts both.

### Why test `fromJson` with a saved file instead of a live request?

- **Repeatable:** the file never changes, so the expected values (title, price, 3 reviews) stay true. Live data can change at any time.
- **Isolated:** a failure means the parser is wrong, not that the network, the server or DummyJSON was down.
- **Fast and offline:** it runs in milliseconds, works in CI and on a plane, and puts no load on the server.
- **Edge cases on demand:** a hand-written map can test missing or odd fields that the live server may never send.
