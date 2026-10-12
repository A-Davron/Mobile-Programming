import 'package:flutter/material.dart';
class AppRoutes {
  static const home = '/task2_1';
  static const settings = '/task2_1/settings';
  
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Task_1_3_LoginScreen(),
      routes: {
        AppRoutes.home: (context) => const Task_2_1_HomeScreen(),
        AppRoutes.settings: (context) => const Task_2_1_SettingsScreen(),
      },
    ),
  );
}

// TASK 1.1
class Task_1_1_HomeScreen extends StatelessWidget {
  const Task_1_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Open details'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Task_1_1_DetailsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text('Open Task 1.2: Screens A, B, C'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Task_1_2_ScreenA(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text('Open Task 2.1: Named Routes'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.home,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class Task_1_1_DetailsScreen extends StatelessWidget {
  const Task_1_1_DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

// TASK 1.2
class Task_1_2_ScreenA extends StatelessWidget {
  const Task_1_2_ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen A'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Next'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_2_ScreenB(),
              ),
            );
          },
        ),
      ),
    );
  }
}


class Task_1_2_ScreenB extends StatelessWidget {
  const Task_1_2_ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen B'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Next'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_2_ScreenC(),
              ),
            );
          },
        ),
      ),
    );
  }
}


class Task_1_2_ScreenC extends StatelessWidget {
  const Task_1_2_ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen C'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}


// TASK 1.3
class Task_1_3_LoginScreen extends StatelessWidget {
  const Task_1_3_LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_1_HomeScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}


// TASK 2.1
class Task_2_1_HomeScreen extends StatelessWidget {
  const Task_2_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2.1 - Home'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Settings'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.settings,
            );
          },
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
