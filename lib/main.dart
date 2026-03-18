import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'widgets/menu_item_card.dart';
import 'models/cart_item.dart';
import 'models/menu_item_options.dart';
import 'models/category_item.dart';
import 'about_us_page.dart';
import 'adress_page.dart';
import 'admin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Список категорий, который мы потом будем менять в админке
//List<String> categories = ["Классика", "Авторские", "НЕ кофе", "Молочные"];

void main() async{

  // 1. Фиксируем инициализацию движка Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Запускаем Firebase
  await Firebase.initializeApp();

  runApp(const CafeApp());
}

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<CartItem> cart = [];

  List<CategoryItem> cloudCategories = []; 
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Запускаем загрузку категорий из Firebase
  }

  Future<void> _loadCategories() async {
    try {
      // Идем в коллекцию, которая была создана
      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('createdAt') 
          .get();

      setState(() {
        cloudCategories = snapshot.docs.map((doc) => CategoryItem(
          id: doc.id,
          name: doc['name'],
        )).toList();
        isLoadingCategories = false;
      });
    } catch (e) {
      print("Ошибка загрузки: $e");
      setState(() => isLoadingCategories = false);
    }
  }

  void _addToCart(MenuItem item, MenuItemOption option) {
    setState(() {
      // Ищем, есть ли в корзине точно такой же напиток с таким же объемом
      int index = cart.indexWhere(
        (i) => i.item.id == item.id && i.option.volume == option.volume,
      );

      if (index != -1) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(item: item, option: option));
      }
    });
  }

  // Считаем общую цену, вытаскивая её из option внутри CartItem
  double get totalPrice => cart.fold(0, (sum, cartItem) => sum + (cartItem.option.price * cartItem.quantity));

  @override
  Widget build(BuildContext context) {

    if (isLoadingCategories) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Крутилка, пока база отвечает
      );
    }

/*
    if (mockMenuItems.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Меню пустое. Добавьте товары в админке.")),
      );
    }
*/

    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        // Иконка для открытия шторки (Drawer)
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      //выдвижная панель (Шторка)
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(55, 67, 117, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              width: double.infinity,
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            ListTile(
              visualDensity: const VisualDensity(vertical: -3),
              leading: const Icon(Icons.coffee_outlined, color: Colors.white),
              title: const Text('Меню', style: TextStyle(color: Colors.white, fontSize: 17)),
              onTap: () => Navigator.pop(context),
            ),

            Divider(
              color: Colors.white.withValues(alpha: 0.2),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Адреса',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdressPage()));
              }
            ),

            Divider(
              color: Colors.white.withValues(alpha: 0.2),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Для сотрудников',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              onTap: () {
                Navigator.pop(context); // Закрываем боковое меню
                  
                final TextEditingController _passController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Доступ для персонала"),
                    content: TextField(
                      controller: _passController,
                      obscureText: true, // Скрывает символы пароля
                      decoration: const InputDecoration(labelText: "Введите код доступа"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
                      ElevatedButton(
                        onPressed: () {
                          if (_passController.text == "TestPasswordTestPassword111") { // пароль
                            Navigator.pop(context); // Закрываем диалог
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminPage(
                                  menuItems: [], 
                                  categories: cloudCategories.map((c) => c.name).toList(), // Берем категории из облака!
                                  onAdd: (item) {},
                                  onDelete: (id) {},
                                ),
                              ),
                            );
                          } else {
                            // Если пароль неверный
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Неверный код доступа!")),
                            );
                          }
                        },
                        child: const Text("Войти"),
                      ),
                    ],
                  ),
                );
              },
            ),

            Divider(
              color: Colors.white.withValues(alpha: 0.2),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text(
                'О нас',
                style: TextStyle(color: Colors.white, fontSize: 17),
                
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
              }
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), // Отступы: лево, верх, право, низ
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 252, 215, 190), // Голубой
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "ЛЮБОЙ НАПИТОК МОЖЕТ БЫТЬ ПРИГОТОВЛЕН НА АЛЬТЕРНАТИВНОМ ИЛИ БЕЗЛАКТОЗНОМ МОЛОКЕ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 1. Подключаемся к "трубе" с товарами
              stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
              builder: (context, snapshot) {
                // Пока данные летят из облака — показываем крутилку
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Превращаем данные из Firebase в список наших объектов MenuItem
                final allItems = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Безопасное получение списка опций
                  List<MenuItemOption> options = [];
                  if (data['options'] is List) {
                    for (var o in data['options']) {
                      if (o is Map) {
                        options.add(MenuItemOption(
                          volume: o['volume']?.toString() ?? '',
                          price: (o['price'] as num?)?.toInt() ?? 0,
                        ));
                      }
                    }
                  }

                  return MenuItem(
                    id: doc.id,
                    name: data['name']?.toString() ?? 'Без названия',
                    category: data['category']?.toString() ?? '',
                    imageUrl: data['imageUrl']?.toString() ?? 'assets/images/default.png',
                    options: options.isEmpty ? [MenuItemOption(volume: '?', price: 0)] : options,
                  );
                }).toList();

                // 2. Рисуем наш список категорий, используя уже ПОЛУЧЕННЫЕ товары
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cloudCategories.length,
                  itemBuilder: (context, catIndex) {
                    final category = cloudCategories[catIndex];
                    
                    // Фильтруем товары из облака по категории
                    final categoryItems = allItems.where((item) => item.category == category.name).toList();

                    if (categoryItems.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            category.name.toUpperCase(),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            return MenuItemCard(
                              item: categoryItems[index],
                              onAdd: (price) => _showVolumeSelection(categoryItems[index]),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: cart.isEmpty
          ? null
          : Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(137, 81, 89, 1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _showCartSheet, 
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_basket_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1.5,
                        height: 24,
                        color: Colors.white54,
                      ),
                      Text(
                        "${cart.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Кнопка слева
    );
  }

  void _showVolumeSelection(MenuItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Шторка по размеру контента
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              // Список вариантов объема
              ...item.options.map(
                (option) => ListTile(
                  title: Text(option.volume, style: TextStyle(fontSize: 17)),
                  trailing: Text(
                    "${option.price} ₽",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    _addToCart(
                      item,
                      option,
                    ); // Передаем объекты item и option, как требует модель
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
 
 //корзина-калькулятор (пока)
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text("Ваш заказ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                          if (index >= cart.length) return const SizedBox(); // Страховка
                          final cartItem = cart[index];
                          return ListTile(
                          // 1. Имя берем из объекта item
                          title: Text(cartItem.item.name), 
                          
                          // 2. Объем и цену берем из объекта option
                          subtitle: Text("${cartItem.option.volume} • ${cartItem.option.price.toInt()} ₽"), 
                          
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() {
                                      if (cartItem.quantity > 1) {
                                        cartItem.quantity--;
                                      } else {
                                        cart.removeAt(index);
                                      }
                                    });
                                  });
                                },
                              ),
                              Text("${cartItem.quantity}"),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() {
                                      cartItem.quantity++;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Text("Итого: ${totalPrice.toInt()} ₽", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}