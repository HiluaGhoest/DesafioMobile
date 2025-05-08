// school_related.dart

// Escola Model
class Escola {
 int? id;
 String nome;
 String diretor;
 String coordenadorInclusao;

 Escola({this.id, required this.nome, required this.diretor, required this.coordenadorInclusao});
}

// Curso Model
class Curso {
 int? id;
 String nome;
 String tipo;

 Curso({this.id, required this.nome, required this.tipo});
}

class Professor {
 final String id;
 final String nome;

 Professor({required this.id, required this.nome});

 factory Professor.fromJson(Map<String, dynamic> json) {
 return Professor(
 id: json['id'],
 nome: json['nome'],
 );
 }
}

class Disciplina {
 final String id;
 final String nome;

 Disciplina({required this.id, required this.nome});

 factory Disciplina.fromJson(Map<String, dynamic> json) {
 return Disciplina(
 id: json['id'],
 nome: json['nome'],
 );
 }
}
