import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/place.dart';
import '../services/database_helper.dart';
import 'new_place_screen.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Place> _places = [];
  bool _newestFirst = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    final places = await DatabaseHelper.instance.getPlaces(
      newestFirst: _newestFirst,
    );
    if (!mounted) return;
    setState(() {
      _places = places;
      _loading = false;
    });
  }

  List<Place> get _filteredPlaces {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _places;
    return _places.where((place) {
      final date = DateFormat('dd/MM/yyyy HH:mm').format(place.dateTime);
      return place.title.toLowerCase().contains(query) ||
          date.toLowerCase().contains(query) ||
          place.latitude.toString().contains(query) ||
          place.longitude.toString().contains(query);
    }).toList();
  }

  Future<void> _openNewPlace() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NewPlaceScreen()),
    );
    if (saved == true) _loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final places = _filteredPlaces;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GeoDiário', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Suas memórias, com lugar e momento',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _newestFirst ? 'Mais antigos primeiro' : 'Mais recentes primeiro',
            onPressed: () {
              setState(() => _newestFirst = !_newestFirst);
              _loadPlaces();
            },
            icon: const Icon(Icons.swap_vert),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPlace,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nova foto'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por descrição, data ou coordenada',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : places.isEmpty
                    ? _EmptyState(hasSearch: _searchController.text.isNotEmpty)
                    : RefreshIndicator(
                        onRefresh: _loadPlaces,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaceDetailScreen(place: place),
                                    ),
                                  );
                                  _loadPlaces();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 112,
                                      height: 112,
                                      child: Image.file(
                                        File(place.imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image_outlined,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.title.isEmpty ? 'Sem descrição' : place.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              DateFormat('dd/MM/yyyy • HH:mm').format(place.dateTime),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(hasSearch ? Icons.search_off : Icons.photo_library_outlined,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                hasSearch ? 'Nenhum registro encontrado' : 'Sua galeria está vazia',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                hasSearch
                    ? 'Tente buscar por outro termo.'
                    : 'Toque em “Nova foto” para criar sua primeira memória.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
