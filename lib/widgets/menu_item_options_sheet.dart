import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/menu_item_options.dart';

// Добавь callback в конструктор
class MenuItemOptionsSheet extends StatelessWidget {
  final MenuItem item;
  final Function(MenuItemOption) onOptionSelected; // Добавили это

  const MenuItemOptionsSheet({
    super.key,
    required this.item,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...item.options.map((option) {
            return ListTile(
              title: Text(option.volume),
              trailing: Text('${option.price} ₽'),
              onTap: () {
                onOptionSelected(option); // Вызываем функцию
                Navigator.pop(context);
              },
            );
          })
        ],
      ),
    );
  }
}