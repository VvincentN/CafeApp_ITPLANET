import 'package:flutter/material.dart';
import '../models/menu_item.dart';
//import 'dart:io';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Function(double) onAdd;

  const MenuItemCard({super.key, required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    // 1. Находим минимальную цену среди всех объемов
    final minPrice = item.options
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);
    // 2. Находим минимальный объем (для красоты)
    final minVolume = item.options[0].volume;

    String priceDisplay;
    String volumeDisplay = "";

    if (item.options.length > 1) {
      // Ищем минимальную цену среди всех вариантов
      int minPrice = item.options.map((o) => o.price).reduce((a, b) => a < b ? a : b);
      priceDisplay = "от $minPrice ₽";
      volumeDisplay = "от $minVolume"; // Для нескольких объемов в карточке объем лучше скрыть
    } else {
      // Если объем только один
      int price = item.options.first.price;
      priceDisplay = "$price ₽";
      volumeDisplay = item.options.first.volume; // Показываем объем (например, 300мл)
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 214, 213, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Картинка (твой код с ClipRRect...)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                item.imageUrl, // Используем imageUrl из модели MenuItem
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                // Если в базе нет ссылки или она битая — покажем заглушку
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default.png',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
                // Индикатор загрузки, пока картинка качается
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                // Добавляем надпись про объем
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Расталкивает элементы в разные стороны
                    children: [
                      // Текст объема (слева)
                      Text(
                        volumeDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Кнопка с ценой (справа)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B4671),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          minimumSize: const Size(
                            0,
                            40,
                          ), // Делаем кнопку чуть компактнее
                        ),
                        onPressed: () => onAdd(minPrice.toDouble()),
                        child: Text(
                          priceDisplay,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
