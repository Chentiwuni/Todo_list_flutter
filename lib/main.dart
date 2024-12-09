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
  
  void _onReorder(int oldIndex, int newIndex) {
  setState(() {
    if (oldIndex < newIndex) {
      newIndex -= 1; // Adjust for the removal of the original index
    }
    final task = tasksByCategory[currentCategory]!.removeAt(oldIndex);
    tasksByCategory[currentCategory]!.insert(newIndex, task);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Ensures the title is centered within the AppBar
        title: Text(
          currentCategory,
          style: const TextStyle(
            color: Color(0xFFFF4500),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
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
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Bucket'),
              onTap: () {
                _showAddCategoryDialog(context);
              },
            ),
            const Divider(),
            ...tasksByCategory.keys.map((category) {
              return ListTile(
                title: Text(category),
                onTap: () {
                  setState(() {
                    currentCategory = category;
                  });
                  Navigator.of(context).pop();
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
          : ReorderableListView(
              padding: const EdgeInsets.all(16.0),
              onReorder: (oldIndex, newIndex) {
                _onReorder(oldIndex, newIndex);
              },
              children: tasksByCategory[currentCategory]!
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                var task = entry.value;
                bool hasNote = task['note'] != null && task['note']!.isNotEmpty;

                return ListTile(
                  key: ValueKey(task), // Key required for reordering
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      color: task['completed'] ? Colors.grey : Colors.black,
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasNote)
                        const Icon(
                          Icons.description,
                          color: Colors.lightBlue,
                        ),
                      IconButton(
                        icon: Icon(
                          task['completed']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task['completed'] ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleTaskCompletion(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showBottomSheet(context, index);
                  },
                );
              }).toList(),
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
    String taskTitle = tasksByCategory[currentCategory]![index]['title'];
    String note = tasksByCategory[currentCategory]![index]['note'] ?? ''; // Initialize note with current task's note

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Task title centered
            Text(
              taskTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            // Add Note text field centered
            TextField(
              controller: TextEditingController(text: note), // Set the initial value of the note
              decoration: const InputDecoration(
                labelText: 'Add a Note',
              ),
              onChanged: (value) {
                note = value; // Update the note variable when the user types
              },
              textAlign: TextAlign.center, // Center the text inside the field
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Normal Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(), // Normal rectangular shape
                    minimumSize: const Size(100, 40), // Set minimum size for consistent button height
                  ),
                  onPressed: () {
                    setState(() {
                      tasksByCategory[currentCategory]![index]['note'] = note; // Save the updated note to the task
                    });
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('Save Note'),
                ),
                // Normal Delete Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const RoundedRectangleBorder(), // Normal rectangular shape
                    minimumSize: const Size(100, 40), // Set minimum size for consistent button height
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the confirmation dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                setState(() {
                                  tasksByCategory[currentCategory]!.removeAt(index); // Delete the task
                                });
                                Navigator.of(context).pop(); // Close the confirmation dialog
                                Navigator.of(context).pop(); // Close the bottom sheet
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Delete Task', 
                  style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
