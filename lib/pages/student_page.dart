import 'package:flutter/material.dart';
import 'package:myapp/objects/application_state.dart';
import 'package:myapp/objects/student_classes.dart';
import 'package:provider/provider.dart';

class StudentPage extends StatefulWidget {
  StudentPage({Key? key}) : super(key: key);

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  TextEditingController classNameText = TextEditingController();
  TextEditingController classDescriptionText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Your Student Schedule'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(
              child: Consumer<ApplicationState>(
                  builder: (context, appState, _) => ListView.builder(
                      itemCount: appState.classMap.length,
                      itemBuilder: (context, index) {
                        int key = appState.classMap.keys.elementAt(index);
                        return Card(
                          child: ListTile(
                              tileColor: Colors.grey[200],
                              title: Text(
                                appState.classMap[key]!.className,
                                overflow: TextOverflow.fade,
                              ),
                              subtitle: Text(
                                appState.classMap[key]!.description,
                                overflow: TextOverflow.fade,
                              ),
                              trailing:
                                  const Icon(Icons.arrow_drop_down_rounded),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ClassPage(),
                                      settings: RouteSettings(
                                          arguments: appState.classMap[key]))),
                              onLongPress: () =>
                                  _classOptionsDialog(appState.classMap, key)),
                        );
                      }))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClassDialog,
        child: const Icon(Icons.add_rounded, color: Colors.white),
        backgroundColor: Colors.indigo,
        elevation: 10,
      ),
    ));
  }

  Future<void> _addClassDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ApplicationState>(
            builder: (context, appState, _) => AlertDialog(
                  title: const Text('Add a class'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text('Class name')),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5)),
                          controller: classNameText,
                        ),
                        const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 5),
                            child: Text('Class description')),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5)),
                          controller: classDescriptionText,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Create'),
                      onPressed: () async {
                        StudentClass newClass = await appState.createClass(
                            classNameText.text, classDescriptionText.text, {});
                        setState(() {
                          appState.classMap[newClass.id] = newClass;
                          classNameText.clear();
                          classDescriptionText.clear();
                        });
                        await appState.classHandler
                            .insertClass(appState.classMap[newClass.id]!);
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      },
    );
  }

  void _classOptionsDialog(Map<int, StudentClass> classMap, int id) async {
    String className = classMap[id]!.className;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('What would you like to do with $className?'),
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Consumer<ApplicationState>(
                        builder: (context, appState, _) => ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            onPressed: () {
                              setState(() {
                                appState.removeClass(id);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Delete")),
                      )),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Consumer<ApplicationState>(
                        builder: (context, appState, _) => ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.indigo)),
                            onPressed: () async {
                              await _editClassDialog(classMap[id]!);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Edit")),
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> _editClassDialog(StudentClass studentClass) async {
    String className = studentClass.className;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ApplicationState>(
            builder: (context, appState, _) => AlertDialog(
                  title: Text('Edit $className', overflow: TextOverflow.fade),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text('Class name')),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5)),
                          controller: classNameText,
                        ),
                        const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 5),
                            child: Text('Class description')),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5)),
                          controller: classDescriptionText,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Apply'),
                      onPressed: () async {
                        setState(() {
                          editClass(studentClass);
                          appState.classMap[studentClass.id] = studentClass;
                          classNameText.clear();
                          classDescriptionText.clear();
                        });
                        await appState.classHandler.updateClass(studentClass);
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      },
    );
  }

  void editClass(StudentClass studentClass) {
    if (classNameText.text == "") {
      studentClass.className = "Untitled Class";
    } else {
      studentClass.className = classNameText.text.toString();
    }
    studentClass.description = classDescriptionText.text.toString();
  }
}
