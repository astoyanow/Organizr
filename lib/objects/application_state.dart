import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:myapp/objects/class_data.dart';
import 'package:myapp/objects/student_classes.dart';

class ApplicationState extends ChangeNotifier {
  late StudentClassDB classHandler;
  Map<int, Map<int, Assignment>> assignmentMap = {};
  Map<int, StudentClass> classMap = {};
  List<StudentClass> classList = [];

  ApplicationState() {
    classHandler = StudentClassDB();
    classHandler.initClassesDb();
    init();
  }

  Future<void> init() async {
    classList = await classHandler.getClasses();
    List<Assignment> assignments = await classHandler.getAssignments();
    for (StudentClass studentClass in classList) {
      classMap[studentClass.id] = studentClass;
    }
    for (Assignment assignment in assignments) {
      print(assignment.toMap());
      if (assignmentMap[assignment.classId] == null) {
        assignmentMap[assignment.classId] =
            {}; //create map for assignments in a class
      }
      assignmentMap[assignment.classId]![assignment.id] =
          assignment; //add assignment to class's assignment map
      classMap[assignment.classId]!.assignmentMap =
          assignmentMap[assignment.classId]!; //set the
    }

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

  Future<int> getAssignmentId() async {
    int id = await classHandler.getLastAssignmentInsert();
    print(id);
    if (id == 0) {
      return 1;
    } else {
      return id + 1;
    }
  }

  Future<StudentClass> createClass(String className, String description,
      Map<int, Assignment> assignments) async {
    StudentClass newClass = StudentClass(
        className: (className == '') ? "Untitled Class" : className,
        description: description,
        assignmentMap: assignments,
        id: await getClassId());
    return newClass;
  }

  void addClass(int classId, Assignment assignment) {
    if (assignmentMap[classId] == null) {
      assignmentMap[classId] = {};
    }
    assignmentMap[classId]![assignment.id] = assignment;
  }

  Future<Assignment> createAssignment(
      StudentClass studentClass,
      String assignmentNameText,
      DateTime? assignmentDate,
      String dropDownVal) async {
    String assignmentName = "";
    if (assignmentNameText == "") {
      assignmentName = "Untitled Assignment";
    } else {
      assignmentName = assignmentNameText;
    }
    return Assignment(
        assignmentTitle: assignmentName,
        dueDate: assignmentDate,
        assignmentType: dropDownVal,
        classId: studentClass.id,
        id: await getAssignmentId());
  }

  Future<void> removeClass(int classId) async {
    if (assignmentMap[classId] != null) {
      assignmentMap[classId]!.forEach((key, value) async {
        await classHandler.deleteAssignment(classId, key);
      });
      assignmentMap[classId] = {};
    }
    classMap.remove(classId);
    await classHandler.deleteClass(classId);
  }

  Future<void> removeAssignment(int classId, int id) async {
    assignmentMap[classId]!.remove(id);
    await classHandler.deleteAssignment(classId, id);
  }
}
