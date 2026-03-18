import 'package:flutter/material.dart';

class AdressPage extends StatelessWidget {
  const AdressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Адрес", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B4671),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Color.fromRGBO(137, 81, 89, 1)),
            const SizedBox(height: 20),
            const Text(
              "Где нас найти:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "ул. Свободы, д. 15\nСанкт-Петербург",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 60, thickness: 1),
            const Icon(Icons.access_time, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "Часы работы",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
            ),
            const Text(
              "  Понедельник-Пятница\n  13:00 — 21:00",
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "Суббота-Воскресенье\n10:00 — 20:00",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}