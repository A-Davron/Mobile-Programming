import 'package:flutter/material.dart';

/// Category 5 - Simple transition animations.
class Category5MenuScreen extends StatelessWidget {
  const Category5MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 5'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TASK 5.1 - fade in over 400 ms.
            ElevatedButton(
              child: const Text('Task 5.1 - Open with fade'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Task_5_DetailsScreen(label: 'I faded in!'),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // TASK 5.2 - slide in from the right edge.
            ElevatedButton(
              child: const Text('Task 5.2 - Slide from the right'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Task_5_DetailsScreen(
                          label: 'I slid in from the right!',
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // TASK 5.3 - slide up from the bottom, eased, over 500 ms.
            ElevatedButton(
              child: const Text('Task 5.3 - Open as a sheet'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Task_5_DetailsScreen(
                          label: 'I slid up from the bottom!',
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          );
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          );
                        },
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

class Task_5_DetailsScreen extends StatelessWidget {
  const Task_5_DetailsScreen({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.pink,
      ),
      // Press back and the same animation plays in reverse.
      body: Center(child: Text(label, style: const TextStyle(fontSize: 20))),
    );
  }
}
