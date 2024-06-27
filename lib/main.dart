import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Martynkowe Kreski',
      theme: ThemeData(
        primaryColor: Colors.pink[200],
        scaffoldBackgroundColor: Colors.pink[50],
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.pink[900]),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _persons = [];

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? personsJson = prefs.getString('persons');
    if (personsJson != null) {
      setState(() {
        _persons = List<Map<String, dynamic>>.from(json.decode(personsJson));
      });
    }
  }

  Future<void> _savePersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String personsJson = json.encode(_persons);
    await prefs.setString('persons', personsJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Martynkowe Kreski',
          style: TextStyle(color: Colors.pink[900]),
        ),
        backgroundColor: Colors.pink[200],
        leading: Image.asset(
          'assets/logokreski.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
      body: _persons.isEmpty
          ? const Center(
        child: Text(
          'Brak osób, dodaj!',
          style: TextStyle(fontSize: 20),
        ),
      )
          : ListView.builder(
        itemCount: _persons.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.pink[100],
            child: ListTile(
              title: Text(
                _persons[index]['name'],
                style: TextStyle(fontSize: 18, color: Colors.pink[900])
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_persons[index]['counter'] > 0) {
                          _persons[index]['counter']--;
                          _savePersons();
                        }
                      });
                    },
                  ),
                  Text(
                    _persons[index]['counter'].toString(),
                    style: TextStyle(fontSize: 18, color: Colors.pink[900]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _persons[index]['counter']++;
                        _savePersons();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPersonDialog,
        tooltip: 'Dodaj osobę',
        backgroundColor: Colors.pink[300],
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddPersonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String personName = '';
        return AlertDialog(
          title: Text(
            'Dodaj osobę',
            style: TextStyle(color: Colors.pink[900]),
          ),
          content: TextField(
            onChanged: (value) {
              personName = value;
            },
            decoration: InputDecoration(
              hintText: "Wpisz imię osoby",
              hintStyle: TextStyle(color: Colors.pink[200]),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Anuluj',
                style: TextStyle(color: Colors.pink[900]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Dodaj',
                style: TextStyle(color: Colors.pink[900]),
              ),
              onPressed: () {
                if (personName.isNotEmpty) {
                  setState(() {
                    _persons.add({'name': personName, 'counter': 0});
                    _savePersons();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Potwierdzenie',
            style: TextStyle(color: Colors.pink[900]),
          ),
          content: Text(
            'Czy na pewno chcesz usunąć osobę?',
            style: TextStyle(color: Colors.pink[200]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Anuluj',
                style: TextStyle(color: Colors.pink[900]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Usuń',
                style: TextStyle(color: Colors.pink[900]),
              ),
              onPressed: () {
                setState(() {
                  _persons.removeAt(index);
                  _savePersons();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
