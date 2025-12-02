import 'package:bem_na_hora_flutter/pages/registerUserPage.dart';
import 'package:bem_na_hora_flutter/widgets/appDrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/userProvider.dart';
import '../models/user.dart';
import 'updateUserPage.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.loadAllUsers(reset: true);
      setState(() {
        _filteredUsers = userProvider.users;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar usuários: $e')));
    }
  }

  void _onSearch(String query) {
    final userProvider = context.read<UserProvider>();
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = userProvider.users;
      } else {
        _filteredUsers = userProvider.users.where((u) {
          return (u.nome ?? '').toLowerCase().contains(lowerQuery) ||
              (u.username ?? '').toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _onDeleteUser(BuildContext context, User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o usuário "${user.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<UserProvider>().deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário "${user.nome}" excluído com sucesso!'),
          ),
        );
        await _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: const Color.fromARGB(255, 245, 146, 16),
        elevation: 2,
      ),
      drawer: const AppDrawer(),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔸 Linha de busca + botão de novo usuário
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Buscar usuário por nome ou email...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 245, 146, 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final created = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterUserPage(),
                          ),
                        );
                        if (created == true) {
                          await _loadUsers();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Usuário'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          146,
                          16,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔸 Tabela de usuários
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: userProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum usuário encontrado.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 32,
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.orange.shade100,
                                ),
                                border: TableBorder.symmetric(
                                  inside: BorderSide(
                                    color: Colors.orange.shade50,
                                  ),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Nome',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Função',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Telefone',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ações',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.nome ?? '-')),
                                      DataCell(Text(user.username)),
                                      DataCell(
                                        Text(
                                          user.role != null
                                              ? user.role
                                                    .toString()
                                                    .split('.')
                                                    .last
                                                    .capitalize()
                                              : '-',
                                        ),
                                      ),
                                      DataCell(Text(user.telefone ?? '-')),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () async {
                                                final updated =
                                                    await Navigator.push<bool>(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            UpdateUserPage(
                                                              userId: user.id,
                                                            ),
                                                      ),
                                                    );
                                                if (updated == true) {
                                                  await _loadUsers();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                await _onDeleteUser(
                                                  context,
                                                  user,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔸 Extensão para capitalizar
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
