import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../services/entregador_service.dart';
import '../providers/authProvider.dart';
import '../models/user.dart';

class EntregadoresCadastroPage extends StatefulWidget {
  final String? editId;
  const EntregadoresCadastroPage({super.key, this.editId});

  @override
  State<EntregadoresCadastroPage> createState() =>
      _EntregadoresCadastroPageState();
}

class _EntregadoresCadastroPageState extends State<EntregadoresCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _cnhCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmSenhaCtrl = TextEditingController();

  bool _loading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.editId != null;
    if (_isEdit) {
      _loadForEdit();
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    _cnhCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmSenhaCtrl.dispose();
    super.dispose();
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
        validator: (v) {
          if ((label.toLowerCase().contains('nome') ||
                  label.toLowerCase().contains('email')) &&
              (v == null || v.trim().isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);

    if (_senhaCtrl.text.trim() != _confirmSenhaCtrl.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem')));
      setState(() => _loading = false);
      return;
    }

    try {
      final svc = context.read<EntregadorService>();
      if (_isEdit && widget.editId != null) {
        final body = {
          'nome': _nomeCtrl.text.trim(),
          'telefone': _telefoneCtrl.text.trim(),
          'cnh': _cnhCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'username': _emailCtrl.text.trim(),
        };
        if (_senhaCtrl.text.trim().isNotEmpty) {
          body['passwordHash'] = _senhaCtrl.text.trim();
        }
        await svc.update(widget.editId!, body);
        messenger.showSnackBar(
          const SnackBar(content: Text('Entregador atualizado com sucesso')),
        );
      } else {
        await svc.create({
          'nome': _nomeCtrl.text.trim(),
          'telefone': _telefoneCtrl.text.trim(),
          'cnh': _cnhCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'username': _emailCtrl.text.trim(),
          'passwordHash': _senhaCtrl.text.trim(),
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Entregador criado com sucesso')),
        );
      }
      context.go('/entregadores');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadForEdit() async {
    if (widget.editId == null) return;
    setState(() => _loading = true);
    try {
      final svc = context.read<EntregadorService>();
      final data = await svc.getById(widget.editId!);
      setState(() {
        _nomeCtrl.text = (data['nome'] ?? data['nomeCompleto'] ?? '')
            .toString();
        _telefoneCtrl.text = (data['telefone'] ?? '').toString();
        _cnhCtrl.text = (data['cnh'] ?? data['documento'] ?? '').toString();
        _emailCtrl.text = (data['email'] ?? data['username'] ?? '').toString();
        // não preencher senha
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteCurrent() async {
    if (widget.editId == null) return;
    final svc = context.read<EntregadorService>();
    try {
      await svc.delete(widget.editId!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entregador excluído')));
      context.go('/entregadores');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn || auth.user?.role != UserType.admin) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F9),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _loading,
          child: Center(
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
                              "Cadastro de Entregador",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Cadastro",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Preencha os dados para criar a conta de entregador",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField('Nome completo', _nomeCtrl, Icons.person),
                      _buildTextField('Email', _emailCtrl, Icons.email),
                      _buildTextField('Telefone', _telefoneCtrl, Icons.phone),
                      _buildTextField('CNH', _cnhCtrl, Icons.badge),
                      _buildTextField(
                        'Senha',
                        _senhaCtrl,
                        Icons.lock,
                        isPassword: true,
                      ),
                      _buildTextField(
                        'Confirmar Senha',
                        _confirmSenhaCtrl,
                        Icons.lock,
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.go('/entregadores'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Voltar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (_isEdit) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: const Text(
                                        'Deseja realmente excluir este entregador?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Sim'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) await _deleteCurrent();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Excluir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _loading
                                  ? const Text(
                                      'Salvando...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text(
                                      _isEdit ? 'Salvar' : 'Cadastrar',
                                      style: const TextStyle(
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
        ),
      ),
    );
  }
}
