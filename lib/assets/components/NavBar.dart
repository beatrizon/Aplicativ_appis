import 'package:appis_app/telas/Visualizar_Producoes.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';
import 'package:appis_app/telas/Visualizar_perfil.dart';
import 'package:appis_app/telas/Index_maps.dart';
import 'package:appis_app/telas/Tela_sobre.dart';

BottomNavigationBar buildBottomNavigationBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    backgroundColor: paletaDeCores.amareloEscuro,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: 'Mapa',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bug_report_outlined), // Ícone de produções
        label: 'Produções',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info),
        label: 'Sobre',
      ),
    ],
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black,
    currentIndex: currentIndex,
    onTap: (int index) {
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ViewPerfil()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapaPage()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VisualizarProducoes()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SobrePage()),
          );
          break;
      }
    },
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );
}
