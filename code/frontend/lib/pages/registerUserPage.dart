import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../providers/userProvider.dart';
import 'loginPage.dart';
import 'package:provider/provider.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
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
                  color: Colors.black.withOpacity(
                    0.1,
                  ), //por que raios ta ficando riscado?
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
                    "Preencha os dados para criar a conta",
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
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'Empresa',
                        child: Text('Empresa'),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Voltar",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                    ],
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

  UserType _stringToRole(String tipo) {
    switch (tipo) {
      case 'Entregador':
        return UserType.deliverer;
      case 'Admin':
        return UserType.admin;
      case 'Cliente':
      default:
        return UserType.customer;
    }
  }

  Future<void> _register() async {
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }

    // Converter a string selecionada no dropdown para o enum UserType
    UserType role;
    switch (_tipoUsuario) {
      case 'Entregador':
        role = UserType.deliverer;
        break;
      case 'Empresa':
        role = UserType.admin;
        break;
      case 'Cliente':
      default:
        role = UserType.customer;
    }

    User novoUsuario = User(
      id: '',
      username: _emailController.text,
      nome: _nomeController.text,
      telefone: _telefoneController.text,
      endereco: _enderecoController.text,
      cidade: _cidadeController.text,
      estado: _estadoController.text,
      role: _stringToRole(_tipoUsuario),
      passwordHash: _senhaController.text,
    );

    try {
      final request = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).register(novoUsuario);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
      );
    }
  }
}
