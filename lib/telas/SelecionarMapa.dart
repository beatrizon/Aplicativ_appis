import 'package:appis_app/assets/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;
  LatLng? _markerLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Solicita a localização com alta precisão
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markerLocation = _currentLocation; // Inicializa o marcador na localização atual
      });

      // Movimenta o mapa para a localização após um pequeno atraso para garantir que a renderização foi concluída
      Future.delayed(Duration(milliseconds: 500), () {
        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, 15); // Move o mapa para a localização atual
        }
      });
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _markerLocation = location; // Atualiza a posição do marcador quando clica
    });

    // Exibe o diálogo para confirmação da localização
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tem certeza que deseja inserir nessa localização?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLocationSelected(location); // Passa a localização selecionada
              },
              child: const Text('Sim', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecione um Local',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: paletaDeCores.amareloClaro, // Cor da AppBar: amarelo claro
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 15.0,
                onTap: (tapPosition, point) {
                  _onMapTap(point); // Chama _onMapTap diretamente ao clicar
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        builder: (ctx) => const Icon(Icons.person_pin_circle, color: Colors.blue), // Ícone do usuário
                      ),
                    if (_markerLocation != null)
                      Marker(
                        point: _markerLocation!,
                        builder: (ctx) => const Icon(
                          Icons.location_on, 
                          color: Colors.red, // Cor do marcador
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
