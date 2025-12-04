
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Buscar usuarios o clubes...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // TODO: Lógica de búsqueda en tiempo real
          },
        ),
      ),
      body: Center(
        child: Text("Resultados de la búsqueda aparecerán aquí."),
      ),
    );
  }
}
