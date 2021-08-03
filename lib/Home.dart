import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//Bibliotecas
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

//Constantes
const key = "e6ebf5b3";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll(){
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarControler.text = (real/dolar).toStringAsFixed(2);
    euroControler.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realControler.text =(dolar*this.dolar).toStringAsFixed(2);
    euroControler.text =(dolar*this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realControler.text= (euro*this.euro).toStringAsFixed(2);
    dolarControler.text= (euro*this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
              onPressed: _clearAll,
            )
          ],
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: Text(
            "\$ Conversor de Moedas \$",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar Dados ",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextField("R\$", "Reais", realControler, _realChanged),
                        Divider(),
                        buildTextField("U\$", "Dólares", dolarControler, _dolarChanged),
                        Divider(),
                        buildTextField("€", "Euro", euroControler, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response _response =
      await http.get(Uri.https("api.hgbrasil.com", "/finance", {"format": "json", "key": key}));
  return json.decode(_response.body);
}

buildTextField(String prefix, String label, TextEditingController controller, Function funcao) {
  return TextField(
    controller: controller,
    style: TextStyle(color: Colors.amber, fontSize: 25.8),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        prefixText: prefix,
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber)),
    onChanged: (text) {
      funcao(controller.text);
    },
  );
}
