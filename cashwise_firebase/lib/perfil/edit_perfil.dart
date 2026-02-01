import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;

  bool _isLoading = false;
  int _selectedDay = 1;
  String _selectedMonth = 'Janeiro';
  int _selectedYear = 2000;
  
  // Para mobile
  File? _imageFile;
  // Para web
  Uint8List? _webImage;
  
  String? _imageBase64;
  bool _photoWasRemoved = false;

  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _parseBirthDate();
    _loadProfileImage();
  }

  void _initializeControllers() {
    _nomeController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _telefoneController = TextEditingController(text: widget.userData['phone'] ?? '');
  }

  void _parseBirthDate() {
    final birthDate = widget.userData['birthDate'] ?? '';
    if (birthDate.isNotEmpty) {
      try {
        final parts = birthDate.split('/');
        if (parts.length == 3) {
          _selectedDay = int.parse(parts[0]);
          _selectedMonth = _months[int.parse(parts[1]) - 1];
          _selectedYear = int.parse(parts[2]);
        }
      } catch (e) {
        print('Erro ao parsear data: $e');
      }
    }
  }

  void _loadProfileImage() {
    _imageBase64 = widget.userData['photoBase64'] as String?;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final source = await showModalBottomSheet<ImageSource?>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolher foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF17A2B8)),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF17A2B8)),
                  title: const Text('Câmera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              if (_imageBase64 != null || _imageFile != null || _webImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover foto'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile = null;
                      _webImage = null;
                      _imageBase64 = null;
                      _photoWasRemoved = true;
                    });
                  },
                ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,  // Reduzido para economizar espaço
        maxHeight: 800,
        imageQuality: 70,  // Reduzido para economizar espaço
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        
        // Verificar tamanho (limite de ~500KB para Base64)
        if (bytes.length > 500000) {
          if (mounted) {
            _showSnackBar('Imagem muito grande. Por favor, escolha uma imagem menor.', isError: true);
          }
          return;
        }

        if (kIsWeb) {
          setState(() {
            _webImage = bytes;
            _imageFile = null;
            _photoWasRemoved = false;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImage = bytes;
            _photoWasRemoved = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      _showSnackBar('Erro ao selecionar imagem', isError: true);
    }
  }

  Future<String?> _convertImageToBase64() async {
    try {
      Uint8List? bytes;
      
      if (kIsWeb && _webImage != null) {
        bytes = _webImage;
      } else if (_imageFile != null) {
        bytes = await _imageFile!.readAsBytes();
      }
      
      if (bytes == null) return _imageBase64;
      
      print('🔵 Convertendo imagem para Base64...');
      final base64String = base64Encode(bytes);
      print('✅ Imagem convertida: ${base64String.length} caracteres');
      
      return base64String;
    } catch (e) {
      print('❌ Erro ao converter imagem: $e');
      throw Exception('Erro ao processar imagem');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10a5c6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10a5c6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EDITAR PERFIL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Avatar com seleção de imagem
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8DD7E8),
                                    shape: BoxShape.circle,
                                    image: _getProfileImage(),
                                  ),
                                  child: _shouldShowInitials()
                                      ? Center(
                                          child: Text(
                                            _getInitials(_nomeController.text),
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF17A2B8),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Center(
                          child: Text(
                            'Toque para alterar a foto',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Campo Nome
                        const Text(
                          'Nome Completo',
                          style: TextStyle(
                            color: Color(0xFF17A2B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nomeController,
                          hintText: 'Nome e Sobrenome',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome';
                            }
                            if (value.trim().split(' ').length < 2) {
                              return 'Por favor, insira nome e sobrenome';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Email (desabilitado)
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            color: Color(0xFF17A2B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'E-mail',
                          icon: Icons.email_outlined,
                          enabled: false,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'O e-mail não pode ser alterado',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Telefone
                        const Text(
                          'Telefone',
                          style: TextStyle(
                            color: Color(0xFF17A2B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _telefoneController,
                          hintText: 'Celular',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu celular';
                            }
                            final numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (numbersOnly.length < 10) {
                              return 'Celular inválido';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Data de Nascimento
                        const Text(
                          'Data de Nascimento',
                          style: TextStyle(
                            color: Color(0xFF17A2B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildDropdown(
                                value: _selectedDay.toString(),
                                items: List.generate(31, (index) => (index + 1).toString()),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDay = int.parse(value!);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              flex: 2,
                              child: _buildDropdown(
                                value: _selectedMonth,
                                items: _months,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              flex: 1,
                              child: _buildDropdown(
                                value: _selectedYear.toString(),
                                items: List.generate(100, (index) => (DateTime.now().year - index).toString()),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = int.parse(value!);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Botão Salvar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF17A2B8),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'SALVAR ALTERAÇÕES',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DecorationImage? _getProfileImage() {
    if (_webImage != null) {
      return DecorationImage(
        image: MemoryImage(_webImage!),
        fit: BoxFit.cover,
      );
    } else if (_imageFile != null && !kIsWeb) {
      return DecorationImage(
        image: FileImage(_imageFile!),
        fit: BoxFit.cover,
      );
    } else if (_imageBase64 != null && !_photoWasRemoved) {
      try {
        final bytes = base64Decode(_imageBase64!);
        return DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Erro ao decodificar Base64: $e');
        return null;
      }
    }
    return null;
  }

  bool _shouldShowInitials() {
    return _webImage == null && 
           _imageFile == null && 
           (_imageBase64 == null || _photoWasRemoved);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF5F5F5) : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        enabled: enabled && !_isLoading,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: enabled ? const Color(0xFF17A2B8) : Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF17A2B8) : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          color: Color(0xFF17A2B8),
          fontSize: 14,
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: _isLoading ? null : onChanged,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF17A2B8),
        ),
      ),
    );
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final name = _nomeController.text.trim();
      final phone = _telefoneController.text.trim();
      final monthNumber = _months.indexOf(_selectedMonth) + 1;
      final birthDate = '$_selectedDay/${monthNumber.toString().padLeft(2, '0')}/$_selectedYear';

      print('🔵 Atualizando perfil do usuário: ${user.uid}');

      final Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
        'birthDate': birthDate,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Lidar com a foto do perfil
      if (_photoWasRemoved) {
        updateData['photoBase64'] = FieldValue.delete();
        print('🗑️ Foto removida');
      } else if (_imageFile != null || _webImage != null) {
        print('📸 Processando nova foto...');
        final photoBase64 = await _convertImageToBase64();
        if (photoBase64 != null) {
          updateData['photoBase64'] = photoBase64;
          print('✅ Nova foto salva em Base64');
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      print('✅ Perfil atualizado com sucesso');

      if (!mounted) return;

      _showSnackBar('✅ Perfil atualizado com sucesso!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pop(context, true);

    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');

      String errorMessage = 'Erro ao atualizar perfil';
      
      if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Erro de conexão. Verifique sua internet';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Você não tem permissão para atualizar este perfil';
      } else {
        errorMessage = 'Erro: ${e.toString().split(':').last.trim()}';
      }

      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF17A2B8),
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}