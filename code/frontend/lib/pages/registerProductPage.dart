import 'package:bem_na_hora_flutter/models/product.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/productProvider.dart';
import 'loginPage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

class RegisterProductPage extends StatefulWidget {
  @override
  State<RegisterProductPage> createState() => _RegisterProductPageState();
}

class _RegisterProductPageState extends State<RegisterProductPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  String _tipoProduto = 'bebida';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

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
                    "Cadastro de Produto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  _buildTextField("Nome", _nameController, Icons.shopping_bag),
                  _buildTextField(
                    "Preço",
                    _priceController,
                    Icons.attach_money,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  _buildTextField(
                    "Unidade",
                    _unitController,
                    Icons.shopping_cart,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                  _buildTextField(
                    "Descrição",
                    _descriptionController,
                    Icons.description,
                    maxLines: 5,
                  ),

                  const SizedBox(height: 10),
                  const Text("Categoria"),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _tipoProduto,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'bebida', child: Text('Bebida')),
                      DropdownMenuItem(value: 'carne', child: Text('Carne')),
                      DropdownMenuItem(
                        value: 'churrasco',
                        child: Text('Churrasco'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tipoProduto = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // IMAGEM
                  Text(
                    "Imagem do Produto",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Selecionar imagem",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _register() async {
    String tipo;
    switch (_tipoProduto) {
      case 'churrasco':
        tipo = "churrasco";
        break;
      case 'carne':
        tipo = "carne";
        break;
      default:
        tipo = "bebida";
    }

    Product newProduct = Product(
      id: "",
      nome: _nameController.text,
      descricao: _descriptionController.text,
      preco: _priceController.text,
      categoria: tipo,
      unidade: _unitController.text,

      // TODO quando o backend suportar imagem, trocar pra _selectedImage
      imagem: null,

      quantidadeEmEstoque: 0,
    );

    try {
      final request = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).createProduct(newProduct.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
      );
    }
  }
}
