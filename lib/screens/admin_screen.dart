import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class AdminScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final FocusNode menuFocusNode;
  final Function(int) navigateToScreen;

  const AdminScreen({
    super.key,
    required this.firestoreService,
    required this.menuFocusNode,
    required this.navigateToScreen,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();
  String _selectedCategory = 'Фильм';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newMovie = Movie(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        posterUrl: _posterUrlController.text,
        year: int.parse(_yearController.text),
        category: _selectedCategory,
        rating: double.parse(_ratingController.text),
      );
      await widget.firestoreService.addMovie(newMovie); // <-- Исправлено

      // Показываем подтверждение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фильм успешно добавлен!')),
      );
      // Очищаем форму
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _posterUrlController.clear();
      _yearController.clear();
      _ratingController.clear();
      setState(() {
        _selectedCategory = 'Фильм';
      });
       widget.navigateToScreen(7); // Переходим к списку фильмов
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTextFormField(_titleController, 'Название'),
            _buildTextFormField(_descriptionController, 'Описание', maxLines: 3),
            _buildTextFormField(_posterUrlController, 'URL постера'),
            _buildTextFormField(_yearController, 'Год', keyboardType: TextInputType.number),
            _buildTextFormField(_ratingController, 'Рейтинг', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            _buildCategoryDropdown(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Добавить фильм'),
            ),
            const SizedBox(height: 16),
             ElevatedButton(
              onPressed: () => widget.navigateToScreen(7), // Переход к списку
              child: const Text('Показать все фильмы'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Пожалуйста, заполните это поле';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Категория',
          border: OutlineInputBorder(),
        ),
        items: <String>['Фильм', 'Сериал', 'Мультфильм', 'Аниме', 'Новинка']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue!;
          });
        },
      ),
    );
  }
}
