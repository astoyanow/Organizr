import 'package:flutter/material.dart';
import 'package:myapp/objects/class_data.dart';
import 'package:myapp/objects/student_classes.dart';

class ApplicationState extends ChangeNotifier {
  late StudentClassDB classHandler;
  List<StudentClass> classes = [];

  ApplicationState() {
    classHandler = StudentClassDB();
    classHandler.initClassesDb();
    init();
  }

  Future<void> init() async {
    List<StudentClass> studentClasses = await classHandler.getClasses();
    List<Assignment> assignments = await classHandler.getAssignments();
    for (Assignment assignment in assignments) {
      studentClasses[assignment.classId].assignmentList!.add(assignment);
    }
    classes = studentClasses;

    notifyListeners();
  }

  Future<int> getClassId() async {
    int id = await classHandler.getLastClassInsert();
    if (id == 0) {
      return 1;
    } else {
      return id + 1;
    }
  }

  Future<StudentClass> addClass(String className, String description,
      List<Assignment> assignments) async {
    StudentClass newClass = StudentClass(
        className: (className == '') ? "Untitled Class" : className,
        description: description,
        assignmentList: assignments,
        id: await getClassId());
    return newClass;
  }
}
