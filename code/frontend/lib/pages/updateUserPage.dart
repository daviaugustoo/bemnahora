import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/userProvider.dart';

class UpdateUserPage extends StatefulWidget {
  final String userId;

  const UpdateUserPage({super.key, required this.userId});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
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
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUser();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadUser() async {
    try {
      final user = await context.read<UserProvider>().getUserById(
        widget.userId,
      );
      if (!mounted) return;
      _user = user;
      _nomeController.text = user.nome ?? '';
      _emailController.text = user.username ?? '';
      _telefoneController.text = user.telefone ?? '';
      _enderecoController.text = user.endereco ?? '';
      _cidadeController.text = user.cidade ?? '';
      _estadoController.text = user.estado ?? '';
      _tipoUsuario = _roleToString(user.role);
      _isLoading = false;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar usuário: $e')));
      Navigator.pop(context);
    }
  }

  String _roleToString(UserType role) {
    switch (role) {
      case UserType.deliverer:
        return 'Entregador';
      case UserType.admin:
        return 'Admin';
      case UserType.customer:
      default:
        return 'Cliente';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F9),
      appBar: AppBar(
        title: const Text("Editar Usuário"),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                                Icons.person,
                                size: 56,
                                color: Color.fromARGB(255, 245, 146, 16),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Editar Usuário",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField("Nome", _nomeController, Icons.person),
                        _buildTextField("Email", _emailController, Icons.email),
                        _buildTextField(
                          "Telefone",
                          _telefoneController,
                          Icons.phone,
                        ),

                        const SizedBox(height: 10),
                        const Text("Tipo de Usuário"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _tipoUsuario,
                          decoration: _inputDecoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Cliente',
                              child: Text('Cliente'),
                            ),
                            DropdownMenuItem(
                              value: 'Admin',
                              child: Text('Admin'),
                            ),
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
                          "Senha (opcional)",
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  "Voltar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updateUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  "Salvar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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

  Future<void> _updateUser() async {
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }

    final updatedUser = User(
      id: _user!.id,
      username: _emailController.text,
      nome: _nomeController.text,
      telefone: _telefoneController.text,
      endereco: _enderecoController.text,
      cidade: _cidadeController.text,
      estado: _estadoController.text,
      role: _stringToRole(_tipoUsuario),
      passwordHash: _senhaController.text.isNotEmpty
          ? _senhaController.text
          : _user!.passwordHash,
    );

    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário atualizado com sucesso!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: ${e.toString()}')),
      );
    }
  }
}
