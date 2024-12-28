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
  final Map<String, Map<String, List<Map<String, dynamic>>>> tasksByCategory = {
    'My ToDo': {
      'uncompletedTasks': [],
      'completedTasks': [],
    },
  };
  String currentCategory = 'My ToDo'; // Tracks the current active category

  void _addCategory(String categoryName) {
    if (categoryName.isNotEmpty && !tasksByCategory.containsKey(categoryName)) {
      setState(() {
        tasksByCategory[categoryName] = {
          'uncompletedTasks': [],
          'completedTasks': [],
        };
      });
    }
  }

  void _addTask(String taskName) {
    setState(() {
      tasksByCategory[currentCategory]!['uncompletedTasks']!.insert(0, {
        'title': taskName,
        'completed': false,
        'note': '',
      });
    });
  }

  void _toggleTaskCompletion(int index, bool isCompleted) {
    setState(() {
      final task = tasksByCategory[currentCategory]![isCompleted ? 'completedTasks' : 'uncompletedTasks']!.removeAt(index);
      task['completed'] = !isCompleted;

      if (isCompleted) {
        tasksByCategory[currentCategory]!['uncompletedTasks']!.insert(0, task);
      } else {
        tasksByCategory[currentCategory]!['completedTasks']!.add(task);
      }
    });
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final task = tasksByCategory[currentCategory]!['uncompletedTasks']!.removeAt(oldIndex);
      tasksByCategory[currentCategory]!['uncompletedTasks']!.insert(newIndex, task);
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
      body: Column(
        children: [
          if (tasksByCategory[currentCategory]!['uncompletedTasks']!.isEmpty &&
              tasksByCategory[currentCategory]!['completedTasks']!.isEmpty)
            const Center(
              child: Text(
                'No tasks added yet. Tap + to add a task.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          else
            Expanded(
                            child: ReorderableListView(
                padding: const EdgeInsets.all(16.0),
                onReorder: _onReorder,
                children: tasksByCategory[currentCategory]!['uncompletedTasks']!
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final task = entry.value;

                  return ListTile(
                    key: ValueKey(task),
                    title: Text(task['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task['note'] != null && task['note']!.isNotEmpty)
                          const Icon(Icons.description, color: Colors.lightBlue),
                        IconButton(
                          icon: Icon(
                            task['completed']
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task['completed'] ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            _toggleTaskCompletion(index, false);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _showBottomSheet(context, index, false); // Show the bottom sheet
                    },
                  );
                }).toList(),
              ),

            ),
          Expanded(
                                    child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasksByCategory[currentCategory]!['completedTasks']!.length,
              itemBuilder: (context, index) {
                final task = tasksByCategory[currentCategory]!['completedTasks']![index];
                return ListTile(
                  title: Text(
                    task['title'],
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Check if the task has a note and show the icon
                      if (task['note'] != null && task['note']!.isNotEmpty)
                        const Icon(Icons.description, color: Colors.lightBlue),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          _toggleTaskCompletion(index, true);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showBottomSheet(context, index, true); // Show the bottom sheet
                  },
                );
              },
            )


          ),
        ],
      ),
      floatingActionButton: tasksByCategory.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              tooltip: 'Add Task',
              child: const Icon(Icons.add),
            )
          : null,
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

void _showBottomSheet(BuildContext context, int index, bool isCompleted) {
  final taskList = tasksByCategory[currentCategory]![isCompleted ? 'completedTasks' : 'uncompletedTasks']!;
  final task = taskList[index];
  final String taskTitle = task['title'];
  String note = task['note'] ?? '';

showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero, // No rounded corners
  ),
  builder: (context) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          taskTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const Divider(),
        TextField(
          controller: TextEditingController(text: note),
          decoration: const InputDecoration(labelText: 'Add a Note'),
          onChanged: (value) => note = value,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  task['note'] = note;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save Note'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              taskList.removeAt(index);
                            });
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Close bottom sheet
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red),),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Delete Task', style: TextStyle(color: Colors.red),),
            ),
          ],
        ),
      ],
    ),
  ),
);
}
}
