// To parse this JSON data, do
//
//     final medico = medicoFromJson(jsonString);

import 'dart:convert';

Medico medicoFromJson(String str) => Medico.fromJson(json.decode(str));

String medicoToJson(Medico data) => json.encode(data.toJson());

class Medico {
    String especialidad;
    String id = '';
    String nombre;

    Medico({
        required this.especialidad,
        required this.nombre,
    });

    factory Medico.fromJson(Map<String, dynamic> json) => Medico(
        especialidad: json["especialidad"],
        nombre: json["nombre"],
    );

    Map<String, dynamic> toJson() => {
        "especialidad": especialidad,
        "nombre": nombre,
    };

    String toString(){return '''
      Id: $id
      Nombre: $nombre
      Especialidad: $especialidad
    ''';}
}
