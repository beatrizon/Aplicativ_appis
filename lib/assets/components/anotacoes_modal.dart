import "package:appis_app/models/anotacoes_modelo.dart";
import "package:appis_app/models/cadastroApiarios.dart";
import "package:appis_app/service/anotacoesServico.dart";
import "package:flutter/material.dart";
import "package:uuid/uuid.dart";

Future<dynamic> mostrarAdicionarAnotacoes(
  BuildContext context, {
  required String idApiario,
  AnotacoesModelo? anotacoesModelo,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      TextEditingController anotacoesController = TextEditingController();

      if (anotacoesModelo != null) {
        anotacoesController.text = anotacoesModelo.anotacoes;
      }

      return AlertDialog( 
        title: const Text("Qual anotação deseja inserir?"),
        content: TextFormField(
          controller: anotacoesController,
          decoration: const InputDecoration(
            label: Text("Anote"),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              AnotacoesModelo novaAnotacao = AnotacoesModelo(
                // Use o nome da classe aqui
                id: anotacoesModelo?.id ?? const Uuid().v1(),
                anotacoes: anotacoesController.text,
                data: anotacoesModelo?.data ?? DateTime.now().toString(),
              );
              if (anotacoesModelo != null) {
                novaAnotacao.id = anotacoesModelo.id;
              }

              AnotacoesServico().adicionarAnotacoes(
                  idApiario: idApiario, anotacoesModelo: novaAnotacao);

              Navigator.pop(context, novaAnotacao);
            },
            child: Text((anotacoesModelo != null)
                ? "Editar anotações"
                : "Criar anotações"),
          ),
        ],
      );
    },
  );
}
