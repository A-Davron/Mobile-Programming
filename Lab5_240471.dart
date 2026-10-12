import 'package:flutter/material.dart';
class AppRoutes {
  // Task 2.2
  static const menuHome = '/home2_2';
  static const profile = '/profile';
  static const messages = '/messages';
  static const about = '/about';

  // Task 2.1
  static const home = '/task2_1';
  static const settings = '/task2_1/settings';
}


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Task_1_3_LoginScreen(),
      routes: {
        // TASK 2.1
        AppRoutes.home: (context) => const Task_2_1_HomeScreen(),
        AppRoutes.settings: (context) => const Task_2_1_SettingsScreen(),

        // TASK 2.2
        AppRoutes.menuHome: (context) => const Task_2_2_HomeScreen(),
        AppRoutes.profile: (context) => const Task_2_2_ProfileScreen(),
        AppRoutes.messages: (context) => const Task_2_2_MessagesScreen(),
        AppRoutes.about: (context) => const Task_2_2_AboutScreen(),
      },
      // TASK 2.3
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Task_2_3_NotFoundScreen(),
      ),
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
            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text('Task 2.3 - Test 404 Page'),
              onPressed: () {
                Navigator.pushNamed(context, '/does-not-exist');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First button: Task 1.1 Home Screen
            ElevatedButton(
              child: const Text('Sign in - Task 1.1'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Task_1_1_HomeScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Second button: Task 2.2 Home Screen
            ElevatedButton(
              child: const Text('Sign in - Task 2.2'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Task_2_2_HomeScreen(),
                  ),
                );
              },
            ),
          ],
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
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            subtitle: const Text('Open messages screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.messages,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Open about screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.about,
              );
            },
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
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Profile Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
            Icon(
              Icons.markunread,
              size: 100,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Messages Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
            Icon(
              Icons.info_outline,
              size: 100,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'About Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Sorry, this page does not exist.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
