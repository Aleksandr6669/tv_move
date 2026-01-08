import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryMenu extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategoryMenu({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryMenu> createState() => _CategoryMenuState();
}

class _CategoryMenuState extends State<CategoryMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Width of the side menu
      color: Colors.black.withOpacity(0.8),
      child: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedIndex == index;
          return ListTile(
            title: Text(
              widget.categories[index],
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            tileColor: isSelected ? Colors.red.withOpacity(0.5) : Colors.transparent,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onCategorySelected(widget.categories[index]);
            },
          );
        },
      ),
    );
  }
}
