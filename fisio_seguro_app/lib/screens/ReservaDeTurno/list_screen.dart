import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ListaDeTurnosScreen extends StatefulWidget {
  const ListaDeTurnosScreen({Key? key}) : super(key: key);

  @override
  _ListaDeTurnosScreenState createState() => _ListaDeTurnosScreenState();
}

class _ListaDeTurnosScreenState extends State<ListaDeTurnosScreen> {
  List<Map<String, dynamic>> turnos = [];
  List<Map<String, dynamic>> personas = [];
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> originalTurnos = [];
  DateTime selectedDateStart = DateTime.now();
  DateTime selectedDateEnd = DateTime.now();
  String? selectedCliente;
  String? selectedDoctor;
  late String filePathTurno;

  @override
  void initState() {
    super.initState();
    _initialize('categories');
    _initialize('persons');
    _initialize('turnos');
  }

  Future<void> _saveturnos() async {
    final File file = File(filePathTurno);
    final String data = json.encode(turnos);
    await file.writeAsString(data);
  }

  void _filter() {
    List<Map<String, dynamic>> filteredList = originalTurnos;

    if (selectedDoctor != null) {
      filteredList = filteredList
          .where((turno) =>
              turno['doctor']['idPersona'] == int.parse(selectedDoctor!))
          .toList();
    }
    if (selectedCliente != null) {
      filteredList = filteredList
          .where((turno) =>
              turno['paciente']['idPersona'] == int.parse(selectedCliente!))
          .toList();
    }

    DateTime selectedDateEndFilter = DateTime(
        selectedDateEnd.year, selectedDateEnd.month, selectedDateEnd.day,23, 59, 59);
    DateTime selectedDateStartFilter = DateTime(
        selectedDateStart.year, selectedDateStart.month, selectedDateStart.day);
    filteredList = filteredList
        .where((turno) =>
            DateTime.parse(turno['fecha']).isAfter(selectedDateStartFilter) ||
            DateTime.parse(turno['fecha']).isAtSameMomentAs(selectedDateStartFilter))
        .toList();
    filteredList = filteredList
        .where((turno) =>
            DateTime.parse(turno['fecha']).isBefore(selectedDateEndFilter) ||
            DateTime.parse(turno['fecha']).isAtSameMomentAs(selectedDateEndFilter))
        .toList();

    setState(() {
      turnos = filteredList;
    });
  }

//si el archivo no existe, lo crea y lo llena con el contenido del archivo persons.json
// si el archivo existe, lo carga
  Future<void> _initialize(String objeto) async {
    final directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$objeto.json';
    if (objeto == 'turnos') {
      filePathTurno = filePath;
    }
    final File file = File(filePath);

/*     final String jsonString =
        await rootBundle.loadString('assets/$objeto.json');
    await file.writeAsString(jsonString); */

    if (!await file.exists()) {
      final String jsonString =
          await rootBundle.loadString('assets/$objeto.json');
      await file.writeAsString(jsonString);
    }

    final data = await file.readAsString();
    final List<Map<String, dynamic>> loadedData = List.from(json.decode(data));
    setState(() {
      if (objeto == 'categories') {
        categorias = loadedData;
      } else if (objeto == 'persons') {
        personas = loadedData;
      } else if (objeto == 'turnos') {
        originalTurnos = loadedData;
        _filter();
      }
    });
  }

  List<DropdownMenuItem<String>> _listaPersonas(bool isDoctor) {
    List<DropdownMenuItem<String>> listaClientes = personas
        .where((persona) => persona['isDoctor'] == isDoctor)
        .map((persona) {
      String nombre = persona['nombre'];
      String apellido = persona['apellido'];
      String personaId = persona['idPersona'].toString();
      String nombreCompleto = '$nombre $apellido';
      return DropdownMenuItem<String>(
        value: personaId,
        child: Text(nombreCompleto),
      );
    }).toList();
    return listaClientes;
  }

  List<DropdownMenuItem<String>> _listaCategorias() {
    List<DropdownMenuItem<String>> listaCategorias = categorias.map((categoria) {
      String nombre = categoria['descripcion'];
      String categoriaId = categoria['id'].toString();
      return DropdownMenuItem<String>(
        value: categoriaId,
        child: Text(nombre),
      );
    }).toList();
    return listaCategorias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva de turnos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                value:
                    selectedCliente, // El valor seleccionado (inicialmente null)
                hint: const Text(
                    'Selecciona un paciente'), // Texto que se muestra cuando no se ha seleccionado nada
                items: _listaPersonas(false),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      selectedCliente = newValue;
                    }
                  });
                },
              ),
              DropdownButton<String>(
                value:
                    selectedDoctor, // El valor seleccionado (inicialmente null)
                hint: const Text(
                    'Selecciona un doctor'), // Texto que se muestra cuando no se ha seleccionado nada
                items: _listaPersonas(true),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      selectedDoctor = newValue;
                    }
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Desde',
                ),
                onTap: () async {
                  DateTime? pickedDateStart = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDateStart != null &&
                      pickedDateStart != selectedDateStart) {
                    setState(() {
                      selectedDateStart = pickedDateStart;
                    });
                  }
                },
                controller: TextEditingController(
                    text: selectedDateStart.toLocal().toString().split(' ')[0]),
                readOnly: true,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Hasta',
                ),
                onTap: () async {
                  DateTime? pickedDateEnd = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDateEnd != null &&
                      pickedDateEnd != selectedDateEnd) {
                    setState(() {
                      selectedDateEnd = pickedDateEnd;
                    });
                  }
                },
                controller: TextEditingController(
                    text: selectedDateEnd.toLocal().toString().split(' ')[0]),
                readOnly: true,
              ),
              ElevatedButton(
                onPressed: _filter,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter), // Icono para el botón de filtrar
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text('Filtrar'),
                  ],
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: turnos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        'Cliente: ${turnos[index]['paciente']['nombre']} ${turnos[index]['paciente']['apellido']}'),
                    subtitle: Text(
                        'Doctor: ${turnos[index]['doctor']['nombre']} ${turnos[index]['doctor']['apellido']}\nFecha: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(turnos[index]['fecha']))}\t${turnos[index]['hora']}\nCategoria: ${turnos[index]['categoria']['descripcion']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTurno(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTurno(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTurno(int index) {
    DateTime editedDate = DateTime.parse(turnos[index]['fecha']);
    String? editedTime = turnos[index]['hora'];
    String? editedCliente = turnos[index]['paciente']['idPersona'];
    String? editedDoctor = turnos[index]['doctor']['idPersona'];
    String? editedCategory = turnos[index]['categoria']['id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value:
                  editedCliente, // El valor seleccionado (inicialmente null)
              hint: const Text(
                  'Selecciona un paciente'), // Texto que se muestra cuando no se ha seleccionado nada
              items: _listaPersonas(false),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    editedCliente = newValue;
                  }
                });
              },
            ),
            DropdownButton<String>(
              value: editedDoctor, // El valor seleccionado (inicialmente null)
              hint: const Text(
                  'Selecciona un doctor'), // Texto que se muestra cuando no se ha seleccionado nada
              items: _listaPersonas(true),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    editedDoctor = newValue;
                  }
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Selecciona una fecha',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null && pickedDate != editedDate) {
                  setState(() {
                    editedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                  text: editedDate.toLocal().toString().split(' ')[0]),
              readOnly: true,
            ),
            DropdownButton<String>(
              value: editedTime,
              hint: const Text('Selecciona una hora'),
              items: [
                "09:00 - 10:00",
                "10:00 - 11:00",
                "11:00 - 12:00",
                "12:00 - 13:00",
                "13:00 - 14:00",
                "14:00 - 15:00",
                "15:00 - 16:00",
                "16:00 - 17:00",
                "17:00 - 18:00",
                "18:00 - 19:00",
                "19:00 - 20:00",
                "20:00 - 21:00"
              ]
                  .map((time) => DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    editedTime = value;
                  });
                }
              },
            ),
            DropdownButton<String>(
              value:
                  editedCategory, // El valor seleccionado (inicialmente null)
              hint: const Text(
                  'Selecciona una Categoria'), // Texto que se muestra cuando no se ha seleccionado nada
              items: _listaCategorias(),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    editedCategory = newValue;
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                turnos[index] = {
                  'doctor': {
                    'idPersona': personas[int.parse(editedDoctor!) - 1]
                        ['idPersona'],
                    'nombre': personas[int.parse(editedDoctor!) - 1]['nombre'],
                    'apellido': personas[int.parse(editedDoctor!) - 1]
                        ['apellido'],
                    'RUC': personas[int.parse(editedDoctor!) - 1]
                        ['RUC'],
                    'email': personas[int.parse(editedDoctor!) - 1]['email'],
                    'cedula': personas[int.parse(editedDoctor!) - 1]['cedula'],
                    'isDoctor': personas[int.parse(editedDoctor!) - 1]
                        ['isDoctor'],
                    'isEditing': false
                  },
                  'paciente': {
                    'idPersona': personas[int.parse(editedCliente!) - 1]
                        ['idPersona'],
                    'nombre': personas[int.parse(editedCliente!) - 1]
                        ['nombre'],
                    'apellido': personas[int.parse(editedCliente!) - 1]
                        ['apellido'],
                    'RUC': personas[int.parse(editedCliente!) - 1]
                        ['RUC'],
                    'email': personas[int.parse(editedCliente!) - 1]['email'],
                    'cedula': personas[int.parse(editedCliente!) - 1]
                        ['cedula'],
                    'isDoctor': personas[int.parse(editedCliente!) - 1]
                        ['isDoctor'],
                    'isEditing': false
                  },
                  // 'fecha' : selectedDate to string
                  'fecha': editedDate.toString(),
                  'hora': editedTime,
                  'categoria': {
                    'id': categorias[int.parse(editedCategory!) - 1]['id'],
                    'descripcion': categorias[int.parse(editedCategory!) - 1]
                        ['descripcion'],
                  }
                };
              });

              _saveturnos(); // Save changes to file
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteTurno(int index) {
    setState(() {
      turnos.removeAt(index);
    });
    _saveturnos(); // Save changes to file
  }
}
