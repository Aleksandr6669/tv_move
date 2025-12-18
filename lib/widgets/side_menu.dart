
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Модель для элемента меню, чтобы хранить иконку и название
class MenuItemData {
  final IconData icon;
  final String title;

  MenuItemData({required this.icon, required this.title});
}

// Виджет бокового меню для навигации
class SideMenu extends StatefulWidget {
  final FocusNode focusNode;
  final List<MenuItemData> menuItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onItemActivated;

  const SideMenu({
    super.key,
    required this.focusNode,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onItemActivated,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late List<FocusNode> _itemFocusNodes;

  @override
  void initState() {
    super.initState();
    _itemFocusNodes =
        List.generate(widget.menuItems.length, (index) => FocusNode(debugLabel: 'MenuItem $index'));

    // Когда меню получает фокус, передаем его на выбранный пункт
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _itemFocusNodes[widget.selectedIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если изменился индекс извне, а фокус все еще в меню, двигаем фокус
    if (oldWidget.selectedIndex != widget.selectedIndex && widget.focusNode.hasFocus) {
      _itemFocusNodes[widget.selectedIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Сделаем меню немного шире
      color: const Color(0xFF1F2227), // Новый цвет фона из скриншота
      child: Focus(
        focusNode: widget.focusNode,
        // Убираем отступы сверху/снизу и используем Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Добавим заголовок как на скриншоте
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 24, bottom: 20),
              child: Text(
                'Сейчас смотрят', // Пример заголовка
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final bool isSelected = widget.selectedIndex == index;
    final item = widget.menuItems[index];

    return Focus(
      focusNode: _itemFocusNodes[index],
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          widget.onItemSelected(index);
        }
      },
      onKey: (node, event) {
        if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (index > 0) _itemFocusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (index < widget.menuItems.length - 1) _itemFocusNodes[index + 1].requestFocus();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select) {
          widget.onItemActivated();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        final bool hasFocus = Focus.of(context).hasFocus;
        // Используем Stack для добавления зеленой полоски слева
        return GestureDetector(
          onTap: () {
            widget.onItemSelected(index);
            // Задержка для того, чтобы пользователь увидел эффект выбора
            Future.delayed(const Duration(milliseconds: 100), () {
              widget.onItemActivated();
            });
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: hasFocus ? const Color(0xFF00A95D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 24,
                      // Цвет иконки меняется в зависимости от фокуса
                      color: hasFocus ? Colors.white : Colors.grey[400],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.title,
                      style: TextStyle(
                        // Цвет текста тоже меняется
                        color: hasFocus ? Colors.white : Colors.grey[400],
                        fontSize: 18,
                        fontWeight: hasFocus ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Зеленая полоска слева для выбранного, но не сфокусированного элемента
              if (isSelected && !hasFocus)
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A95D),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
