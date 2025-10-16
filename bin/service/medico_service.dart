import '../model/medico.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

final String _url = 'https://practica-obligatoria1-30c54-default-rtdb.europe-west1.firebasedatabase.app/';

Future<List<Medico>> leeMedicos() async {
  Uri uri = Uri.parse('${_url}medicos.json');
  List<Medico> medicos = [];

  Response response = await get(uri);
  if (response.statusCode != 200) return medicos;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Medico temp = Medico.fromJson(obj);
    temp.id = id;
    medicos.add(temp);
  });
  return medicos;
}

Future<Medico?> leeMedicoId(String id) async {
  Uri uri = Uri.parse('${_url}medicos/$id.json');

  Response response = await get(uri);
  if (response.statusCode != 200) return null;

  final data = jsonDecode(response.body);

  if(data == null) return null;

  final medico = Medico.fromJson(data);
  medico.id = id;

  return medico;
}