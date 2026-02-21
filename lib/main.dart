import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final poundController = TextEditingController();

  double? dollarRate;
  double? euroRate;
  double? poundRate;

  Future<void> getRates() async {
    final url = Uri.parse(
        "https://api.exchangerate.host/latest?base=BRL&symbols=USD,EUR,GBP");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load exchange rates");
    }

    final data = json.decode(response.body);

    dollarRate = data["rates"]["USD"];
    euroRate = data["rates"]["EUR"];
    poundRate = data["rates"]["GBP"];
  }

  void realChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    final real = double.tryParse(text);
    if (real == null) return;

    dollarController.text =
        (real * dollarRate!).toStringAsFixed(2);
    euroController.text =
        (real * euroRate!).toStringAsFixed(2);
    poundController.text =
        (real * poundRate!).toStringAsFixed(2);
  }

  void dollarChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    final dollar = double.tryParse(text);
    if (dollar == null) return;

    realController.text =
        (dollar / dollarRate!).toStringAsFixed(2);
    euroController.text =
        (realValue() * euroRate!).toStringAsFixed(2);
    poundController.text =
        (realValue() * poundRate!).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    final euro = double.tryParse(text);
    if (euro == null) return;

    realController.text =
        (euro / euroRate!).toStringAsFixed(2);
    dollarController.text =
        (realValue() * dollarRate!).toStringAsFixed(2);
    poundController.text =
        (realValue() * poundRate!).toStringAsFixed(2);
  }

  void poundChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    final pound = double.tryParse(text);
    if (pound == null) return;

    realController.text =
        (pound / poundRate!).toStringAsFixed(2);
    dollarController.text =
        (realValue() * dollarRate!).toStringAsFixed(2);
    euroController.text =
        (realValue() * euroRate!).toStringAsFixed(2);
  }

  double realValue() {
    return double.tryParse(realController.text) ?? 0.0;
  }

  void clearAll() {
    realController.clear();
    dollarController.clear();
    euroController.clear();
    poundController.clear();
  }

  Widget buildTextField(
    String label,
    String prefix,
    TextEditingController controller,
    void Function(String) onChanged,
  ) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getRates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading exchange rates"),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildTextField(
                    "Real", "R\$ ", realController, realChanged),
                const SizedBox(height: 12),
                buildTextField(
                    "Dollar", "\$ ", dollarController, dollarChanged),
                const SizedBox(height: 12),
                buildTextField(
                    "Euro", "€ ", euroController, euroChanged),
                const SizedBox(height: 12),
                buildTextField(
                    "Pound", "£ ", poundController, poundChanged),
              ],
            ),
          );
        },
      ),
    );
  }
}