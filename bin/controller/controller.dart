import '../model/medico.dart';
import '../model/consulta.dart';
import '../model/paciente.dart';
import '../service/consulta_service.dart' as consultaService;
import '../service/medico_service.dart' as medicoService;
import '../service/paciente_service.dart' as pacienteService;
import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

Future<int> numMedicos() async{
  List<Medico> medicos = await medicoService.leeMedicos();
  return medicos.length;
}

Future<int> numConsultasLibres() async{
  List<Consulta> consultas = await consultaService.leeConsultasLibres();
  return consultas.length;
}

Future<Paciente?> buscaPacienteNumHistoria(int numHistoria) async {
  Paciente? paciente = await pacienteService.leePacienteNumHistoria(numHistoria);
  return paciente;
} // Puede devolver null

Future<int> liberaConsulta(Consulta consulta) async {
  pacienteService.deletePaciente(consulta.paciente);
  List<Paciente> pacientesCola = await leePacientesCola();
  if (pacientesCola.isNotEmpty) consulta.paciente = pacientesCola.first.id;
  else {
    consulta.libre = true;
    consulta.paciente = '';
  }
  int response = await consultaService.modificaConsulta(consulta);
  return response;
}

Future<int> asignaConsultasInicial() async {
  int code = 0;
  List<Consulta> consultasLibres =  await leeConsultasLibres();
  List<Paciente> pacientesCola = await leePacientesCola();
  if (consultasLibres.isEmpty || pacientesCola.isEmpty) return 200;
  for (final c in consultasLibres) {
    if (pacientesCola.isEmpty) break;

    final temp = pacientesCola.removeAt(0);
    c.paciente = temp.id;
    c.libre = false;

    code = await consultaService.modificaConsulta(c);
  }
  return code;
}

Future<int> asignaConsulta(Paciente paciente) async {
  List<Consulta?> consultas = await leeConsultas();
  Consulta? consulta = consultas.firstWhereOrNull(
    (c) => c != null && c.libre
  );
  
  if (consulta == null) return 0;
  consulta.libre = false;
  consulta.paciente = paciente.id;
  int response = await consultaService.modificaConsulta(consulta);
  return response;
}

Future<List<Paciente>> leePacientesCola() async {
  List<String> idsPacientes = await consultaService.leeIdPacientes();
  List<Paciente> pacientes = await pacienteService.leePacientes();
  return pacientes.where((p) => !idsPacientes.contains(p.id)).toList();
}

Future<List<Consulta>> leeConsultas() async {
  List<Consulta> consultas = await consultaService.leeConsultas();
  return consultas;
}

Future<List<Consulta>> leeConsultasLibres() async {
  List<Consulta> consultas = await consultaService.leeConsultasLibres();
  return consultas;
}

Future<List<Consulta>> leeConsultasOcupadas() async {
  List<Consulta> consultas = await consultaService.leeConsultasOcupadas();
  return consultas;
}

Future<Paciente?> buscaPacienteId(String id) async {
  Paciente? paciente = await pacienteService.leePacienteId(id);
  return paciente;
}

Future<Medico?> buscaMedicoId(String id) async {
  Medico? medico = await medicoService.leeMedicoId(id);
  return medico;
}

Future<int> generaNumHistoria() async {
  while(true){
    final random = Random();
    int numero = random.nextInt(10000);
    Paciente? p = await buscaPacienteNumHistoria(numero);
    if(p == null) return numero;
  }
}

Future<int> creaPaciente(String? dni, String? nombre, String? apellidos, String? sintomas) async {
  if (dni == null || nombre == null || apellidos == null || sintomas == null) return 0;
  int numHistoria = await generaNumHistoria();
  Map<String, dynamic> response = await pacienteService.creaPaciente(new Paciente(apellidos: apellidos, dni: dni, nombre: nombre, numHistoria: numHistoria, sintomas: sintomas));
  int code = response['codigoRespuesta'];
  Paciente p = Paciente.fromJson(response['paciente']);
  p.id = response['paciente']['id'];
  asignaConsulta(p);
  return code;
}
