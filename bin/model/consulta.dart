// To parse this JSON data, do
//
//     final consulta = consultaFromJson(jsonString);

import 'dart:convert';

Consulta consultaFromJson(String str) => Consulta.fromJson(json.decode(str));

String consultaToJson(Consulta data) => json.encode(data.toJson());

class Consulta {
    String id = '';
    bool libre;
    String medico;
    String paciente;

    Consulta({
        required this.libre,
        required this.medico,
        required this.paciente,
    });

    factory Consulta.fromJson(Map<String, dynamic> json) => Consulta(
        libre: json["libre"],
        medico: json["medico"],
        paciente: json["paciente"],
    );

    Map<String, dynamic> toJson() => {
        "libre": libre,
        "medico": medico,
        "paciente": paciente,
    };

    String toString(){return'''
      Id: $id
      Medico: $medico
      Estado: ${libre ? 'Libre' : 'Ocupado'}
      Paciente: ${libre ? '' : paciente}
''';}
}
