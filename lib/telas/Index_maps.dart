import 'package:appis_app/assets/components/NavBar.dart';
import 'package:appis_app/service/autenticacaoServico.dart';
import 'package:appis_app/telas/Visualizar_Producoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appis_app/service/apiarioServico.dart';
import 'package:appis_app/models/cadastroApiarios.dart';
import 'package:appis_app/assets/colors/colors.dart';
import 'package:geolocator/geolocator.dart'; // Adicione essa linha

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  int _selectedIndex = 1;
  List<Marker> _apiarioMarkers = [];
  bool _isLoading = true;
  List<ApiariosModelo> _apiariosList = [];
  LatLng? _currentLocation; // Variável para armazenar a localização atual

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  void _onMarkerTapped(ApiariosModelo apiario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesApiario(apiario),
      ),
    );
  }

  Future<void> _fetchApiarios() async {
    setState(() {
      _isLoading = true;
    });

    ApiarioServico apiarioServico = ApiarioServico();
    try {
      List<ApiariosModelo> apiarios = await apiarioServico.fetchApiarios();
      setState(() {
        _apiariosList = apiarios;
        _apiarioMarkers = apiarios.map((apiario) {
          List<String> coords = apiario.localizacao?.split(',') ?? ['0', '0'];
          double latitude = double.tryParse(coords[0]) ?? 0.0;
          double longitude = double.tryParse(coords[1]) ?? 0.0;

          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(latitude, longitude),
            builder: (ctx) => GestureDetector(
              onTap: () => _onMarkerTapped(apiario),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          );
        }).toList();
      });
    } catch (e) {
      print('Erro ao buscar apiários: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função que pede permissão para acessar a localização
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão ativados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Se os serviços de localização não estão habilitados, mostramos um Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Os serviços de localização estão desabilitados. O mapa será exibido com a localização padrão."),
          duration: Duration(seconds: 5),
        ),
      );
      // Definimos a localização padrão
      setState(() {
        _currentLocation = LatLng(-15.753929436524059, -47.8792730725485); // Localização padrão
      });
      return;
    }

    // Solicita a permissão para acessar a localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Se a permissão for negada, mostramos um Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permissão de localização negada. O mapa será exibido com a localização padrão."),
            duration: Duration(seconds: 5),
          ),
        );
        // Definimos a localização padrão
        setState(() {
          _currentLocation = LatLng(-15.753929436524059, -47.8792730725485); // Localização padrão
        });
        return;
      }
    }

    // Caso a permissão tenha sido concedida, obtemos a localização
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtém a localização atual
    _fetchApiarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa de Apiários',
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        backgroundColor: paletaDeCores.amareloClaro,
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
                'Menu',
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
                AutenticacaoServico().deslogar();
              },
            ),
          ],
        ),
      ),
      backgroundColor: paletaDeCores.fundoApp,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _currentLocation ?? LatLng(-15.753929436524059, -47.8792730725485),
                zoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _apiarioMarkers,
                ),
                // Removemos o CircleLayer que mostrava o círculo amarelo
              ],
            ),
      bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex),
    );
  }
}
