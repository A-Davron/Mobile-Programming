# Mobile Programming

Coursework for the Mobile Programming module, student ID 240471.

```
Mobile-Programming/
├── Lab2_240471.dart          console Dart, sections 1-4
├── Lab3_240471.dart          console Dart, sections 5-12
├── Lab4_240471.dart          Flutter widgets
└── Lab5_240471/              Flutter project: navigation and routing
    └── lib/
        ├── main.dart         app, route table, category menu
        ├── app_routes.dart   every named route in one place
        ├── category1.dart    Navigator: push and pop
        ├── category2.dart    named routes
        ├── category3.dart    arguments through constructors
        ├── category4.dart    arguments through named routes
        ├── category5.dart    transition animations
        └── category6.dart    go_router, own entry point
```

## Lab 2 and Lab 3

Plain Dart exercises. Every problem is commented out, one after another.
Uncomment the one you want, then run it:

```bash
dart run Lab2_240471.dart
```

## Lab 4

Flutter source only. There is no project around it, so it does not run from
here — paste it into a Flutter project's `lib/main.dart` to try it.

## Lab 5

```bash
cd Lab5_240471
flutter run
```

Category 6 uses `go_router`, which drives `MaterialApp.router` instead of the
`MaterialApp` of the other categories, so it has its own entry point:

```bash
flutter run -t lib/category6.dart
```

Pick a device with `-d`, for example `-d chrome` or `-d windows`.

### Checks

```bash
flutter analyze
```

## Requirements

Flutter SDK with Dart 3.13.4 or newer. Lab 5 enables Android, web and Windows.
