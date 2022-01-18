import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String titulo = 'Conversor de Moeda';
    return MaterialApp(
      title: titulo,
      theme: ThemeData(
          primarySwatch: Colors.green,
          hintColor: Colors.green,
          primaryColor: Colors.white),
      home: const Home(title: titulo),
    );
  }
}

Future<Map> getData() async {
  String request =
      "https://api.hgbrasil.com/finance?format=json&key= <<chave_da_api>>";
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _limparSeVazio(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
  }

  void _realChanged(String text) {
    _limparSeVazio(text);
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    _limparSeVazio(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    _limparSeVazio(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Aguarde...",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    "Falha de conexão",
                    style: TextStyle(color: Colors.green, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(
                          Icons.attach_money,
                          size: 100.0,
                          color: Colors.green,
                        ),
                        buildTextField(
                          "Reais",
                          "R\$ ",
                          realController,
                          _realChanged,
                        ),
                        buildTextField(
                          "Euros",
                          "€ ",
                          euroController,
                          _euroChanged,
                        ),
                        buildTextField(
                          "Dólares",
                          "US\$ ",
                          dolarController,
                          _dolarChanged,
                        ),
                      ]),
                );
            }
          },
        ));
  }

  Widget buildTextField(
    String label,
    String prefix,
    TextEditingController c,
    Function(String) f,
  ) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        border: const OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: const TextStyle(
        color: Colors.green,
        fontSize: 25.0,
      ),
      onChanged: f,
    );
  }
}
