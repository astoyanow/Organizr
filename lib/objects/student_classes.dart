import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:myapp/main.dart';
import 'package:myapp/objects/application_state.dart';
import 'package:myapp/widgets/date_picker_widget.dart';
import 'package:provider/provider.dart';

class StudentClass {
  StudentClass(
      {Key? key,
      required this.className,
      required this.description,
      this.assignmentMap,
      required this.id});

  String className;
  String description;
  Map<int, Assignment>? assignmentMap;
  int id;

  Map<String, dynamic> toMap() {
    return {
      'classId': id,
      'className': className,
      'classDescription': description,
    };
  }

  StudentClass.fromMap(Map<String, dynamic> res)
      : id = res["classId"],
        className = res["className"],
        description = res["classDescription"];
}

class Assignment {
  Assignment(
      {required this.assignmentTitle,
      required this.dueDate,
      required this.assignmentType,
      required this.classId,
      required this.id});

  String assignmentTitle;
  DateTime? dueDate;
  String assignmentType;
  int classId;
  int id;

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': id,
      'classAssignmentId': classId,
      'assignmentName': assignmentTitle,
      'assignmentType': assignmentType,
      'dueDate': dueDate.toString()
    };
  }

  Assignment.fromMap(Map<String, dynamic> res)
      : id = res["assignmentId"],
        classId = res["classAssignmentId"],
        assignmentTitle = res["assignmentName"],
        assignmentType = res["assignmentType"],
        dueDate = DateTime.parse(res["dueDate"]);
}

class ClassPage extends StatefulWidget {
  ClassPage({Key? key}) : super(key: key);

  @override
  ClassPageState createState() => ClassPageState();
}

class ClassPageState extends State<ClassPage> {
  TextEditingController assignmentNameText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final studentClass =
        ModalRoute.of(context)!.settings.arguments as StudentClass;
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
          tooltip: 'Go back to the class list.',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          studentClass.className,
          overflow: TextOverflow.fade,
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(
              child: Consumer<ApplicationState>(
                  builder: (context, appState, _) => ListView.builder(
                      itemCount:
                          assignmentListLength(studentClass.assignmentMap),
                      itemBuilder: (context, index) {
                        int key =
                            studentClass.assignmentMap!.keys.elementAt(index);
                        return Card(
                          child: ListTile(
                            onTap: () => _assignmentOptionsDialog(
                                studentClass.assignmentMap![key]!),
                            tileColor:
                                dueDateColor(studentClass.assignmentMap![key]!),
                            title: (Text(
                              studentClass.assignmentMap![key]!.assignmentTitle,
                              overflow: TextOverflow.fade,
                            )),
                            subtitle: Text(
                              studentClass.assignmentMap![key]!.dueDate
                                  .toString()
                                  .substring(0, 16),
                              overflow: TextOverflow.fade,
                            ),
                            leading: assignmentTypeIcon(
                                studentClass.assignmentMap![key]!),
                          ),
                        );
                      }))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _assignmentCreatorDialog,
        child: const Icon(Icons.add_rounded, color: Colors.white),
        backgroundColor: Colors.indigo,
        elevation: 10,
      ),
    ));
  }

  int assignmentListLength(Map<int, Assignment>? assignments) {
    if (assignments == null) {
      return 0;
    } else {
      return assignments.length;
    }
  }

  String dropDownVal = 'Homework/Reading';
  DateTime? assignmentDate;

// add an assignment to the assignment list
  Future<void> _assignmentCreatorDialog() async {
    if (assignmentDate != null) {
      assignmentDate = null;
    }
    final studentClass =
        ModalRoute.of(context)!.settings.arguments as StudentClass;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add an assignment'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter _setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text('Assignment name')),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5)),
                        controller: assignmentNameText,
                      )),
                  const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text('Assignment Type')),
                  DropdownButton(
                    value: dropDownVal,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: <String>[
                      'Homework/Reading',
                      'Quiz/Small Project',
                      'Large Project/Exam'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          child: Text(value), value: value);
                    }).toList(),
                    onChanged: (String? newValue) {
                      _setState(() {
                        dropDownVal = newValue!;
                      });
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                          onPressed: () async {
                            assignmentDate = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DatePickerWidget()));
                            _setState(() {
                              assignmentDate;
                            });
                          },
                          child: const Text("Select Due Date"))),
                  Text(assignmentDate == null
                      ? ""
                      : assignmentDate.toString().substring(0, 16))
                ],
              ),
            );
          }),
          actions: <Widget>[
            Consumer<ApplicationState>(
                builder: (context, appState, _) => TextButton(
                      child: const Text('Create'),
                      onPressed: () async {
                        Assignment newAssignment =
                            await appState.createAssignment(
                                studentClass,
                                assignmentNameText.text,
                                assignmentDate,
                                dropDownVal);
                        setState(() {
                          if (assignmentDate != null) {
                            studentClass.assignmentMap![newAssignment.id] =
                                newAssignment;
                            appState.addClass(studentClass.id, newAssignment);
                            assignmentNameText.clear();
                            Navigator.of(context).pop();
                          }
                        });
                        if (assignmentDate != null) {
                          await appState.classHandler.insertAssignment(
                              studentClass.assignmentMap![newAssignment.id]!);
                        }
                      },
                    )),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _editAssignmentDialog(Assignment assignment) async {
    String assignmentName = assignment.assignmentTitle;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $assignmentName'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter _setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text('Assignment name')),
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: assignmentName,
                    ),
                    controller: assignmentNameText,
                  ),
                  const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Text('Assignment Type')),
                  DropdownButton(
                    value: assignment.assignmentType,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: <String>[
                      'Homework/Reading',
                      'Quiz/Small Project',
                      'Large Project/Exam'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          child: Text(value), value: value);
                    }).toList(),
                    onChanged: (String? newValue) {
                      _setState(() {
                        dropDownVal = newValue!;
                      });
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                          onPressed: () async {
                            assignmentDate = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DatePickerWidget()));
                            _setState(() {
                              assignmentDate;
                            });
                          },
                          child: const Text("Select Due Date"))),
                  Text(assignment.dueDate.toString().substring(0, 16))
                ],
              ),
            );
          }),
          actions: <Widget>[
            Consumer<ApplicationState>(
                builder: (context, appState, _) => TextButton(
                      child: const Text('Apply'),
                      onPressed: () async {
                        setState(() {
                          editAssignment(assignment);
                          appState.assignmentMap[assignment.classId]![
                              assignment.id] = assignment;
                        });
                        await appState.classHandler
                            .updateAssignment(assignment);
                        Navigator.of(context).pop();
                      },
                    )),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _assignmentOptionsDialog(Assignment assignment) async {
    final studentClass =
        ModalRoute.of(context)!.settings.arguments as StudentClass;
    String assignmentName = assignment.assignmentTitle;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('What would you like to do with $assignmentName?'),
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.indigo)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editAssignmentDialog(assignment);
                        },
                        child: const Text("Edit")),
                  ),
                ),
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
                                appState.removeAssignment(
                                    studentClass.id, assignment.id);
                                studentClass.assignmentMap!
                                    .remove(assignment.id);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Delete"))),
                  ),
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
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<DateTime?> getDatePickerData(BuildContext context) async {
    final DateTime date = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DatePickerWidget()));
    return date;
  }

  void editAssignment(Assignment assignment) {
    if (assignmentNameText.text.toString() == "") {
      assignment.assignmentTitle = "Untitled Assignment";
    } else {
      assignment.assignmentTitle = assignmentNameText.text.toString();
    }
    assignment.dueDate = assignmentDate;
    assignment.assignmentType = dropDownVal;
  }

  // used to set icon depending on the type of assignment for the assignment's ListTile
  Icon assignmentTypeIcon(Assignment assignment) {
    if (assignment.assignmentType == "Homework/Reading") {
      return const Icon(Icons.auto_stories_outlined);
    } else if (assignment.assignmentType == "Quiz/Small Project") {
      return const Icon(Icons.my_library_books_sharp);
    } else {
      return const Icon(Icons.dashboard_sharp);
    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  MaterialColor dueDateColor(Assignment assignment) {
    if (assignment.dueDate == null) {
      return Colors.grey;
    } else if (daysBetween(DateTime.now(), assignment.dueDate!) < 4) {
      return Colors.red;
    } else if (daysBetween(DateTime.now(), assignment.dueDate!) < 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Future<void> deleteClass(StudentClass studentClass) async {
    String className = studentClass.className;
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete $className?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Delete"))
            ],
          );
        });
  }
}
