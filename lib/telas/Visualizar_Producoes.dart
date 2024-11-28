import 'package:appis_app/assets/components/anotacoes_modal.dart';
import 'package:appis_app/service/anotacoesServico.dart';
import 'package:appis_app/service/apiarioServico.dart';
import 'package:appis_app/telas/AdicionarApiarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/assets/components/NavBar.dart';
import 'package:appis_app/assets/colors/colors.dart';
import 'package:appis_app/models/anotacoes_modelo.dart';
import 'package:appis_app/models/cadastroApiarios.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisualizarProducoes extends StatefulWidget {
  final ApiarioServico servico = ApiarioServico();

  VisualizarProducoes({super.key});

  @override
  _VisualizarProducoesState createState() => _VisualizarProducoesState();
}

class _VisualizarProducoesState extends State<VisualizarProducoes> {
  bool _isAscending = true; // Variável para controle da ordenação

  // Função que realiza a ordenação da lista de apiários
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending; // Alterna a direção da ordenação
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissão de localização foi negada permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
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
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Deslogar'),
              onTap: () {
                _signOut(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Minhas produções",
          style: TextStyle(color: Colors.black), // Texto em preto
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ícone de seta para voltar
          onPressed: () {
            Navigator.of(context).pop(); // Voltar para a tela anterior
          },
        ),
        backgroundColor: paletaDeCores.amareloClaro,
        actions: [
          // Botão para alternar a ordem de ordenação
          IconButton(
  icon: Icon(
    _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
    color: Colors.black,
  ),
  onPressed: _toggleSortOrder,
),

        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          backgroundColor: paletaDeCores.amareloClaro,
          foregroundColor: Colors.black, // Define a cor do texto como preto
          onPressed: () {
            mostrarModalInicio(context);
          },
          label: const Text("Nova Produção"),
          icon: const Icon(Icons.edit),
        ),
      ),
      body: StreamBuilder(
        stream: widget.servico.conectarStreamApiarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.docs.isNotEmpty) {
              List<ApiariosModelo> listaApiario = [];

              for (var doc in snapshot.data!.docs) {
                listaApiario.add(
                    ApiariosModelo.fromMap(doc.data() as Map<String, dynamic>));
              }

              // Ordenar a lista conforme a ordem selecionada
              listaApiario.sort((a, b) {
                int comparison = a.apelido.compareTo(b.apelido);
                return _isAscending ? comparison : -comparison;
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: listaApiario.length,
                itemBuilder: (context, index) {
                  var apiarioModelo = listaApiario[index];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: paletaDeCores.fundoApp,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalhesApiario(apiarioModelo),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.asset(
                          "lib/assets/images/apiario.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          apiarioModelo.apelido,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                            apiarioModelo.dateStart ?? 'Data não especificada'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                mostrarModalInicio(context,
                                    apiario: apiarioModelo);
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                SnackBar snackBar = SnackBar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 235, 95, 85),
                                  content: Text(
                                      "Deseja remover o apiário ${apiarioModelo.apelido}?"),
                                  action: SnackBarAction(
                                    label: "REMOVER",
                                    textColor: Colors.white,
                                    onPressed: () {
                                      widget.servico.removerApiario(
                                          idApiario: apiarioModelo.id);
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  "Nenhum apiário registrado 😢",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 2),
    );
  }
}

class DetalhesApiario extends StatelessWidget {
  final ApiariosModelo apiario;

  DetalhesApiario(this.apiario);

  @override
  Widget build(BuildContext context) {
    final ApiarioServico servico = ApiarioServico();
    final AnotacoesServico anotacoesServico = AnotacoesServico();

    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      appBar: AppBar(
        title: Text(apiario.apelido),
        backgroundColor: paletaDeCores.amareloClaro, // Cor da AppBar
        foregroundColor: Colors.black, // Cor do texto do título
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostrarAdicionarAnotacoes(context, idApiario: apiario.id);
        },
        backgroundColor: paletaDeCores.amareloClaro, // Cor de fundo
        foregroundColor: Colors.black, // Cor do ícone
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: anotacoesServico.conectarStream(idApiario: apiario.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma anotação registrada 😢",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }

          var anotacoes = snapshot.data!.docs
              .map((doc) => AnotacoesModelo.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apelido: ${apiario.apelido}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                        "Localização: ${apiario.localizacao ?? 'Não especificado'}"),
                    const SizedBox(height: 8.0),
                    Text("Tipo de Abelha: ${apiario.tipoAbelha}"),
                    const SizedBox(height: 8.0),
                    Text(
                        "Quantidade de Colmeias: ${apiario.qtdColmeias}"),
                    const SizedBox(height: 16.0),
                    const Text(
                      "Anotações",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    for (var anotacao in anotacoes)
                      Card(
                        child: ListTile(
                          title: Text(anotacao.anotacoes),
                          subtitle: Text(anotacao.data),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmarExclusao(
                                  context, anotacao, anotacoesServico);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Método para exibir o SnackBar de confirmação
  void _confirmarExclusao(
      BuildContext context, AnotacoesModelo anotacao, AnotacoesServico anotacoesServico) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Deseja excluir esta anotação?"),
          actions: [
            TextButton(
              onPressed: () {
                // Remover a anotação e voltar para a tela
                anotacoesServico.removerAnotacao(
                  apiarioId: apiario.id,
                  anotacoesId: anotacao.id,
                ).then((_) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Fechar o diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Anotação excluída com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  Navigator.of(context).pop(); // Fechar o diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao excluir a anotação."),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
              child: const Text("Sim", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fechar o diálogo
              child: const Text("Não", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}


