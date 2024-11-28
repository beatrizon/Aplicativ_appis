import 'package:appis_app/assets/colors/colors.dart';
import 'package:appis_app/assets/components/EstiloCampoFormulario.dart';
import 'package:appis_app/models/anotacoes_modelo.dart';
import 'package:appis_app/models/cadastroApiarios.dart';
import 'package:appis_app/service/apiarioServico.dart';
import 'package:appis_app/service/anotacoesServico.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

mostrarModalInicio(BuildContext context, {ApiariosModelo? apiario}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: paletaDeCores.fundoApp,
    isDismissible: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return ApiarioModal(apiariosModelo: apiario);
    },
  );
}

class ApiarioModal extends StatefulWidget {
  final ApiariosModelo? apiariosModelo;

  const ApiarioModal({super.key, this.apiariosModelo});

  @override
  State<ApiarioModal> createState() => _ApiarioModalState();
}

class _ApiarioModalState extends State<ApiarioModal> {
  final TextEditingController _descricaoCtrl = TextEditingController();
  final TextEditingController _apelidoCtrl = TextEditingController();
  final TextEditingController _localizacaoCtrl = TextEditingController();
  final TextEditingController _dataInicioCtrl = TextEditingController();
  final TextEditingController _tipoAbelhaCtrl = TextEditingController();
  final TextEditingController _qtdColmeiasCtrl = TextEditingController();
  final TextEditingController _anotacoesCtrl = TextEditingController();

  bool isCarregando = false;
  final ApiarioServico _apiarioServico = ApiarioServico();

  @override
  void initState() {
    super.initState();
    if (widget.apiariosModelo != null) {
      _apelidoCtrl.text = widget.apiariosModelo!.apelido;
      _descricaoCtrl.text = widget.apiariosModelo!.descricao;
      _localizacaoCtrl.text = widget.apiariosModelo!.localizacao ?? '';
      _dataInicioCtrl.text = widget.apiariosModelo!.dateStart;
      _tipoAbelhaCtrl.text = widget.apiariosModelo!.tipoAbelha;
      _qtdColmeiasCtrl.text = widget.apiariosModelo!.qtdColmeias;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null && pickedDate != DateTime.now()) {
    setState(() {
      // Formate a data para o formato dd/MM/yyyy
      _dataInicioCtrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }
}

  Future<void> _obterLocalizacaoAtual() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Serviço de localização desativado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('Permissão de localização negada');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _localizacaoCtrl.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  Future<void> _showOpenMapDialog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (LatLng location) {
            setState(() {
              _localizacaoCtrl.text = '${location.latitude}, ${location.longitude}';
            });
          },
        ),
      ),
    );
  }

  void _showLocationConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deseja inserir a localização atual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _obterLocalizacaoAtual();
                Navigator.of(context).pop();
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
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(32),
        height: MediaQuery.of(context).size.height * 0.9,
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          (widget.apiariosModelo != null)
                              ? "Editar ${widget.apiariosModelo!.apelido}"
                              : "Entre com as informações sobre sua produção",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apelidoCtrl,
                        decoration: getAuthenticationInputDecoration(
                          "Apelido",
                          icon: const Icon(Icons.hive),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoCtrl,
                        decoration: getAuthenticationInputDecoration(
                          "Descrição",
                          icon: const Icon(Icons.note),
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _localizacaoCtrl,
                              decoration: getAuthenticationInputDecoration(
                                "Localização",
                                icon: const Icon(Icons.location_on),
                              ),
                              onTap: () {
                                _showLocationConfirmationDialog(context);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: () => _showOpenMapDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context), // Ação para abrir o calendário
                        child: AbsorbPointer( // Absorve o toque para garantir que só o calendário seja aberto
                          child: TextFormField(
                            controller: _dataInicioCtrl,
                            decoration: getAuthenticationInputDecoration(
                              "Data Início",
                              icon: const Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tipoAbelhaCtrl,
                        decoration: getAuthenticationInputDecoration(
                          "Tipo Abelha",
                          icon: const Icon(Icons.bug_report),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _qtdColmeiasCtrl,
                        decoration: getAuthenticationInputDecoration(
                          "Quantidade de Colmeias",
                          icon: const Icon(Icons.format_list_numbered),
                        ),
                      ),
                      Visibility(
                        visible: (widget.apiariosModelo == null),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _anotacoesCtrl,
                              decoration: getAuthenticationInputDecoration(
                                "Anotações",
                                icon: const Icon(Icons.edit),
                              ),
                              maxLines: null,
                            ),
                            const Text(
                              'Você não precisa preencher as anotações agora',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  enviarClicando();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      paletaDeCores.amareloClaro),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(paletaDeCores.preto),
                ),
                child: (isCarregando)
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : Text((widget.apiariosModelo != null)
                        ? "Salvar"
                        : "Criar Apiário"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void enviarClicando() {
  // Verificar se todos os campos obrigatórios estão preenchidos
  if (_apelidoCtrl.text.isEmpty ||
      _descricaoCtrl.text.isEmpty ||
      _localizacaoCtrl.text.isEmpty ||
      _dataInicioCtrl.text.isEmpty ||
      _tipoAbelhaCtrl.text.isEmpty ||
      _qtdColmeiasCtrl.text.isEmpty) {
    // Exibir a mensagem de erro como um AlertDialog
    _showErrorDialog();
    return; // Não prosseguir com o envio se algum campo obrigatório estiver vazio
  }

  setState(() {
    isCarregando = true;
  });

  String nome = _apelidoCtrl.text;
  String descricao = _descricaoCtrl.text;
  String localizacao = _localizacaoCtrl.text;
  String dataInicio = _dataInicioCtrl.text;
  String tipoAbelha = _tipoAbelhaCtrl.text;
  String quantidadeColemias = _qtdColmeiasCtrl.text;
  String anotacoes = _anotacoesCtrl.text;

  ApiariosModelo apiario = ApiariosModelo(
    id: Uuid().v1(),
    apelido: nome,
    descricao: descricao,
    localizacao: localizacao,
    dateStart: dataInicio,
    tipoAbelha: tipoAbelha,
    qtdColmeias: quantidadeColemias,
  );

  if (widget.apiariosModelo != null) {
    apiario.id = widget.apiariosModelo!.id;
  }

  _apiarioServico.AdicionarApiarios(apiario).then((value) {
    if (anotacoes.isNotEmpty) {
      AnotacoesModelo anotacao = AnotacoesModelo(
        id: Uuid().v1(),
        anotacoes: anotacoes,
        data: DateTime.now().toString(),
      );

      AnotacoesServico()
          .adicionarAnotacoes(
            idApiario: apiario.id, // Certifique-se de usar o ID do apiário aqui
            anotacoesModelo: anotacao,
          )
          .then((value) {
        setState(() {
          isCarregando = false;
        });
        Navigator.pop(context);
      }).catchError((error) {
        setState(() {
          isCarregando = false;
        });
        print("Erro ao adicionar anotações: $error");
      });
    } else {
      setState(() {
        isCarregando = false;
      });
      Navigator.pop(context);
    }
  }).catchError((error) {
    setState(() {
      isCarregando = false;
    });
    print("Erro ao adicionar apiário: $error");
  });
}

// Função para exibir o AlertDialog com a mensagem de erro
void _showErrorDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // Impede que o diálogo seja fechado ao tocar fora dele
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Erro'),
        content: const Text('Você deve preencher todos os campos para salvar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o AlertDialog
            },
          ),
        ],
      );
    },
  );
}


}

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(
        _currentLocation!, 15); // Move o mapa para a localização atual
  }

  void _onMapTap(LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deseja inserir neste local?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLocationSelected(location);
                Navigator.of(context).pop(); // Fecha o mapa
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
  backgroundColor: paletaDeCores.amareloClaro, // Cor de fundo da AppBar
  title: const Text(
    'Selecione um Local',
    style: TextStyle(color: Colors.black), // Cor preta para o texto
  ),
  leading: IconButton(
    icon: const Icon(Icons.close, color: Colors.black), // Cor preta para o ícone
    onPressed: () => Navigator.of(context).pop(),
  ),
),

      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 15.0,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        builder: (ctx) => const Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
