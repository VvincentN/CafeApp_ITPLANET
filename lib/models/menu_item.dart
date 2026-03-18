import 'menu_item_options.dart';

class MenuItem {
  final String id;
  String name;
  String imageUrl;
  String category;
  String? localImagePath;
  List<MenuItemOption> options;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    this.localImagePath,
    required this.options
  });
}
/*
// Тестовые данные (Mock Data)
final List<MenuItem> mockMenuItems = [
  MenuItem(
    id: "1",
    name: 'ЭСПРЕССО',
    imageUrl: 'assets/images/espresso.jpg',
    category: 'Классика',
    options: [
      MenuItemOption(volume: "30 мл", price: 130),
      MenuItemOption(volume: "60 мл", price: 170)
    ]
  ),
  MenuItem(
    id: "2",
    name: 'АМЕРИКАНО',
    imageUrl: 'assets/images/americano.jpg',
    category: 'Классика',
    options: [
      MenuItemOption(volume: "200 мл", price: 160),
      MenuItemOption(volume: "300 мл", price: 180)
    ]
  ),
  MenuItem(
    id: "3", 
    name: "ЛАТТЕ", 
    imageUrl: 'assets/images/latte.jpg', 
    category: 'Классика',
    options: [
      MenuItemOption(volume: "300 Мл", price: 220),
      MenuItemOption(volume: "400 Мл", price: 270)
    ]),
  MenuItem(
    id: "4",
    name: "ФЛЭТ-УАЙТ", 
    imageUrl: 'assets/images/flat-white.png', 
    category: 'Авторские',
    options: [
      MenuItemOption(volume: "200 Мл", price: 220),
      MenuItemOption(volume: "300 Мл", price: 270)
    ])
  // Добавьте еще несколько позиций для тестирования скроллинга
];
*/