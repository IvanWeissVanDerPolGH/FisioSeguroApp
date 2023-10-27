// ignore_for_file: avoid_shadowing_type_parameters

import 'package:flutter/material.dart';
mixin PersonWidgets<T extends StatefulWidget> on State<T> {
  List<DataColumn> getColumns() {
    return [
      _createColumn('Name', 0),
      _createColumn('Last Name', 1),
      _createColumn('Phone', 2),
      _createColumn('Email', 3),
      _createColumn('ID', 4),
      _createColumn('is Dr?', 5),
      const DataColumn(label: Text('Actions')),
    ];
  }

  DataColumn _createColumn(String label, int index) {
    return DataColumn(
      label: Text(label),
      onSort: (columnIndex, ascending) => sort<String>(index, ascending),
    );
  }



  List<DataRow> getRows() {
    return persons.map((person) {
      return DataRow(
        cells: [
          DataCell(Text(person[0], overflow: TextOverflow.ellipsis)),
          DataCell(Text(person[1], overflow: TextOverflow.ellipsis)),
          DataCell(Text(person[2], overflow: TextOverflow.ellipsis)),
          DataCell(Text(person[3], overflow: TextOverflow.ellipsis, maxLines: 1)),
          DataCell(Text(person[4], overflow: TextOverflow.ellipsis)),
          DataCell(Checkbox(
            value: person[5] == "True",
            onChanged: (bool? value) {},
          )),
          DataCell(actionButtons()),
        ],
      );
    }).toList();
  }

  Widget actionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {},
        ),
      ],
    );
  }



  final List<List<String>> persons = [
    ['Ethan_0', 'Clark_0', '555-876-5432', 'ethanclark_0@example.com', 'K12345', "True"],
    ['Ava_1', 'Davis_1', '555-345-6789', 'avadavis_1@example.com', 'L98765', "False"],
    ['Ethan_2', 'Ethan_2', '555-246-912', 'ethan_2ethan_2_2@example.com', 'C24690', "True"],
    ['Ava_3', 'Ava_3', '555-369-368', 'ava_3ava_3_3@example.com', 'D37035', "True"],
    ['Ethan_4', 'Clark_4', '555-492-824', 'ethan_4clark_4_4@example.com', 'E49380', "False"],
    ['Ava_5', 'Davis_5', '555-615-280', 'ava_5davis_5_5@example.com', 'F61725', "True"],
    ['Ethan_6', 'Ethan_6', '555-738-736', 'ethan_6ethan_6_6@example.com', 'G74070', "True"],
  ]; // Your person data here

  late List<List<String>> originalOrder;
  int? sortColumnIndex;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    originalOrder = List.from(persons);
  }

  void sort<T>(int columnIndex, bool ascending) {
    if (sortColumnIndex == columnIndex && !sortAscending) {
      // Reset to original order when clicked consecutively
      persons.setAll(0, originalOrder);
      sortColumnIndex = null;
    } else {
      persons.sort((a, b) {
        final comparableA = a[columnIndex] as T;
        final comparableB = b[columnIndex] as T;
        return ascending
            ? (comparableA as Comparable<T>).compareTo(comparableB)
            : (comparableB as Comparable<T>).compareTo(comparableA);
      });
      if (mounted) {
        setState(() {
          sortColumnIndex = columnIndex;
          sortAscending = ascending;
        });
      }
    }
  }
}