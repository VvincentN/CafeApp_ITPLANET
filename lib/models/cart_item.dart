import 'menu_item_options.dart';
import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  final MenuItemOption option;
  int quantity;

  CartItem({
    required this.item, 
    required this.option, 
    this.quantity = 1
  });
}