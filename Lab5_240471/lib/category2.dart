import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Category 2 - Named routes.
class Category2MenuScreen extends StatelessWidget {
  const Category2MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 2'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.table_rows),
            title: const Text('Task 2.1 - Route table and pushNamed'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.task2_1Home),
          ),
          ListTile(
            leading: const Icon(Icons.menu),
            title: const Text('Task 2.2 - Menu with four routes'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.menuHome),
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('Task 2.3 - Page not found'),
            subtitle: const Text('Opens a route that is not registered'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/does-not-exist'),
          ),
        ],
      ),
    );
  }
}

// TASK 2.1
class Task_2_1_HomeScreen extends StatelessWidget {
  const Task_2_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The screens know each other's route names, not each other's classes.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2.1 - Home'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Settings'),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.task2_1Settings),
        ),
      ),
    );
  }
}

class Task_2_1_SettingsScreen extends StatelessWidget {
  const Task_2_1_SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Back'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

// TASK 2.2
class Task_2_2_HomeScreen extends StatelessWidget {
  const Task_2_2_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2.2 - Menu'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Open profile screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            subtitle: const Text('Open messages screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Open about screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

class Task_2_2_ProfileScreen extends StatelessWidget {
  const Task_2_2_ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Profile Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Task_2_2_MessagesScreen extends StatelessWidget {
  const Task_2_2_MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.markunread, size: 100, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Messages Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Task_2_2_AboutScreen extends StatelessWidget {
  const Task_2_2_AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 100, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'About Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// TASK 2.3
class Task_2_3_NotFoundScreen extends StatelessWidget {
  const Task_2_3_NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 - Page Not Found'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Sorry, this page does not exist.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
