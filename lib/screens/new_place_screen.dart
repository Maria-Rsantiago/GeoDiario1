import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/place.dart';
import '../services/database_helper.dart';
import '../services/image_storage_service.dart';
import '../services/location_service.dart';

class NewPlaceScreen extends StatefulWidget {
  const NewPlaceScreen({super.key});

  @override
  State<NewPlaceScreen> createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends State<NewPlaceScreen> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _locationService = LocationService();
  final _imageStorage = ImageStorageService();

  XFile? _image;
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  bool _saving = false;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (image != null && mounted) setState(() => _image = image);
  }

  Future<void> _chooseFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (image != null && mounted) setState(() => _image = image);
  }

  Future<void> _captureLocation() async {
    setState(() {
      _gettingLocation = true;
      _locationMessage = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationMessage = 'Localização obtida com sucesso.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _locationMessage = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _save() async {
    if (_image == null) {
      _message('Tire uma foto ou escolha uma imagem.');
      return;
    }
    if (_latitude == null || _longitude == null) {
      _message('Não foi possível obter o GPS. Verifique a permissão e tente novamente.');
      return;
    }

    setState(() => _saving = true);
    String? savedImagePath;
    try {
      final id = const Uuid().v4();
      savedImagePath = await _imageStorage.saveImage(File(_image!.path), id);
      final place = Place(
        id: id,
        title: _descriptionController.text.trim(),
        imagePath: savedImagePath,
        latitude: _latitude!,
        longitude: _longitude!,
        dateTime: DateTime.now(),
      );
      await DatabaseHelper.instance.insertPlace(place);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (savedImagePath != null) {
        await _imageStorage.deleteImage(savedImagePath);
      }
      _message('Erro ao salvar o registro: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova foto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 280,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: _image == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 58, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Sua foto aparecerá aqui'),
                    ],
                  )
                : Image.file(File(_image!.path), fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chooseFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex.: Passeio no parque',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Localização GPS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        if (_gettingLocation)
                          const Text('Obtendo localização...')
                        else if (_latitude != null && _longitude != null)
                          Text(
                            '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                          )
                        else
                          Text(_locationMessage ?? 'Localização ainda não disponível'),
                        if (_locationMessage != null && _latitude == null)
                          Text(_locationMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tentar novamente',
                    onPressed: _gettingLocation ? null : _captureLocation,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Salvando...' : 'Salvar registro'),
          ),
        ],
      ),
    );
  }
}
