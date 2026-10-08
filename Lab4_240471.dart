import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

ListTile _tile(BuildContext context, String title, Widget screen) {
  return ListTile(
    title: Text(title),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 4')),
      body: ListView(
        children: [
          _tile(context, 'Task 1: Settings', const SettingsScreen()),
          _tile(context, 'Task 2: Login', const LoginScreen()),
          _tile(context, 'Task 3: Counter', const CounterScreen()),
          _tile(context, 'Task 4: Progress', const ProgressScreen()),
          _tile(context, 'Task 5: Dialogs', const DialogScreen()),
          _tile(context, 'Task 6: Slider & Date', const SliderScreen()),
          _tile(context, 'Task 7: List', const ListScreen()),
          _tile(context, 'Task 8: Grid', const GridScreen()),
          _tile(context, 'Task 9.1: Bottom Nav', const BottomNavScreen()),
          _tile(context, 'Task 9.2: Tabs', const TabsScreen()),
        ],
      ),
    );
  }
}


// Task 1: Checkbox & Switch
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkMode,
            onChanged: (value) => setState(() => darkMode = value),
          ),
          CheckboxListTile(
            title: const Text('Agree to Terms'),
            value: agreed,
            onChanged: (value) => setState(() => agreed = value!),
          ),
          ElevatedButton(
            // null disables the button
            onPressed: agreed ? () {} : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}


// Task 2: TextFormField
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.contains('@') ? null : 'Email must contain @',
              ),
              TextFormField(
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a password' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged in')),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Task 3: FloatingActionButton & OutlinedButton
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count', style: const TextStyle(fontSize: 48)),
            OutlinedButton(
              onPressed: () => setState(() => count = 0),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}


// Task 4: CircularProgressIndicator & SnackBar
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool loading = false;

  Future<void> load() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Done'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: load,
                child: const Text('Load'),
              ),
      ),
    );
  }
}


// Task 5: AlertDialog & showModalBottomSheet
class DialogScreen extends StatelessWidget {
  const DialogScreen({super.key});

  void showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy link'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Message'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialogs')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => showDeleteDialog(context),
              child: const Text('Delete item'),
            ),
            ElevatedButton(
              onPressed: () => showShareSheet(context),
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }
}


// Task 6: Slider & showDatePicker
class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  double volume = 50;
  DateTime? date;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider & Date')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Volume: ${volume.round()}%'),
            Slider(
              value: volume,
              max: 100,
              onChanged: (value) => setState(() => volume = value),
            ),
            const SizedBox(height: 16),
            Text(date == null
                ? 'No date selected'
                : '${date!.day}/${date!.month}/${date!.year}'),
            ElevatedButton(
              onPressed: pickDate,
              child: const Text('Pick date'),
            ),
          ],
        ),
      ),
    );
  }
}


// Task 7: ListView.builder & Dismissible
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final items = List.generate(20, (i) => 'Item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Dismissible(
            key: Key(item),
            background: Container(color: Colors.red),
            onDismissed: (direction) => setState(() => items.remove(item)),
            child: ListTile(
              leading: const Icon(Icons.label),
              title: Text(item),
            ),
          );
        },
      ),
    );
  }
}


// Task 8: GridView.count & InkWell
class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid')),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        children: List.generate(10, (index) {
          // Coloured boxes stand in for images, so no assets are needed.
          final color = Colors.primaries[index % Colors.primaries.length];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PreviewScreen(color: color, index: index),
              ),
            ),
            child: Container(
              color: color,
              child: Center(child: Text('${index + 1}')),
            ),
          );
        }),
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.color, required this.index});

  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image ${index + 1}')),
      body: Container(color: color),
    );
  }
}


// Task 9.1: BottomNavigationBar
class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int index = 0;

  static const pages = [
    Center(child: Text('Home')),
    Center(child: Text('Search')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Nav')),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


// Task 9.2: TabBar & TabBarView
class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'One'),
              Tab(text: 'Two'),
              Tab(text: 'Three'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Tab One')),
            Center(child: Text('Tab Two')),
            Center(child: Text('Tab Three')),
          ],
        ),
      ),
    );
  }
}
