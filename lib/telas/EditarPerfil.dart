import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';

class EditPerfil extends StatefulWidget {
  const EditPerfil({Key? key}) : super(key: key);

  @override
  State<EditPerfil> createState() => _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEditingPassword = false;
  bool _isEditingName = false;
  String? _oldPassword;
  String? _newPassword;
  String? _confirmPassword;
  String? _newName;
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;

        final cred = EmailAuthProvider.credential(
          email: user!.email!,
          password: _oldPassword!,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPassword!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nova senha cadastrada')),
        );
        setState(() {
          _isEditingPassword = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateName() async {
    try {
      User? user = _auth.currentUser;
      await user!.updateDisplayName(_newName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome atualizado com sucesso')),
      );
      setState(() {
        _isEditingName = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: paletaDeCores.preto, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        obscureText: obscureText,
        initialValue: initialValue,
        validator: validator,
        enabled: enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    _nameController.text = user?.displayName ?? '';

    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: paletaDeCores.preto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Removido o fundo branco aqui
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Nome:',
                          controller: _nameController,
                          enabled: _isEditingName,
                        ),
                      ),
                      if (_isEditingName)
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _newName = _nameController.text;
                              _updateName();
                            });
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditingName = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16), // Espaçamento entre os campos
                  _buildTextField(
                    label: 'Email:',
                    controller: TextEditingController(text: user?.email),
                    enabled: false,
                  ),
                  const SizedBox(height: 16), // Espaçamento entre os campos
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Senha:',
                          controller: TextEditingController(text: '****'),
                          enabled: false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingPassword = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isEditingPassword)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Senha Anterior',
                            controller: _oldPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a senha antiga';
                              }
                              _oldPassword = value;
                              return null;
                            },
                          ),
                          const SizedBox(
                              height: 16), // Espaçamento entre os campos
                          _buildTextField(
                            label: 'Nova Senha',
                            controller: _newPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a nova senha';
                              }
                              _newPassword = value;
                              return null;
                            },
                          ),
                          const SizedBox(
                              height: 20), // Espaçamento entre os campos
                          _buildTextField(
                            label: 'Confirmar Nova Senha',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value != _newPasswordController.text) {
                                return 'As senhas não coincidem';
                              }
                              _confirmPassword = value;
                              return null;
                            },
                          ),
                          const SizedBox(
                              height: 20), // Espaçamento entre os campos
                          ElevatedButton(
                            onPressed: _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: paletaDeCores.amareloClaro,
                            ),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
