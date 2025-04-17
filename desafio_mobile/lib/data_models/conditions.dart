// conditions.dart

sealed class CondicaoEspecial {
  const CondicaoEspecial();
}

class Autismo extends CondicaoEspecial {
  const Autismo();
}

class Tdah extends CondicaoEspecial {
  const Tdah();
}

class SindromeDown extends CondicaoEspecial {
  const SindromeDown();
}

class Dislexia extends CondicaoEspecial {
  const Dislexia();
}

class DeficienciaVisual extends CondicaoEspecial {
  const DeficienciaVisual();
}

class DeficienciaAuditiva extends CondicaoEspecial {
  const DeficienciaAuditiva();
}

class Outras extends CondicaoEspecial {
  const Outras();
}

class OutraCondicaoCustomizada extends CondicaoEspecial {
  final String descricao;

  const OutraCondicaoCustomizada(this.descricao);
}
