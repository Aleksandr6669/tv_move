import 'package:flutter/material.dart';
import 'package:myapp/services/firestore_service.dart';

class AdminScreen extends StatelessWidget {
  final FirestoreService firestoreService;
  // УПРОЩЕНО: Убран contentFocusNode
  final FocusNode menuFocusNode; 
  final Function(int) navigateToScreen;

  const AdminScreen({
    super.key,
    required this.firestoreService,
    required this.menuFocusNode, 
    required this.navigateToScreen,
  });

  void _showAddMovieDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final posterUrlController = TextEditingController();
    String category = 'Фильм'; // Значение по умолчанию

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить новый фильм'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) => value!.isEmpty ? 'Введите название' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                    validator: (value) => value!.isEmpty ? 'Введите описание' : null,
                  ),
                  TextFormField(
                    controller: posterUrlController,
                    decoration: const InputDecoration(labelText: 'URL постера'),
                    validator: (value) => value!.isEmpty ? 'Введите URL постера' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['Новинка', 'Фильм', 'Сериал', 'Мультфильм', 'Аниме']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        category = value;
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Категория'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  firestoreService.addMovie(
                    title: titleController.text,
                    description: descriptionController.text,
                    posterUrl: posterUrlController.text,
                    category: category,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text('Админ-панель'),
        backgroundColor: const Color(0xFF2C2C2E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Добавить фильм/сериал'),
              onPressed: () => _showAddMovieDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Показать весь список'),
              onPressed: () => navigateToScreen(7), // Индекс для MovieListScreen
               style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
