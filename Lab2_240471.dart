// Problem 1.1
// void main (List <String > arguments ) {
//     print ('Hello , Dart World !');
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     }
// }


// Problem 1.2
// void main (List <String > arguments ) {
//     print ('Abidov Davron \nStudent ID: 240471 \nMajor: Computer Science \n');
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     }
// }


// Problem 1.3
// void main (List <String > arguments ) {
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     }
//     var count = arguments.length;
//     print ('Number of arguments: ${count}');
// }


// Problem 1.4
// void main (List <String > arguments ) {
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     double sum = 0;

//     for (String arg in arguments) {
//         sum += double.parse(arg);
//     }
//     double average = sum / arguments.length;
//     print('Average: ${average}');
// }


// Problem 1.5
// void main (List <String > arguments ) {
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     }

//     if (arguments.length != 2) {
//         print('More than 2 arguments');
//         return;
//     }
// }


// Problem 1.6
// import 'dart:io';
// void main (List <String > arguments ) {
//     if ( arguments.isNotEmpty ) {
//         print ('Command line arguments passed : ${ arguments . join (", ")}');  
//     }
//     if (arguments.length != 2) {
//         print('More than 2 arguments');
//         exitCode = 1;
//         return;
//     }

//     print('First argument: ${arguments[0]}');
//     print('Second argument: ${arguments[1]}');
//     print('Arguments are valid.');
//     exitCode = 0;
// }


// Problem 2.1
// void main() {
//   var mutableName = 'Alice';
//   final String birthCity = 'Tashkent';
//   const double pi = 3.14159;
//   late String lazyDescription;

//   lazyDescription = 'Initialized later!';

//   print(
//     '$mutableName born in $birthCity. Math constant: $pi. Status: $lazyDescription',
//   );
// }


// Problem 2.2
// void main() {
//   int age = 20;
//   double gpa = 4.5;
//   String country = 'Uzbekistan';
//   bool isStudent = true;

//   print('Age: $age');
//   print('GPA: $gpa');
//   print('Country: $country');
//   print('Is student: $isStudent');
// }


// Problem 2.3
// void main() {
//   final currentTime = DateTime.now();
//   print('Current time: $currentTime');

//   const String dateOfInitializetion = '21:54 20/09/2026';
//   print('Const: $dateOfInitializetion');
// }




// Problem 2.4
// void main() {
//   String? phoneNumber;
//   String phone = phoneNumber ?? 'No phone number provided';
//   print('Phone: $phone');
//   phoneNumber = '+998 99 999 99 99';
//   phone = phoneNumber ?? 'No phone number provided';

//   print('Phone: $phone');
// }



// Problem 2.5
// void main() {
//   dynamic value = 'Hello';
//   if (value is String) {
//     print('The value is a String.');
//   }

//   value = 42;
//   if (value is int) {
//     print('The value is an integer.');
//   }
// }



// Problem 2.6
// void main() {
//   var coordinate = (10, 20, 30);

//   print('X: ${coordinate.$1}');
//   print('Y: ${coordinate.$2}');
//   print('Z: ${coordinate.$3}');
// }


// Problem 2.7
// typedef UserProfile = Map<String, dynamic>;

// void main() {
//   UserProfile user = {
//     'name': 'Davron',
//     'age': 20,
//     'country': 'Uzbekistan',
//     'isStudent': true,
//     'address': {
//       'city': 'Tashkent',
//       'street': 'University Street',
//     },
//   };

//   print('Name: ${user['name']}');
//   print('Age: ${user['age']}');
//   print('Country: ${user['country']}');
//   print('Student: ${user['isStudent']}');

//   print('City: ${(user['address'] as Map<String, dynamic>)['city']}');
// }


// Problem 3.1
// void main () {
//     int score = 85;
//     String grade = switch ( score ) {
//         >= 90 => 'A',
//         >= 80 => 'B',
//         >= 70 => 'C',
//         _ => 'F'
//     };
//     print ('Grade achieved : $grade ');
// }


// Problem 3.2
// void main () {
//     int score = 85;
//     if ( score > 0 ){
//         print('Number is positive');
//     }else if( score < 0 ){
//         print('Number is negative');
//     }else{
//         print('Number is zero');
//     }
// }


// Problem 3.3
// void main() {
//   int num = 5;
//   int factorial = 1;
//   for (int i = 1; i <= num; i++) {
//     factorial = factorial * i;
//   }
//   print(factorial);


//   factorial = 1;
//   List<int> numbers = [1, 2, 3, 4, 5];
//   for (int i in numbers) {
//     factorial = factorial * i;
//   }
//   print(factorial);
// }


// Problem 3.4
// void main() {
//   int target = 5;
//   int guess = 1;
//   while (true) {
//     print('Guess: $guess');
//     if (guess == target) {
//       print('You guessed it!');
//       break;
//     }
//     guess++;
//   }
// }


// Problem 3.5
// break
// void main() {
//   for (int i = 1; i <= 3; i++) {
//     for (int j = 1; j <= 3; j++) {
//       if (j == 2) {
//         break;
//       }
//       print('$i $j');
//     }
//   }
// }

// continue
// void main() {
//   for (int i = 1; i <= 2; i++) {
//     for (int j = 1; j <= 3; j++) {
//       if (j == 2) {
//         continue;
//       }
//       print('$i $j');
//     }
//   }
// }


// Problem 4.1
// double calculateTotal(
//   double price, {
//   double discount = 0.0,
//   double tax = 0.08,
// }) {
//   double discounted = price * (1 - discount);
//   return discounted * (1 + tax);
// }

// void main() {
//   print(
//     'Total: \$${calculateTotal(100.0, discount: 0.15).toStringAsFixed(2)}',
//   );
// }


// Problem 4.2
// bool isEven(int n) => n % 2 == 0;
// void main() {
//   print(isEven(4));
// }


// Problem 4.3
// String formatName(String name, [String? prefix, String? suffix]) {
//   return '${prefix ?? ''}$name${suffix ?? ''}';
// }
// void main() {
//   print(formatName('John', 'Mr. ', ' Jr.'));
// }


// Problem 4.5
// int fibonacci(int n) {
//   if (n <= 1) {
//     return n;
//   }
//   return fibonacci(n - 1) + fibonacci(n - 2);
// }
// void main() {
//   print(fibonacci(6));
// }


// Problem 4.6
// void main() {
//   int counter = 0;

//   var count = () {
//     counter++;
//     return counter;
//   };
  
//   print(count());
//   print(count());
//   print(count());
// }
