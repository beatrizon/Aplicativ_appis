class AnotacoesModelo {
  String id;
  String anotacoes;
  String data;
  

  AnotacoesModelo(
      {required this.id, required this.anotacoes, required this.data});

  AnotacoesModelo.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        anotacoes = map["anotacoes"],
        data = map["data"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "anotacoes": anotacoes,
      "data": data,
    };
  }
}
