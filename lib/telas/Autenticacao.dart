import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';
import 'package:appis_app/assets/components/snakeBar.dart';

class AutenticacaoServico {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> cadastrarUsario({
    required String nome,
    required String senha,
    required String email,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      await userCredential.user!.updateDisplayName(nome);
      return "Cadastro com sucesso";
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O e-mail já está em uso";
      } else if (e.code == "invalid-email") {
        return "O e-mail fornecido é inválido";
      } else if (e.code == "weak-password") {
        return "A senha deve ter pelo menos 6 caracteres";
      } else {
        return "Erro ao cadastrar: ${e.message ?? 'Erro desconhecido'}";
      }
    } catch (e) {
      return "Erro desconhecido: ${e.toString()}";
    }
  }

  Future<String?> logarUsuarios({
    required String email, 
    required String senha
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "Nenhum usuário encontrado para este e-mail";
      } else if (e.code == "wrong-password") {
        return "Senha incorreta";
      } else if (e.code == "invalid-email") {
        return "O e-mail fornecido é inválido";
      } else {
        return "Erro ao logar: Senha incorreta";
      }
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool queroEntrar = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();

  AutenticacaoServico _autenServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 200,
                width: screenWidth * 0.6, // Responsividade
                margin: const EdgeInsets.only(top: 50),
                child: Image.asset('lib/assets/images/logo.png', fit: BoxFit.cover),
              ),
              const Text(
                'Entre com seu login e senha ou faça seu registro',
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    children: [
                      if (queroEntrar) ...[
                        _buildTextField(emailController, 'Email:', false, 'Por favor, insira seu email'),
                        const SizedBox(height: 24),
                        _buildTextField(senhaController, 'Senha:', true, 'Por favor, insira sua senha'),
                      ] else ...[
                        _buildTextField(emailController, 'Email:', false, 'Por favor, insira seu email'),
                        const SizedBox(height: 24),
                        _buildTextField(cpfController, 'CPF:', false, 'Por favor, insira seu CPF'),
                        const SizedBox(height: 24),
                        _buildTextField(nomeController, 'Nome:', false, 'Por favor, insira seu nome'),
                        const SizedBox(height: 24),
                        _buildTextField(senhaController, 'Senha:', true, 'Por favor, insira sua senha'),
                        const SizedBox(height: 24),
                        _buildTextField(confirmarSenhaController, 'Confirmar Senha:', true, 'Por favor, confirme sua senha', confirm: true),
                      ],
                      const SizedBox(height: 64),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: paletaDeCores.amareloClaro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            queroEntrar ? 'Entrar' : 'Registrar',
                            style: const TextStyle(
                              color: paletaDeCores.preto,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            queroEntrar = !queroEntrar;
                          });
                        },
                        child: Text(
                          queroEntrar ? 'Não tem uma conta? Registre-se aqui' : 'Já tem uma conta? Entre aqui',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label, bool obscureText, String errorMessage, {bool confirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: paletaDeCores.fundoApp,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return errorMessage;
        }
        if (confirm && value != senhaController.text) {
          return 'As senhas não coincidem';
        }
        return null;
      },
    );
  }

  void _onSubmit() {
    String nome = nomeController.text;
    String email = emailController.text;
    String senha = senhaController.text;

    if (_formKey.currentState!.validate()) {
      if (queroEntrar) {
        _autenServico.logarUsuarios(email: email, senha: senha).then((mensagem) {
          bool sucesso = mensagem == null;
          SnackBarUtil.showSnackBar(context, sucesso ? 'Entrada com sucesso' : mensagem!, sucesso);
          if (sucesso) {
            emailController.clear();
            senhaController.clear();
          }
        });
      } else {
        _autenServico.cadastrarUsario(nome: nome, senha: senha, email: email).then((mensagem) {
          bool sucesso = mensagem == "Cadastro com sucesso";
          SnackBarUtil.showSnackBar(context, mensagem, sucesso);
          if (sucesso) {
            emailController.clear();
            cpfController.clear();
            nomeController.clear();
            senhaController.clear();
            confirmarSenhaController.clear();
          }
        });
      }
    } else {
      SnackBarUtil.showSnackBar(context, 'Por favor, preencha todos os campos', false);
    }
  }
}
