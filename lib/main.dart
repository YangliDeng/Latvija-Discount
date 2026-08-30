import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

import 'images.dart';
import 'leaflet.dart';
import 'pdf_page.dart';
import 'animation.dart';

// jsDelivr CDN address for the GitHub repository.
const String repoCdnBaseUrl =
    'https://cdn.jsdelivr.net/gh/YangliDeng/Latvija-Discount@main/';

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
  State<HomePage> createState() => _State();
}

class _State extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Leaflet> leaflets = [];

  bool _loading = true;
  String? _error;

  int _currentIndex = 0;

  late AnimationController _controller;

  Color getWaveColor() {
    if (leaflets.isEmpty) {
      return Colors.blue;
    }

    final currentLeaflet = leaflets[_currentIndex];

    switch (currentLeaflet.name.toLowerCase()) {
      case 'maxima':
        return Colors.blue;
      case 'rimi':
        return Colors.red;
      case 'lidl':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    getManifest();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getManifest() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final manifestUrl = Uri.parse(
        '${repoCdnBaseUrl}manifest.json',
      );

      final response = await http.get(manifestUrl);

      debugPrint('Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final stores = data['stores'];

      setState(() {
        leaflets = stores
            .map<Leaflet>(
              (store) => Leaflet.fromJson(store),
        )
            .toList();

        _loading = false;
      });
    } catch (e) {
      debugPrint('getManifest failed: $e');

      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _openLeaflet(Leaflet leaflet) {
    final pdfUrl = repoCdnBaseUrl + leaflet.path;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPage(
          title: leaflet.name,
          pdfUrl: pdfUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SizedBox.expand(
                child: CustomPaint(
                  painter: WavePainter(
                    _controller.value,
                    getWaveColor(),
                  ),
                ),
              );
            },
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                margin: const EdgeInsets.only(
                  left: 140,
                  right: 140,
                  top: 30,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF9E3039),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(40),
                    right: Radius.circular(40),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Latvija Discount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load stores:\n$_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: getManifest,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (leaflets.isEmpty) {
      return const Center(
        child: Text('No stores available'),
      );
    }

    return Center(
      child: CarouselSlider.builder(
        itemCount: leaflets.length,
        itemBuilder: (context, index, realIndex) {
          final leaflet = leaflets[index];

          final market = Images.marketIcons.firstWhere(
                (market) =>
            market.id == leaflet.name.toLowerCase(),
            orElse: () => Images.marketIcons.first,
          );

          return AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            offset: index == _currentIndex
                ? const Offset(0, -0.15)
                : Offset.zero,
            child: GestureDetector(
              onTap: () => _openLeaflet(leaflet),
              child: Image.asset(
                market.url,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 200,
          viewportFraction: 0.6,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          clipBehavior: Clip.none,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}