import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'model/consulta.dart';
import 'model/medico.dart';
import 'model/paciente.dart';
import 'controller/controller.dart' as controller;
void main(List<String> arguments) async{
  int pacientesCurados = 0;
  String? opt;
  final int codigoAsignacionInicial = await controller.asignaConsultasInicial();
  if (codigoAsignacionInicial != 200) print('Ha habido un problema al contactar con el servidor. Codigo de error: $codigoAsignacionInicial');
  do{
    await menuPrincipal(pacientesCurados);
    opt = stdin.readLineSync();
    switch(opt){
      case '1':
        int code = await admitirCliente();
        switch(code){
          case 0: {
            print('No se ha admitido un paciente. Operacion cancelada por usuario'); 
            break;
          }
          case 200: {
            print('El paciente se ha admitido con exito'); 
            break;
          }
          default: print('Ha ocurrido un error al admitir el paciente. Codigo de error: $code');
        }
        pulsaParaContinuar();
        break;
      case '2':
        int code = await liberarConsulta();
        switch(code){
          case 0: {
            print('No se ha liberado ninguna consulta. Operacion cancelada por usuario');
            break;
          }
          case 200: {
            print('Se ha liberado la consulta con exito');
            pacientesCurados ++;
            break;
          }
          default: print('Ha habido un error al liberar una consulta. Codigo de error: $code');
        }
        pulsaParaContinuar();
        break;
      case '3':
        await pintaPacientesCola();
        pulsaParaContinuar();
        break;
      case '4':
        List<Consulta> consultas = await controller.leeConsultas();
        await pintaConsultas(consultas);
        pulsaParaContinuar();
        break;
      case '5':
        await buscaPaciente();
        pulsaParaContinuar();
        break;
      case '6':
        print('Gracias por usar nuestro servicio');
        break;
      default: print('Opcion no valida');
    }
  }while(opt != '6');
}

void pulsaParaContinuar(){
  print('\nPulsa cualquier boton...');
  stdin.readLineSync();
}

Future<void> menuPrincipal(int pacientesCurados) async {
  int numMedicos = await controller.numMedicos();
  int numConsultas = await controller.numConsultasLibres();
  List<Paciente> pacientesCola = await controller.leePacientesCola();
  print('''
  Bienvenido al centro de salud
  ===========================================================
  El numero actual de médicos pasando consulta es: $numMedicos
  Consultas libres: $numConsultas
  Actualmente tenemos ${pacientesCola.length} pacientes en cola
  Hoy hemos curado a $pacientesCurados pacientes
  ===========================================================
  Introduzca una opción:
  1. Admisión de un paciente
  2. Liberar una consulta
  3. Ver la cola de espera
  4. Ver el estado actual de las consultas
  5. Buscar un paciente en el sistema
  6. Salir
''');
}

Future<int> admitirCliente() async {
  if (preguntaContinuar('¿Estas seguro de que quieres registrar un cliente?')){
    print('Introduce el dni');
    String? dni = stdin.readLineSync();
    print('Introduce el nombre');
    String? nombre = stdin.readLineSync();
    print('Introduce el apellidos');
    String? apellidos = stdin.readLineSync();
    print('Introduce el sintomas');
    String? sintomas = stdin.readLineSync();
    if (!preguntaContinuar('¿Quieres registrar este paciete?')) return 0;
    int code = await controller.creaPaciente(dni, nombre, apellidos, sintomas);
    return code;
  }  else return 0; 
}

Future<int> liberarConsulta() async {
  if (preguntaContinuar('¿Estas seguro de que quieres liberar una consulta?')){
    List<Consulta> consultas = await controller.leeConsultasOcupadas();
    if (consultas.isEmpty) {
      print('No hay consultas que vaciar');
      return -1;
    }
    Consulta? consulta = null;
    bool continuar = true;
    while(consulta == null && continuar){
      await pintaConsultas(consultas);
      print('Selecciona la consulta que quieras vaciar');
      int? seleccion = int.tryParse(stdin.readLineSync() ?? '');
      if (seleccion != null && seleccion <= consultas.length && seleccion > 0){
        if(!preguntaContinuar('¿Estas seguro de que quieres liberar la consulta?')) return 0;
        consulta = consultas[seleccion -1];
      }
      if (consulta == null) continuar = preguntaContinuar('No has seleccionado una consulta correctamente. ¿Deseas continuar?');
    }
    if (consulta == null) return 0;
    int code = await controller.liberaConsulta(consulta);
    return code;
  } else return 0;
}

Future<String> detalleConsulta(Consulta c) async{
  Paciente? p = await controller.buscaPacienteId(c.paciente);
  Medico? m = await controller.buscaMedicoId(c.medico);
  return('''
      Medico: ${m == null ? '' : m.nombre}
      Estado: ${c.libre ? 'Libre' : 'Ocupado'}
      Paciente: ${p == null ? '' : '${p.nombre} ${p.apellidos}'}
''');
}

Future<void> pintaConsultas(List<Consulta> consultas) async{
  if (consultas.isEmpty) print('Las consultas no estan disponibles');
  else{
      for (final c in consultas) {
        final String detalle = await detalleConsulta(c);
        print(detalle);
    }
  }
  
}

Future<void> buscaPaciente() async{
  int? numHistoria;
  Paciente? p = null;
  bool continuar = true;
  while(p == null && continuar){
    print('Introduce el numero de historial del paciente');
    String? input = stdin.readLineSync();
    numHistoria = int.tryParse(input ?? '');
    if (numHistoria != null) p = await controller.buscaPacienteNumHistoria(numHistoria);
    if (p != null){
      pintaPaciente(p);
    }else{
      print('El numero de historial que has introducido no existe. ¿Quieres intentarlo de nuevo? (s/n)');
      String? respuesta = stdin.readLineSync();
      if (respuesta == null || respuesta.toLowerCase() != 's') continuar = false;
    }
  }
}

bool preguntaContinuar(String mensaje){
  print('$mensaje (s/n)');
  String? respuesta = stdin.readLineSync();
  if (respuesta != null)return respuesta.toLowerCase() == 's';
  else return false;
}

Future<void> pintaPacientesCola() async {
  List<Paciente> cola = await controller.leePacientesCola();
  if (!cola.isEmpty) cola.forEach((p) => pintaPaciente(p));
  else print('No hay pacientes en cola');
}

void pintaPaciente(Paciente p){
  print('''
  Nombre: ${p.nombre} ${p.apellidos}
  Dni: ${p.dni}
  Numero de historial: ${p.numHistoria}
  Sintomas: ${p.sintomas}
''');

}