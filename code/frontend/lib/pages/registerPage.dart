import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/userProvider.dart';
import 'loginPage.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  String _tipoUsuario = 'Cliente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 56,
                          color: Color.fromARGB(255, 245, 146, 16),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Bem na Hora",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Criar nova conta",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Cadastro",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    "Preencha os dados para criar sua conta",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    "Nome Completo",
                    _nomeController,
                    Icons.person,
                  ),
                  _buildTextField("Email", _emailController, Icons.email),
                  _buildTextField("Telefone", _telefoneController, Icons.phone),

                  const SizedBox(height: 10),
                  const Text("Tipo de Usuário"),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _tipoUsuario,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Cliente',
                        child: Text('Cliente'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tipoUsuario = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    "Endereço",
                    _enderecoController,
                    Icons.location_on,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Cidade",
                          _cidadeController,
                          Icons.location_city,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: _buildTextField(
                          "Estado",
                          _estadoController,
                          Icons.map,
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(
                    "Senha",
                    _senhaController,
                    Icons.lock,
                    isPassword: true,
                  ),
                  _buildTextField(
                    "Confirmar Senha",
                    _confirmarSenhaController,
                    Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cadastrar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "Já tem uma conta? Faça login aqui",
                        style: TextStyle(
                          color: Color.fromARGB(255, 245, 146, 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }

    // Converter a string selecionada no dropdown para o enum UserType
    UserType tipo;
    switch (_tipoUsuario) {
      case 'Cliente':
      default:
        tipo = UserType.customer;
    }

    final novoUsuario = User(
      id: '', // não será enviado no cadastro
      username: _emailController.text.trim(),
      nomeCompleto: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      role: tipo,
      endereco: _enderecoController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estadoController.text.trim(),
      passwordHash: _senhaController.text, // backend deve hashear
    );

    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).register(novoUsuario);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg.contains('Username já existe')
                ? 'E-mail já cadastrado'
                : 'Erro ao cadastrar: $msg',
          ),
        ),
      );
    }
  }
}
