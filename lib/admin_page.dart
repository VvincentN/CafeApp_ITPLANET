import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'models/menu_item_options.dart';
import 'dart:io'; // Обязательно для работы с File
import 'package:image_picker/image_picker.dart'; // Для работы с галереей
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class AdminPage extends StatefulWidget {
  final List<MenuItem> menuItems; // Список из main.dart
  final List<String> categories;  // Список категорий из main.dart
  final Function(MenuItem) onAdd; // Функция для добавления
  final Function(int) onDelete; // Функция для удаления

  const AdminPage({
    super.key, 
    required this.menuItems, 
    required this.categories,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

/*
  Future<String> _uploadImage(File imageFile) async {
    // Создаем уникальное имя для файла в облаке
    String fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Ссылка на место хранения в Storage
    Reference ref = FirebaseStorage.instance.ref().child('menu_images').child(fileName);
    
    // Загружаем файл
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    
    // Получаем и возвращаем URL
    return await snapshot.ref.getDownloadURL();
  }
*/

  // Контроллеры для полей ввода
  final TextEditingController imageUrlController = TextEditingController();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  //final imageController = TextEditingController();
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.first;
  }

  // Окно для добавления товара
  // список для новых опций
  List<MenuItemOption> newOptions = [MenuItemOption(volume: '200мл', price: 0)];

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Чтобы список объемов обновлялся внутри окна
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Новый напиток"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: "Название")),
                  const SizedBox(height: 15),

                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: "Ссылка на фото (URL)",
                      hintText: "Вставьте ссылку из интернета",
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  
                  //Выбор категории
                  DropdownButton<String>(
                    value: selectedCategory.isEmpty ? widget.categories.first : selectedCategory,
                    isExpanded: true,
                    hint: const Text("Выберите категорию"),
                    items: widget.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                  
                  // Показываем превью, если фото выбрано
                  if (_selectedImage != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
                    ),

                  const SizedBox(height: 15),
                  const Text("Объемы и цены:"),
                  ...newOptions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Row(
                      children: [
                        Expanded(child: TextField(
                          decoration: const InputDecoration(hintText: "мл"),
                          onChanged: (v) => newOptions[idx] = MenuItemOption(volume: v, price: newOptions[idx].price),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(
                          decoration: const InputDecoration(hintText: "₽"),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => newOptions[idx] = MenuItemOption(volume: newOptions[idx].volume, price: int.tryParse(v) ?? 0),
                        )),
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () => setDialogState(() => newOptions.add(MenuItemOption(volume: '', price: 0))),
                    child: const Text("+ Добавить объем"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
              ElevatedButton(
                onPressed: () async {
                  // Валидация: название не должно быть пустым
                  if (nameController.text.trim().isEmpty) return;

                  try {
                    // Берем ссылку из поля, если пусто — ставим заглушку
                    String finalUrl = imageUrlController.text.trim().isEmpty 
                        ? 'assets/images/default.png' 
                        : imageUrlController.text.trim();

                    final Map<String, dynamic> itemData = {
                      'name': nameController.text,
                      'category': selectedCategory,
                      'imageUrl': finalUrl, // Прямая ссылка на фото
                      'options': newOptions.map((o) => {
                        'volume': o.volume,
                        'price': o.price,
                      }).toList(),
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    // Сохраняем в Firestore
                    await FirebaseFirestore.instance.collection('menu_items').add(itemData);

                    // Очистка
                    nameController.clear();
                    imageUrlController.clear();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Товар успешно добавлен!"), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ошибка базы: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text("Добавить"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditDialog(MenuItem item) {
  nameController.text = item.name;
  selectedCategory = item.category;
  // Создаем временный список опций для редактирования
  List<MenuItemOption> tempOptions = List.from(item.options);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Редактировать: ${item.name}"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: "Название")),
                  
                  // ВЫБОР КАТЕГОРИИ
                  DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),

                  // СМЕНА ФОТО
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickImage();
                      setDialogState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Сменить фото"),
                  ),

                  const Divider(),
                  const Text("Объемы и цены:"),
                  ...tempOptions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Row(
                      children: [
                        Expanded(child: TextFormField(
                          initialValue: tempOptions[idx].volume,
                          decoration: const InputDecoration(hintText: "объем"),
                          onChanged: (v) => tempOptions[idx] = MenuItemOption(volume: v, price: tempOptions[idx].price),
                        )),
                        const SizedBox(width: 5),
                        Expanded(child: TextFormField(
                          initialValue: tempOptions[idx].price.toString(),
                          decoration: const InputDecoration(hintText: "₽"),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => tempOptions[idx] = MenuItemOption(volume: tempOptions[idx].volume, price: int.tryParse(v) ?? 0),
                        )),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                          onPressed: () => setDialogState(() => tempOptions.removeAt(idx)),
                        )
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () => setDialogState(() => tempOptions.add(MenuItemOption(volume: '', price: 0))),
                    child: const Text("+ добавить вариант"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
              ElevatedButton(
                // Добавляем async вот сюда:
                onPressed: () async { 
                  try {
                    // 1. Обновляем данные в Firebase
                    // .doc(item.id.toString()) — находим именно этот товар по его ID
                    await FirebaseFirestore.instance
                        .collection('menu_items')
                        .doc(item.id.toString()) 
                        .update({
                        'name': nameController.text,
                        'category': selectedCategory,
                        'options': tempOptions.map((o) => {
                        'volume': o.volume,
                        'price': o.price,
                      }).toList(),
                    });

                    // 2. Код очистки и закрытия
                    _selectedImage = null; 
                    Navigator.pop(context);

                    // Сообщение об успехе
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Изменения сохранены в облаке!")),
                    );
                  } catch (e) {
                    // Если что-то пошло не так (например, пропал интернет)
                    print("Ошибка при обновлении: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text("Сохранить"),
              ),
            ],
          );
        }
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Админ-панель", style: TextStyle(color: Colors.white),), iconTheme: const IconThemeData(color: Colors.white), backgroundColor: const Color(0xFF3B4671)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color.fromRGBO(137, 81, 89, 1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Блок категорий (сверху)
          ExpansionTile(
            title: const Text("Управление категориями"),
            children: [
              ...widget.categories.map((cat) => ListTile(
                title: Text(cat),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => widget.categories.remove(cat)),
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: "Новая категория", suffixIcon: Icon(Icons.add)),
                  onSubmitted: (val) async {
                    if (val.isNotEmpty) {
                      try {
                        // Отправляем в новую коллекцию "categories"
                        await FirebaseFirestore.instance.collection('categories').add({
                          'name': val,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        
                        // Пока оставляем локальное обновление, чтобы увидеть результат сразу
                        setState(() => widget.categories.add(val));
                        
                      } catch (e) {
                        print("Ошибка при добавлении категории: $e");
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          
          // Список товаров (занимает остальное место)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
              builder: (context, snapshot) {
                // Пока данные грузятся
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Превращаем документы из базы в объекты MenuItem
                final items = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Собираем опции (объемы и цены)
                  List<MenuItemOption> options = [];
                  if (data['options'] is List) {
                    for (var o in data['options']) {
                      options.add(MenuItemOption(
                        volume: o['volume']?.toString() ?? '',
                        price: (o['price'] as num?)?.toInt() ?? 0,
                      ));
                    }
                  }

                  return MenuItem(
                    id: doc.id,
                    name: data['name'] ?? 'Без названия',
                    category: data['category'] ?? '',
                    imageUrl: data['imageUrl'] ?? 'assets/images/default.png',
                    options: options,
                  );
                }).toList();

                if (items.isEmpty) {
                  return const Center(child: Text("В меню пока пусто"));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: item.imageUrl.startsWith('http') 
                          ? Image.network(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                          : Image.asset(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Удаление"),
                              content: Text("Удалить ${item.name} из базы данных?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Отмена")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Удалить", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ) ?? false;

                          if (confirm) {
                            await FirebaseFirestore.instance.collection('menu_items').doc(item.id).delete();
                          }
                        },
                      ),
                      onTap: () => _showEditDialog(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}