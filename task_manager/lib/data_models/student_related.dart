// student_related.dart

import 'package:task_manager/data_models/conditions.dart';
import 'package:task_manager/data_models/school_related.dart';

// Aluno Especial Model
class AlunoEspecial {
  int? id;
  String nome;
  String responsavel;
  int idade;
  CondicaoEspecial condicao;
  List<Atividade> atividades = [];

  AlunoEspecial({
    this.id,
    required this.nome,
    required this.responsavel,
    required this.idade,
    required this.condicao,
  });
}


// Tipo de Dificuldade Enum
enum TipoDificuldade { facil, media, dificil }

// Atividade Model
class Atividade {
 int? id;
 String titulo;
 String descricao;
 String objetivo;
 Professor professor;
 Disciplina disciplina;
 TipoDificuldade dificuldade;
 DateTime dataHora;
 List<String> dificuldadesEncontradas = [];
 List<String> habilidadesIdentificadas = [];

 Atividade({this.id, required this.titulo, required this.descricao, required this.objetivo, required this.professor, required this.disciplina, required this.dificuldade, required this.dataHora});
}