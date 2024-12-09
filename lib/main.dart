import 'package:flutter/material.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, List<Map<String, dynamic>>> tasksByCategory = {
    'My ToDo': [], // Default category
  };
  String currentCategory = 'My ToDo'; // Tracks the current active category

  void _addCategory(String categoryName) {
    if (categoryName.isNotEmpty && !tasksByCategory.containsKey(categoryName)) {
      setState(() {
        tasksByCategory[categoryName] = [];
      });
    }
  }

  void _addTask(String taskName) {
    setState(() {
    tasksByCategory[currentCategory]!.insert(0, {
      'title': taskName,
      'completed': false,
    });
  });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasksByCategory[currentCategory]![index]['completed'] =
          !tasksByCategory[currentCategory]![index]['completed'];

      List<Map<String, dynamic>> updatedTasks = List.from(tasksByCategory[currentCategory]!);
      updatedTasks.sort((a, b) => a['completed'] ? 1 : -1);
      tasksByCategory[currentCategory]!.clear();
      tasksByCategory[currentCategory]!.addAll(updatedTasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(currentCategory, style: const TextStyle(color: Color(0xFFFF4500)),)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ibrahim',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            // Add Category ListTile goes first
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Bucket'),
              onTap: () {
                _showAddCategoryDialog(context);
              },
            ),
            const Divider(),
            // Dynamically created category ListTiles go after Add Category
            ...tasksByCategory.keys.map((category) {
              return ListTile(
                title: Text(category),
                onTap: () {
                  setState(() {
                    currentCategory = category; // Switch to the selected category
                  });
                  Navigator.of(context).pop(); // Close the drawer
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: tasksByCategory[currentCategory]!.isEmpty
          ? const Center(
              child: Text(
                'No tasks added yet. Tap + to add a task.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasksByCategory[currentCategory]!.length,
              itemBuilder: (context, index) {
                bool hasNote = tasksByCategory[currentCategory]![index]['note'] != null &&
                    tasksByCategory[currentCategory]![index]['note']!.isNotEmpty;

                return ListTile(
                  title: Text(
                    tasksByCategory[currentCategory]![index]['title'],
                    style: TextStyle(
                      color: tasksByCategory[currentCategory]![index]['completed']
                          ? Colors.grey
                          : Colors.black,
                      decoration: tasksByCategory[currentCategory]![index]['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display checkmark icon for completion toggle
                      IconButton(
                        icon: Icon(
                          tasksByCategory[currentCategory]![index]['completed']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: tasksByCategory[currentCategory]![index]['completed']
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleTaskCompletion(index); // Toggling task completion
                        },
                      ),
                      // Display note icon if task has a note
                      if (hasNote)
                        const Icon(
                          Icons.description,
                          color: Colors.lightBlue,
                        ),
                    ],
                  ),
                  onTap: () {
                    _showBottomSheet(context, index); // Showing bottom sheet for task options
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    String categoryName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter category name'),
            onChanged: (value) {
              categoryName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryName.isNotEmpty) {
                  _addCategory(categoryName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String taskName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter task name'),
            onChanged: (value) {
              taskName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (taskName.isNotEmpty) {
                  _addTask(taskName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, int index) {
    String note = tasksByCategory[currentCategory]![index]['note'] ?? ''; // Initialize note with current task's note
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: note), // Set the initial value of the note
              decoration: const InputDecoration(
                labelText: 'Add a Note',
              ),
              onChanged: (value) {
                note = value; // Update the note variable when the user types
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tasksByCategory[currentCategory]![index]['note'] = note; // Save the updated note to the task
                    });
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('Save Note'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tasksByCategory[currentCategory]!.removeAt(index); // Delete the task
                    });
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
