import 'package:flutter/material.dart';

/// Category 1 - Navigator: push and pop.
class Category1MenuScreen extends StatelessWidget {
  const Category1MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 1'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Task 1.1 - Two screens with push and pop'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_1_HomeScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Task 1.2 - Three-screen chain'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Task_1_2_ScreenA()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Task 1.3 - Replace, do not stack'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_3_LoginScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TASK 1.1
class Task_1_1_HomeScreen extends StatelessWidget {
  const Task_1_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), backgroundColor: Colors.orange),
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}

class Task_1_1_DetailsScreen extends StatelessWidget {
  const Task_1_1_DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The AppBar shows a back arrow on its own, with no extra code.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go back'),
          onPressed: () => Navigator.pop(context),
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
              MaterialPageRoute(builder: (context) => const Task_1_2_ScreenB()),
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
              MaterialPageRoute(builder: (context) => const Task_1_2_ScreenC()),
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
          // Pops one screen, so this lands back on Screen B.
          child: const Text('Back'),
          onPressed: () => Navigator.pop(context),
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
            // pushReplacement drops Login from the stack, so Home has no way
            // back to it.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_1_3_HomeScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Task_1_3_HomeScreen extends StatelessWidget {
  const Task_1_3_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), backgroundColor: Colors.teal),
      body: const Center(
        child: Text(
          'Signed in. The back arrow returns to the menu, not to Login.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
