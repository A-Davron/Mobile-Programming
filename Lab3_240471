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
