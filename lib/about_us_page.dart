import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("О кофейне", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B4671),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: AssetImage('assets/images/cafe_interior.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: const Center(
                  child: Text(
                    "С любовью к кофе",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Мы верим, что каждая чашка кофе — это маленькое путешествие. Мы используем только свежую обжарку и натуральные ингредиенты для наших десертов. Заходите к нам за вдохновением и теплом!",
                style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}