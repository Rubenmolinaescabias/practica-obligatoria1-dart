// To parse this JSON data, do
//
//     final paciente = pacienteFromJson(jsonString);

import 'dart:convert';

Paciente pacienteFromJson(String str) => Paciente.fromJson(json.decode(str));

String pacienteToJson(Paciente data) => json.encode(data.toJson());

class Paciente {
    String id = '';
    String apellidos;
    String dni;
    String nombre;
    int numHistoria;
    String sintomas;

    Paciente({
        required this.apellidos,
        required this.dni,
        required this.nombre,
        required this.numHistoria,
        required this.sintomas,
    });

    factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
        apellidos: json["apellidos"],
        dni: json["dni"],
        nombre: json["nombre"],
        numHistoria: json["numHistoria"],
        sintomas: json["sintomas"],
    );

    Map<String, dynamic> toJson() => {
        "apellidos": apellidos,
        "dni": dni,
        "nombre": nombre,
        "numHistoria": numHistoria,
        "sintomas": sintomas,
    };

    String toString(){return'''
      Numero de historial: $numHistoria
      Nombre: $nombre
      Apellidos: $apellidos
      Dni: $dni
      Sintomas: $sintomas
''';}
}
