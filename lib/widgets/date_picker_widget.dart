import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  DatePickerWidget({Key? key}) : super(key: key);

  @override
  DatePickerWidgetState createState() => DatePickerWidgetState();
}

class DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime selectedDateTime = DateTime.now();
  TextEditingController dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(5),
        child: DateTimePicker(
          type: DateTimePickerType.dateTimeSeparate,
          dateLabelText: "Select a date",
          timeLabelText: "Select a time",
          controller: dateTimeController,
          firstDate: DateTime.now(),
          lastDate: DateTime(2023),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Create'),
          onPressed: () {
            if (isValidDate(dateTimeController.text)) {
              selectedDateTime =
                  DateTime.parse(dateTimeController.text.toString());
              Navigator.of(context).pop(selectedDateTime);
            }
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  bool isValidDate(String input) {
    try {
      DateTime.parse(input);
      return true;
    } catch (e) {
      return false;
    }
  }
}
