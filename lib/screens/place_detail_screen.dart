import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/place.dart';
import '../services/database_helper.dart';
import '../services/image_storage_service.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  const PlaceDetailScreen({super.key, required this.place});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('A foto e os dados deste registro serão removidos do aparelho.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseHelper.instance.deletePlace(place.id);
    await ImageStorageService().deleteImage(place.imagePath);
    if (context.mounted) Navigator.pop(context, true);
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${place.latitude}&mlon=${place.longitude}#map=16/${place.latitude}/${place.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do registro'),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(place.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 220,
                child: Center(child: Icon(Icons.broken_image_outlined, size: 56)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            place.title.isEmpty ? 'Sem descrição' : place.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data e horário',
            value: DateFormat('dd/MM/yyyy • HH:mm:ss').format(place.dateTime),
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Latitude',
            value: place.latitude.toStringAsFixed(7),
          ),
          _InfoRow(
            icon: Icons.explore_outlined,
            label: 'Longitude',
            value: place.longitude.toStringAsFixed(7),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver localização no mapa'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(
                text: '${place.latitude}, ${place.longitude}',
              ));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coordenadas copiadas.')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar coordenadas'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 3),
                  SelectableText(value),
                ],
              ),
            ),
          ],
        ),
      );
}
