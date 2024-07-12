import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelecter extends StatefulWidget {
  final Function selectDate;

  const DateSelecter(this.selectDate, {Key? key}) : super(key: key);

  @override
  State<DateSelecter> createState() => _DateSelecterState();
}

class _DateSelecterState extends State<DateSelecter> {
  DateTime? selectedDate;
  void _pickDate() {
    showDatePicker(
            // initialEntryMode: DatePickerEntryMode.calendarOnly,
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1940),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate = pickedDate;
      });
      widget.selectDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            selectedDate == null
                ? 'No date chosen'
                : DateFormat.yMd().format(selectedDate!),
            style: TextStyle(
              color: selectedDate == null ? Colors.grey : Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _pickDate();
            },
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}

class DateSelecterForDob extends StatefulWidget {
  final Function selectDate;
  final String? initialDOB;
  const DateSelecterForDob(
      {required this.selectDate, required this.initialDOB, Key? key})
      : super(key: key);

  @override
  State<DateSelecterForDob> createState() => _DateSelecterForDobState();
}

class _DateSelecterForDobState extends State<DateSelecterForDob> {
  DateTime? selectedDate;
  void _pickDate() {
    showDatePicker(
            initialEntryMode: DatePickerEntryMode.input,
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1940),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate = pickedDate;
      });
      widget.selectDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            selectedDate == null && widget.initialDOB == null
                ? 'No date chosen'
                : selectedDate == null && widget.initialDOB != null
                    ? widget.initialDOB!
                    : DateFormat.yMd().format(selectedDate!),
            style: TextStyle(
              color: selectedDate == null && widget.initialDOB == null
                  ? Colors.grey
                  : Colors.black,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _pickDate();
            },
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
