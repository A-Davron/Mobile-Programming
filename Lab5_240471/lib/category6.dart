import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'category3.dart' show Product, products;

/// Category 6 of Lab 5: go_router.
///
/// go_router drives `MaterialApp.router`, which replaces the `MaterialApp` of
/// the other categories instead of sitting inside it, so Category 6 lives in
/// its own entry point:
///
///     flutter run -t lib/category6.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Task_6_1_HomeScreen(),
    ),

    // TASK 6.1
    GoRoute(
      path: '/details',
      builder: (context, state) => const Task_6_1_DetailsScreen(),
    ),

    // TASK 6.2
    GoRoute(
      path: '/product/:id',
      builder: (context, state) =>
          Task_6_2_ProductScreen(id: state.pathParameters['id']!),
    ),

    // TASK 6.3
    GoRoute(
      path: '/product-list',
      builder: (context, state) => const Task_6_3_ProductListScreen(),
    ),
    GoRoute(
      path: '/product-details',
      builder: (context, state) =>
          Task_6_3_ProductScreen(product: state.extra! as Product),
    ),
  ],
);

void main() => runApp(
  MaterialApp.router(debugShowCheckedModeBanner: false, routerConfig: router),
);

// TASK 6.1
class Task_6_1_HomeScreen extends StatelessWidget {
  const Task_6_1_HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('go_router - Home'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // go replaces the stack, so Details opens without a back arrow.
            ElevatedButton(
              onPressed: () => context.go('/details'),
              child: const Text('Task 6.1 - go (replace stack)'),
            ),
            const SizedBox(height: 12),
            // push adds to the stack, so the back arrow and pop both work.
            ElevatedButton(
              onPressed: () => context.push('/details'),
              child: const Text('Task 6.1 - push (add to stack)'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // TASK 6.2 - the id travels inside the path itself.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/product/1'),
                  child: const Text('Product 1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.push('/product/2'),
                  child: const Text('Product 2'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.push('/product/3'),
                  child: const Text('Product 3'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // TASK 6.3
            ElevatedButton(
              onPressed: () => context.push('/product-list'),
              child: const Text('Task 6.3 - Pass a Product with extra'),
            ),
          ],
        ),
      ),
    );
  }
}

class Task_6_1_DetailsScreen extends StatelessWidget {
  const Task_6_1_DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // This is the difference between go and push. After push there is
            // a screen underneath, so pop works. After go there is not, and
            // calling pop throws GoError: There is nothing to pop. A null
            // onPressed disables the button instead.
            ElevatedButton(
              onPressed: context.canPop() ? () => context.pop() : null,
              child: const Text('pop'),
            ),
            const SizedBox(height: 12),
            // So there is always a way back, even after go.
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('go home'),
            ),
          ],
        ),
      ),
    );
  }
}

// TASK 6.2
class Task_6_2_ProductScreen extends StatelessWidget {
  const Task_6_2_ProductScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product #$id'), backgroundColor: Colors.teal),
      body: Center(
        child: Text('Product #$id', style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// TASK 6.3
class Task_6_3_ProductListScreen extends StatelessWidget {
  const Task_6_3_ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          for (final p in products)
            ListTile(
              title: Text(p.name),
              subtitle: Text('\$${p.price}'),
              // extra carries the object itself, so it is not part of the
              // URL. On the web a page refresh loses it, while a path
              // parameter like /product/2 survives one.
              onTap: () => context.push('/product-details', extra: p),
            ),
        ],
      ),
    );
  }
}

class Task_6_3_ProductScreen extends StatelessWidget {
  const Task_6_3_ProductScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name), backgroundColor: Colors.green),
      body: Center(
        child: Text(
          'Price: \$${product.price}',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
