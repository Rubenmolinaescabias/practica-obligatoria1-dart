import '../model/paciente.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:collection/collection.dart';

final String _url = 'https://practica-obligatoria1-30c54-default-rtdb.europe-west1.firebasedatabase.app/';

Future<List<Paciente>> leePacientes() async {
  Uri uri = Uri.parse('${_url}paciente.json');
  List<Paciente> pacientes = [];
  
  Response response = await get(uri);
  if (response.statusCode != 200) return pacientes;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Paciente temp = Paciente.fromJson(obj);
    temp.id = id;
    pacientes.add(temp);
  });
  return pacientes;
}

Future<List<Paciente>> leePacientesCola(List<String> idsPacientesEnConsulta) async {
  Uri uri = Uri.parse('${_url}paciente.json');
  List<Paciente> pacientes = [];
  
  Response response = await get(uri);
  if (response.statusCode != 200) return pacientes;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  mapa.forEach((id, obj){
    Paciente temp = Paciente.fromJson(obj);
    temp.id = id;
    if (!idsPacientesEnConsulta.contains(id)) pacientes.add(temp);
  });
  return pacientes;
}

Future<Paciente?> leePacienteNumHistoria(int numHistoria) async {
  Uri uri = Uri.parse('${_url}paciente.json');

  Response response = await get(uri);
  if (response.statusCode != 200) return null;

  Map<String,dynamic> mapa = jsonDecode(response.body);
  return mapa.entries
    .map((e) => Paciente.fromJson(e.value)..id = e.key)
    .firstWhereOrNull((p) => p.numHistoria == numHistoria);
}

Future<Paciente?> leePacienteId(String id) async {
  if (id == '') return null;
  Uri uri = Uri.parse('${_url}paciente/$id.json');

  Response response = await get(uri);
  if (response.statusCode != 200) return null;

  final data = jsonDecode(response.body);

  if(data == null) return null;

  final paciente = Paciente.fromJson(data);
  paciente.id = id;

  return paciente;
}

Future<int> deletePaciente(String id) async {
    Uri uri = Uri.parse('$_url/paciente/${id}.json');

    Response response = await delete(uri);

    return response.statusCode;
  }

Future<Map<String, dynamic>> creaPaciente(Paciente paciente) async {
  Uri uri = Uri.parse('$_url/paciente.json');

  Response response = await post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(paciente.toJson()),
  );
  final Map<String, dynamic> data = jsonDecode(response.body);
  final String id = data['name'];

  Map<String, dynamic> mapaResultado = {
        "codigoRespuesta": response.statusCode,
        "paciente": {
          "id": id,
          "apellidos": paciente.apellidos,
          "dni": paciente.dni,
          "nombre": paciente.nombre,
          "numHistoria": paciente.numHistoria,
          "sintomas": paciente.sintomas
        }
    };
  return mapaResultado;
}