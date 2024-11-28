import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appis_app/models/anotacoes_modelo.dart';
import 'package:appis_app/models/cadastroApiarios.dart';

class ApiarioServico {
  String userId;

  ApiarioServico() : userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Método para adicionar um apiário
  Future<void> AdicionarApiarios(ApiariosModelo apiariosModelo) async {
    return await _firestore
        .collection(userId)
        .doc(apiariosModelo.id)
        .set(apiariosModelo.toMap());
  }

  Future<List<ApiariosModelo>> fetchApiarios() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection(userId).get();
      List<ApiariosModelo> apiariosList = snapshot.docs.map((doc) {
        return ApiariosModelo.fromMap(doc.data());
      }).toList();

      return apiariosList;
    } catch (e) {
      print('Erro ao buscar apiários: $e');
      return [];
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conectarStreamApiarios() {
    return _firestore.collection(userId).snapshots();
  }

  Future<List<AnotacoesModelo>> fetchAnotacoes(String idApiario) async {
  QuerySnapshot snapshot = await _firestore
      .collection(userId)
      .doc(idApiario)
      .collection('anotacoes') // Acessa a subcoleção "anotações"
      .orderBy('data', descending: true) // Ordena por data, mais recente primeiro
      .get();

  return snapshot.docs
      .map((doc) => AnotacoesModelo.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}

  Future<void> removerApiario({required String idApiario}) {
    return _firestore.collection(userId).doc(idApiario).delete();
  }
  
  
}
