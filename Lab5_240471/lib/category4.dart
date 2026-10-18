import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Category 4 - Passing arguments with named routes.
class Category4MenuScreen extends StatelessWidget {
  const Category4MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 4'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Task 4.1 - ScreenArguments class'),
            subtitle: const Text('Pack a title and a message in one class'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_4_1_HomeScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Task 4.2 - Send a number'),
            subtitle: const Text('Pass a plain int and show its square'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_4_2_HomeScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Task 4.3 - User profile'),
            subtitle: const Text('Pass a User object to a named route'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_4_3_UserListScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TASK 4.1
class ScreenArguments {
  final String title;
  final String message;
  const ScreenArguments(this.title, this.message);
}

class Task_4_1_HomeScreen extends StatelessWidget {
  const Task_4_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 4.1 - Home'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Send arguments'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.details,
              arguments: const ScreenArguments('Welcome', 'Sent from Home'),
            );
          },
        ),
      ),
    );
  }
}

class Task_4_1_DetailsScreen extends StatelessWidget {
  const Task_4_1_DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The arguments are read inside build, from this screen's own context.
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return Scaffold(
      appBar: AppBar(title: Text(args.title), backgroundColor: Colors.teal),
      body: Center(child: Text(args.message)),
    );
  }
}

// TASK 4.2
class Task_4_2_HomeScreen extends StatelessWidget {
  const Task_4_2_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 4.2 - Pick a number'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('1'),
              onPressed: () {
                // A plain int is a valid argument on its own.
                Navigator.pushNamed(context, AppRoutes.square, arguments: 1);
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              child: const Text('2'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.square, arguments: 2);
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              child: const Text('3'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.square, arguments: 3);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Task_4_2_SquareScreen extends StatelessWidget {
  const Task_4_2_SquareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final number = ModalRoute.of(context)!.settings.arguments as int;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Square'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Text(
          '$number squared is ${number * number}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// TASK 4.3
class User {
  final String name;
  final int age;
  final String city;
  const User(this.name, this.age, this.city);
}

const users = [
  User('Alice Brown', 21, 'London'),
  User('Bobur Karimov', 20, 'Tashkent'),
  User('Clara Diaz', 23, 'Madrid'),
  User('Dmitry Orlov', 22, 'Prague'),
];

class Task_4_3_UserListScreen extends StatelessWidget {
  const Task_4_3_UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          for (final u in users)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(u.name),
              subtitle: Text(u.city),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.userProfile,
                  arguments: u,
                );
              },
            ),
        ],
      ),
    );
  }
}

class Task_4_3_ProfileScreen extends StatelessWidget {
  const Task_4_3_ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(title: Text(user.name), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(user.name),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Age'),
              subtitle: Text('${user.age}'),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('City'),
              subtitle: Text(user.city),
            ),
          ],
        ),
      ),
    );
  }
}
