import '../model/consulta.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

final String _url = 'https://practica-obligatoria1-30c54-default-rtdb.europe-west1.firebasedatabase.app/';

Future<List<Consulta>> leeConsultas() async {
  Uri uri = Uri.parse('${_url}consultas.json');
  List<Consulta> consultas = [];

  Response response = await get(uri);
  if (response.statusCode != 200) return consultas;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Consulta temp = Consulta.fromJson(obj);
    temp.id = id;
    consultas.add(temp);
  });
  return consultas;
}

Future<List<Consulta>> leeConsultasLibres() async {
  Uri uri = Uri.parse('${_url}consultas.json');
  List<Consulta> consultas = [];

  Response response = await get(uri);
  if (response.statusCode != 200) return consultas;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Consulta temp = Consulta.fromJson(obj);
    temp.id = id;
    if (temp.libre) consultas.add(temp);
  });
  return consultas;
}
Future<List<Consulta>> leeConsultasOcupadas() async {
  Uri uri = Uri.parse('${_url}consultas.json');
  List<Consulta> consultas = [];

  Response response = await get(uri);
  if (response.statusCode != 200) return consultas;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Consulta temp = Consulta.fromJson(obj);
    temp.id = id;
    if (!temp.libre) consultas.add(temp);
  });
  return consultas;
}

Future<List<String>> leeIdPacientes() async {
  Uri uri = Uri.parse('${_url}consultas.json');
  List<String> pacientes = [];

  Response response = await get(uri);
  if (response.statusCode != 200) return pacientes;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Consulta temp = Consulta.fromJson(obj);
    if (!temp.libre) pacientes.add(temp.paciente);
  });
  return pacientes;
}

Future<int> modificaConsulta(Consulta consulta) async {
  Uri uri = Uri.parse('$_url/consultas/${consulta.id}.json');

  Response response = await put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(consulta.toJson()),
  );

  return response.statusCode;
}