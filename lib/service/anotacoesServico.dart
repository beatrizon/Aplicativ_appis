import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appis_app/models/anotacoes_modelo.dart';

class AnotacoesServico {
  String userId;
  AnotacoesServico() : userId = FirebaseAuth.instance.currentUser!.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarAnotacoes({
    required String idApiario,
    required AnotacoesModelo anotacoesModelo,
  }) async {
    return await _firestore
        .collection(userId)
        .doc(idApiario)
        .collection("anotacoes")
        .doc(anotacoesModelo.id)
        .set(anotacoesModelo.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conectarStream({required String idApiario}) {
    return _firestore
        .collection(userId)
        .doc(idApiario)
        .collection("anotacoes")
        .orderBy("data", descending: true)
        .snapshots();
        

  }

  Future<void> removerAnotacao({
  required String apiarioId,
  required String anotacoesId,
}) async {
  try {
    await _firestore
        .collection(userId)
        .doc(apiarioId)
        .collection("anotacoes")
        .doc(anotacoesId)
        .delete();
  } catch (e) {
    throw Exception("Erro ao excluir a anotação: $e");
  }
}
}
