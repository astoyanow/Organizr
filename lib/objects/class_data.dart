import 'dart:async';

import 'package:myapp/objects/student_classes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StudentClassDB {
  static final _dbName = 'classes.db';
  static final _version = 1;

  static final classTable = 'studentClasses';
  static final assignmentTable = 'assignments';

  static final columnClassName = 'className';
  static final columnClassId = 'classId';
  static final columnClassDescription = 'classDescription';

  static final columnAssignmentName = 'assignmentName';
  static final columnAssignmentId = 'assignmentId';
  static final columnClassAssignmentId = 'classAssignmentId';
  static final columnAssignmentType = 'assignmentType';
  static final columnDueDate = 'dueDate';

  Future<Database> initClassesDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        print("Creating database");
        await db.execute(
          '''CREATE TABLE $classTable ($columnClassId INTEGER PRIMARY KEY, 
            $columnClassName TEXT, 
            $columnClassDescription TEXT)''',
        );
        await db.execute(
          '''CREATE TABLE $assignmentTable ($columnAssignmentId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnClassAssignmentId INTEGER,
            $columnAssignmentName TEXT, 
            $columnAssignmentType TEXT,
            $columnDueDate TEXT,
            FOREIGN KEY ($columnClassAssignmentId) REFERENCES $classTable($columnClassId))''',
        );
      },
      onOpen: (db) async {
        print("Opening database");
      },
      version: _version,
    );
  }

  Future<void> insertClass(StudentClass studentClass) async {
    final Database db = await initClassesDb();
    await db.insert(
      classTable,
      studentClass.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAssignment(Assignment assignment) async {
    final Database db = await initClassesDb();
    await db.insert(
      assignmentTable,
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // use when assigning IDs to classes
  Future<int> getLastClassInsert() async {
    final Database db = await initClassesDb();
    var res = await db.query(classTable, orderBy: "$columnClassId DESC");
    List<StudentClass> classesMap =
        res.map((e) => StudentClass.fromMap(e)).toList();
    if (classesMap.isEmpty) {
      return 0;
    } else {
      return classesMap[0].id;
    }
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<StudentClass>> getClasses() async {
    final Database db = await initClassesDb();
    final List<Map<String, dynamic>> maps = await db.query(classTable);
    // NEED TO IMPLEMENT ASSIGNMENT DB INTO HERE
    return List.generate(maps.length, (i) {
      return StudentClass(
        id: maps[i][columnClassId],
        className: maps[i][columnClassName],
        description: maps[i][columnClassDescription],
      );
    });
  }

  Future<List<Assignment>> getAssignments() async {
    final Database db = await initClassesDb();
    final List<Map<String, dynamic>> maps = await db.query(assignmentTable);
    return List.generate(maps.length, (i) {
      return Assignment(
          id: maps[i][columnAssignmentId],
          classId: maps[i][columnClassAssignmentId],
          assignmentTitle: maps[i][columnAssignmentName],
          assignmentType: maps[i][columnAssignmentType],
          dueDate: maps[i][columnDueDate]);
    });
  }

  Future<void> updateClass(StudentClass studentClass) async {
    final Database db = await initClassesDb();
    await db.update(
      classTable,
      studentClass.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [studentClass.id],
    );
  }

  Future<void> deleteClass(int id) async {
    final Database db = await initClassesDb();
    await db.delete(
      classTable,
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
