import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'category1.dart';
import 'category2.dart';
import 'category3.dart';
import 'category4.dart';
import 'category5.dart';

void main() => runApp(const Lab5App());

class Lab5App extends StatelessWidget {
  const Lab5App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 5 - Navigation',
      debugShowCheckedModeBanner: false,
      home: const CategoryMenuScreen(),
      routes: {
        // CATEGORY 2
        AppRoutes.task2_1Home: (context) => const Task_2_1_HomeScreen(),
        AppRoutes.task2_1Settings: (context) => const Task_2_1_SettingsScreen(),
        AppRoutes.menuHome: (context) => const Task_2_2_HomeScreen(),
        AppRoutes.profile: (context) => const Task_2_2_ProfileScreen(),
        AppRoutes.messages: (context) => const Task_2_2_MessagesScreen(),
        AppRoutes.about: (context) => const Task_2_2_AboutScreen(),

        // CATEGORY 4
        AppRoutes.details: (context) => const Task_4_1_DetailsScreen(),
        AppRoutes.square: (context) => const Task_4_2_SquareScreen(),
        AppRoutes.userProfile: (context) => const Task_4_3_ProfileScreen(),
      },
      // Task 2.3
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Task_2_3_NotFoundScreen(),
      ),
    );
  }
}

class CategoryMenuScreen extends StatelessWidget {
  const CategoryMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 5 - Navigation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Category 1 - Navigator: push and pop'),
            subtitle: const Text('Tasks 1.1 - 1.3'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Category1MenuScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Category 2 - Named routes'),
            subtitle: const Text('Tasks 2.1 - 2.3'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Category2MenuScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Category 3 - Constructor arguments'),
            subtitle: const Text('Tasks 3.1 - 3.3'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Category3MenuScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.alt_route),
            title: const Text('Category 4 - Named-route arguments'),
            subtitle: const Text('Tasks 4.1 - 4.3'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Category4MenuScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.animation),
            title: const Text('Category 5 - Transitions'),
            subtitle: const Text('Tasks 5.1 - 5.3'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Category5MenuScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.route),
            title: Text('Category 6 - go_router'),
            subtitle: Text(
              'Drives MaterialApp.router, so it cannot open from here. '
              'Run it with "flutter run -t lib/category6.dart".',
            ),
          ),
        ],
      ),
    );
  }
}
