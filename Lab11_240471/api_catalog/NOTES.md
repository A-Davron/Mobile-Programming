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
