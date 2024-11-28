import 'package:appis_app/assets/colors/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/telas/Autenticacao.dart';

import 'package:appis_app/assets/components/NavBar.dart';

class SobrePage extends StatefulWidget {
  const SobrePage({Key? key});

  @override
  State<SobrePage> createState() => _SobrePageState();
}

class _SobrePageState extends State<SobrePage> {
  int _selectedIndex = 3; // Índice inicial (Sobre)

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      appBar: AppBar(
        title: const Text(
          'Sobre',
          style: TextStyle(color: Colors.black), // Define a cor preta para o texto
        ),
        backgroundColor: paletaDeCores.amareloClaro, // Define a cor para o AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ícone de seta
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
        foregroundColor: Colors.black, // Cor dos ícones
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: paletaDeCores.amareloClaro,
              ),
              child: Text(
                'Sair',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Deslogar'),
              onTap: () {
                // Ação de deslogar aqui
              }
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 40,
          top: 32,
          right: 40,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('lib/assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aplicativo desenvolvido com o objetivo de '
                'colaborar com o controle, administração e apoio a tomada e '
                'proposição do local de inserção de colônias em apiárias e '
                'meliponários de maneira a permitir aos produtores o '
                'planejamento de suas atividades apícolas e consorciamentos.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Desenvolvedores:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beatriz Silva'),
                Text('Barbara Beatriz'),
                Text('Tiago Segato'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex),
    );
  }
}
