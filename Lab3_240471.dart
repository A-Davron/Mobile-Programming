// Problem 5.2
// Which mathematical calculation should i explain
/*
  S = a*b
  a = 2
  b = 3
  So S = 6
 */


// Problem 5.3
/// A simple class for validating user data.
// class Validator {
  /// Checks if the name is not empty.
  ///
  /// [name] is the user's name.
  ///
  /// Returns `true` if the name is valid.
  ///
  /// Throws [FormatException] if the name is empty.
  // static bool checkName(String name) {
  //   if (name.isEmpty) {
  //     throw FormatException('Name is empty');
  //   }
  //   return true;
  // }

  /// Checks if the age is valid.
  ///
  /// [age] is the user's age.
  ///
  /// Returns `true` if the age is valid.
  ///
  /// Throws [FormatException] if the age is less than 0.
//   static bool checkAge(int age) {
//     if (age < 0) {
//       throw FormatException('Invalid age');
//     }
//     return true;
//   }
// }

// void main() {
//   print(Validator.checkName('Davron'));
//   print(Validator.checkAge(20));
// }


// Problem 5.4
/// ## User Validator
///
/// This class checks if user information is valid.
///
/// **Validation rules:**
/// - Name must not be empty.
/// - Age must be greater than 0.
/// - Email must contain `@`.
///
/// **Example:**
/// ```dart
/// bool result = Validator.isValidAge(20);
/// print(result); // true
/// ```
// class Validator {
  /// Checks if the [age] is valid.
  ///
  /// Returns `true` if the age is greater than 0.
//   static bool isValidAge(int age) {
//     return age > 0;
//   }
// }

// void main() {
//   print(Validator.isValidAge(20));
// }


// Problem 5.5
/// A simple animal class.
// class Animal {
  /// Makes the animal sound.
  // void sound() {
  //   print("Animal sound");
  // }

  /// Old method. Use [sound] instead.
//   @deprecated
//   void oldSound() {
//     print("Old sound");
//   }
// }

/// A dog is an animal.
// class Dog extends Animal {
  /// Overrides the [sound] method.
//   @override
//   void sound() {
//     print("Dog barks");
//   }
// }

// void main() {
//   Dog dog = Dog();

//   dog.sound();
// }


// Problem 5.6
/// Represents a student.
// class Student {
  /// The student's name.
  // String name;

  /// The student's age.
  // int age;

  /// Creates a student.
  // Student(this.name, this.age);

  /// Displays student information.
//   void display() {
//     print("Name: $name");
//     print("Age: $age");
//   }
// }

// void main() {
//   Student student = Student("Ali", 20);

//   student.display();
// }



// Problem 6.2
// class Person {
//   String name;
//   int age;

//   Person(this.name, this.age);
// }

// void main() {
//   Person person = Person('Davron', 20);

//   print('Name: ${person.name}');
//   print('Age: ${person.age}');
// }


// Problem 6.3
// class Person {
//   String name;
//   int age;

//   Person(this.name, this.age)
//       : assert(age >= 0 && age <= 120);
// }

// void main() {
//   Person person = Person('Davron', 20);

//   print(person.name);
//   print(person.age);
// }


// Problem 6.4
// class Singleton {
//   static final Singleton _instance = Singleton._privateConstructor();
//   Singleton._privateConstructor();
//   factory Singleton() {
//     return _instance;
//   }
// }

// void main() {
//   Singleton first = Singleton();
//   Singleton second = Singleton();

//   print(identical(first, second));
// }


// Problem 6.5
// class Student {
//   String _name = "";
//   int _age = 0;

//   String get name => _name;

//   set name(String value) {
//     if (value.isEmpty) {
//       throw Exception("Name cannot be empty");
//     }
//     _name = value;
//   }

//   int get age => _age;

//   set age(int value) {
//     if (value < 0) {
//       throw Exception("Age cannot be negative");
//     }
//     _age = value;
//   }
// }

// void main() {
//   Student student = Student();

//   student.name = "Ali";
//   student.age = 20;

//   print(student.name);
//   print(student.age);
// }


// Problem 6.6
// class StudentData {
//   final String name;
//   final int age;

//   const StudentData(this.name, this.age);
// }

// void main() {
//   const student = StudentData("Ali", 20);

//   print(student.name);
//   print(student.age);
// }


// Problem 7.2
// enum Day {
//   monday,
//   tuesday,
//   wednesday,
//   thursday,
//   friday,
//   saturday,
//   sunday,
// }

// void main() {
//   for (var day in Day.values) {
//     print(day);
//   }
// }


// Problem 7.3
// enum Day {
//   monday,
//   tuesday,
//   wednesday,
//   thursday,
//   friday,
//   saturday,
//   sunday,
// }

// String getDisplayName(Day day) {
//   return switch (day) {
//     Day.monday => 'Monday',
//     Day.tuesday => 'Tuesday',
//     Day.wednesday => 'Wednesday',
//     Day.thursday => 'Thursday',
//     Day.friday => 'Friday',
//     Day.saturday => 'Saturday',
//     Day.sunday => 'Sunday',
//   };
// }

// void main() {
//   print(getDisplayName(Day.monday));
//   print(getDisplayName(Day.saturday));
// }


// Problem 7.4
// abstract class Animal {
//   String get sound;
// }

// enum Pet implements Animal {
//   dog('Woof'),
//   cat('Meow'),
//   cow('Moo');

//   final String _sound;

//   const Pet(this._sound);

//   @override
//   String get sound => _sound;
//   String get message => 'The animal says $sound';
// }

// void main() {
//   print(Pet.dog.sound);
//   print(Pet.cat.message);
// }


// Problem 7.5
// enum Color {
//   red,
//   green,
//   blue,
// }

// void main() {
//   String value = "green";

//   try {
//     Color color = Color.values.byName(value);
//     print(color);
//   } catch (e) {
//     print("Invalid color");
//   }
// }


// Problem 7.6
// enum Level {
//   low(1),
//   medium(2),
//   high(3);
//   final int value;
//   const Level(this.value);

//   static Level fromValue(int value) {
//     return Level.values.firstWhere(
//       (level) => level.value == value,
//     );
//   }
// }

// void main() {
//   Level level = Level.high;
//   print(level.value);
//   Level result = Level.fromValue(2);
//   print(result);
// }



// Problem 8.2
// class Animal {
//   void makeSound() {
//     print('Animal makes a sound');
//   }
// }

// class Dog extends Animal {
//   @override
//   void makeSound() {
//     print('Dog says: Woof!');
//   }
// }

// void main() {
//   Dog dog = Dog();
//   dog.makeSound();
// }


// Problem 8.3
// class Car {
//   String brand;
//   Car(this.brand);
// }

// class ElectricCar extends Car {
//   ElectricCar(super.brand);
// }

// void main() {
//   ElectricCar car = ElectricCar('Tesla');

//   print(car.brand);
// }


// Problem 8.4
// class Shape {
//   void showShape() {
//     print('This is a shape');
//   }
// }

// class Polygon extends Shape {
//   void showPolygon() {
//     print('This is a polygon');
//   }
// }

// class Triangle extends Polygon {
//   void showTriangle() {
//     print('This is a triangle');
//   }
// }

// void main() {
//   Triangle triangle = Triangle();

//   triangle.showShape();
//   triangle.showPolygon();
//   triangle.showTriangle();
// }


// Problem 8.5
// abstract class Animal {
//   void eat() {
//     print("Animal is eating");
//   }
//   void sound();
// }

// class Dog extends Animal {
//   @override
//   void sound() {
//     print("Dog barks");
//   }
// }

// void main() {
//   Dog dog = Dog();
//   dog.eat();
//   dog.sound();
// }


// Problem 8.6
// final class Animal {
//   void sound() {
//     print("Animal sound");
//   }
// }

// void main() {
//   Animal animal = Animal();
//   animal.sound();
// }


// Problem 9.2
// abstract interface class DBConnector {
//   void connect();
//   void disconnect();
// }

// class MySQLConnector implements DBConnector {
//   @override
//   void connect() {
//     print('Connected to MySQL');
//   }

//   @override
//   void disconnect() {
//     print('Disconnected from MySQL');
//   }
// }

// void main() {
//   MySQLConnector database = MySQLConnector();

//   database.connect();
//   database.disconnect();
// }

// Problem 9.3
// mixin Flyable {
//   void fly() {
//     print('The bird is flying');
//   }
// }

// class Bird with Flyable {
// }

// void main() {
//   Bird bird = Bird();
//   bird.fly();
// }


// Problem 9.4
// mixin Walker {
//   void walk() {
//     print('Duck is walking');
//   }
// }

// mixin Swimmer {
//   void swim() {
//     print('Duck is swimming');
//   }
// }

// mixin Flyable {
//   void fly() {
//     print('Duck is flying');
//   }
// }

// class Duck with Walker, Swimmer, Flyable {
// }

// void main() {
//   Duck duck = Duck();

//   duck.walk();
//   duck.swim();
//   duck.fly();
// }


// Problem 9.5
// class Animal {
//   void eat() {
//     print("Eating");
//   }
// }

// mixin Fly on Animal {
//   void fly() {
//     print("Flying");
//   }
// }

// class Bird extends Animal with Fly {
// }

// void main() {
//   Bird bird = Bird();
//   bird.eat();
//   bird.fly();
// }


// Problem 9.6
// Implements
// abstract class Animal {
//   void sound();
// }

// class Dog implements Animal {
//   @override
//   void sound() {
//     print("Dog barks");
//   }
// }

// void main() {
//   Dog dog = Dog();
//   dog.sound();
// }


// With
// mixin Fly {
//   void fly() {
//     print("Flying");
//   }
// }

// class Bird with Fly {
// }

// void main() {
//   Bird bird = Bird();
//   bird.fly();
// }



// Problem 10.2
// abstract class Shape {
//   double area();
// }

// class Circle extends Shape {
//   double radius;
//   Circle(this.radius);

//   @override
//   double area() {
//     return 3.14 * radius * radius;
//   }
// }

// class Rectangle extends Shape {
//   double width;
//   double height;
//   Rectangle(this.width, this.height);

//   @override
//   double area() {
//     return width * height;
//   }
// }

// void main() {
//   List<Shape> shapes = [
//     Circle(5),
//     Rectangle(4, 6),
//   ];

//   for (Shape shape in shapes) {
//     print(shape.area());
//   }
// }



// Problem 10.3
// class Animal {
//   void eat() {
//     print('Animal is eating');
//   }
// }

// class Dog extends Animal {
//   void bark() {
//     print('Dog is barking');
//   }
// }

// void main() {
//   Animal animal = Dog();
//   if (animal is Dog) {
//     print('The animal is a Dog');
//   }

//   Dog dog = animal as Dog;
//   dog.bark();
// }


// Problem 10.4
// class Repository<T> {
//   List<T> items = [];

//   void add(T item) {
//     items.add(item);
//   }

//   void showAll() {
//     for (T item in items) {
//       print(item);
//     }
//   }
// }

// void main() {
//   Repository<String> names = Repository<String>();
//   names.add('Alice');
//   names.add('Bob');
//   names.showAll();

//   Repository<int> numbers = Repository<int>();
//   numbers.add(10);
//   numbers.add(20);
//   numbers.showAll();
// }


// Problem 10.5
// sealed class Shape {}
// class Circle extends Shape {}
// class Square extends Shape {}

// String getShape(Shape shape) {
//   return switch (shape) {
//     Circle() => "Circle",
//     Square() => "Square",
//   };
// }

// void main() {
//   Shape shape = Circle();
//   print(getShape(shape));
// }


// Problem 10.6
// abstract class Payment {
//   void pay();
// }

// class CashPayment implements Payment {
//   @override
//   void pay() {
//     print("Paying with cash");
//   }
// }

// class CardPayment implements Payment {
//   @override
//   void pay() {
//     print("Paying with card");
//   }
// }

// class Shop {
//   final Payment payment;
//   Shop(this.payment);
//   void checkout() {
//     payment.pay();
//   }
// }

// void main() {
//   Shop shop = Shop(CardPayment());
//   shop.checkout();
// }


// Problem 11.2
// Future<String> getUserData() async {
//   await Future.delayed(Duration(seconds: 2));
//   return 'User: Davron, Age: 20';
// }

// void main() async {
//   print('Looking up user...');
//   String user = await getUserData();
//   print(user);
// }


// Problem 11.3
// Future<String> task1() async {
//   await Future.delayed(Duration(seconds: 2));
//   return "Task 1 completed";
// }

// Future<String> task2() async {
//   await Future.delayed(Duration(seconds: 1));
//   return "Task 2 completed";
// }

// Future<String> task3() async {
//   await Future.delayed(Duration(seconds: 3));
//   return "Task 3 completed";
// }

// void main() async {
//   List<String> results = await Future.wait([
//     task1(),
//     task2(),
//     task3(),
//   ]);

//   print(results);
// }


// Problem 11.4
// import 'dart:async';
// void main() {
//   int count = 0;
//   StreamSubscription? subscription;
//   subscription = Stream.periodic(
//     Duration(seconds: 1),
//     (value) => value,
//   ).listen((value) {
//     print("Tick: $value");
//     count++;
//     if (count == 5) {
//       subscription?.cancel();
//       print("Stream cancelled");
//     }
//   });
// }


// Problem 11.5
// void main() {
//   Stream<int>.fromIterable([1, 2, 2, 3, 4, 4, 5])
//       .map((value) => value * 2)
//       .where((value) => value > 4)
//       .distinct()
//       .listen((value) {
//     print(value);
//   });
// }


// Problem 11.6
// Stream<int> getNumbers() async* {
//   yield 1;
//   yield 2;
//   throw Exception("Something went wrong");
// }

// void main() {
//   getNumbers()
//       .handleError((error) {
//         print("Error: $error");
//       })
//       .listen((value) {
//         print("Value: $value");
//       });
// }


// Problem 12.2
// double divide(double a, double b) {
//   try {
//     if (b == 0) {
//       throw UnsupportedError("Cannot divide by zero");
//     }

//     return a / b;
//   } on UnsupportedError catch (e) {
//     print(e);
//     return 0;
//   }
// }

// void main() {
//   print(divide(10, 2));
//   print(divide(10, 0));
// }


// Problem 12.3
// void checkName(String? name) {
//   if (name == null || name.isEmpty) {
//     throw ArgumentError("Name cannot be empty or null");
//   }

//   print("Name: $name");
// }

// void main() {
//   checkName("Ali");
// }


// Problem 12.4
// void main() {
//   try {
//     int result = 10 ~/ 0;
//     print(result);
//   } on IntegerDivisionByZeroException {
//     print("Cannot divide by zero");
//   } catch (e) {
//     print("Unknown error: $e");
//   }
// }


// Problem 12.5
// void main() {
//   try {
//     int result = 10 ~/ 0;
//     print(result);
//   } catch (e, stackTrace) {
//     print("Error: $e");
//     print("Stack trace:");
//     print(stackTrace);
//   }
// }


// Problem 12.6
// void test() {
//   try {
//     int result = 10 ~/ 0;
//     print(result);
//   } catch (e) {
//     print("Error caught");
//     rethrow;
//   }
// }

// void main() {
//   try {
//     test();
//   } catch (e) {
//     print("Error received in main: $e");
//   }
// }
