import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';
import 'package:appis_app/models/anotacoes_modelo.dart';
import 'package:appis_app/assets/components/NavBar.dart';

class ApiarioTela extends StatelessWidget {
  final AnotacoesModelo anotacao;

  const ApiarioTela({required this.anotacao, Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: paletaDeCores.fundoApp,
    appBar: AppBar(
      title: const Text(
        'Detalhes da Anotação',
        style: TextStyle(color: Colors.black), // Texto em preto
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.black), // Ícone em preto
          onPressed: () {
            // Lógica para sair da aplicação
          },
        ),
      ],
      backgroundColor: Colors.amber[800], // Amarelo escuro
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ID: ${anotacao.id}'),
          Text('Anotação: ${anotacao.anotacoes}'),
          Text('Data: ${anotacao.data}'),
        ],
      ),
    ),
    bottomNavigationBar: buildBottomNavigationBar(context, 2),
  );
}

}
