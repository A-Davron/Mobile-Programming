import 'package:flutter/material.dart';

/// Category 3 - Passing arguments with constructors.
class Category3MenuScreen extends StatelessWidget {
  const Category3MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 3'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Task 3.1 - Product list'),
            subtitle: const Text('Pass a Product to the details screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_3_1_ProductListScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand),
            title: const Text('Task 3.2 - Greeting'),
            subtitle: const Text('Pass a typed name to the next screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_3_2_NameScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Task 3.3 - Contact card'),
            subtitle: const Text('Pass a whole Contact object'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Task_3_3_ContactListScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TASK 3.1
class Product {
  final String name;
  final double price;
  const Product(this.name, this.price);
}

const products = [
  Product('Laptop', 999.0),
  Product('Phone', 599.5),
  Product('Headphones', 79.9),
];

class Task_3_1_ProductListScreen extends StatelessWidget {
  const Task_3_1_ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          for (final p in products)
            ListTile(
              title: Text(p.name),
              subtitle: Text('\$${p.price}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Task_3_1_ProductScreen(product: p),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class Task_3_1_ProductScreen extends StatelessWidget {
  const Task_3_1_ProductScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name), backgroundColor: Colors.teal),
      body: Center(
        child: Text(
          'Price: \$${product.price}',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

// TASK 3.2
class Task_3_2_NameScreen extends StatefulWidget {
  const Task_3_2_NameScreen({super.key});

  @override
  State<Task_3_2_NameScreen> createState() => _Task_3_2_NameScreenState();
}

class _Task_3_2_NameScreenState extends State<Task_3_2_NameScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your name'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Greet'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Task_3_2_GreetingScreen(name: controller.text),
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

class Task_3_2_GreetingScreen extends StatelessWidget {
  const Task_3_2_GreetingScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greeting'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Hello, $name!', style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// TASK 3.3
class Contact {
  final String name;
  final String phone;
  final String email;
  const Contact(this.name, this.phone, this.email);
}

const contacts = [
  Contact('Alice Brown', '+998 90 111 22 33', 'alice@example.com'),
  Contact('Bobur Karimov', '+998 90 222 33 44', 'bobur@example.com'),
  Contact('Clara Diaz', '+998 90 333 44 55', 'clara@example.com'),
  Contact('Dmitry Orlov', '+998 90 444 55 66', 'dmitry@example.com'),
  Contact('Elena Petrova', '+998 90 555 66 77', 'elena@example.com'),
];

class Task_3_3_ContactListScreen extends StatelessWidget {
  const Task_3_3_ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          for (final c in contacts)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(c.name),
              subtitle: Text(c.phone),
              onTap: () {
                // The whole object travels, not three separate strings.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Task_3_3_ContactScreen(contact: c),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class Task_3_3_ContactScreen extends StatelessWidget {
  const Task_3_3_ContactScreen({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(contact.phone),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(contact.email),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
