import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

import 'images.dart';
import 'leaflet.dart';
import 'pdf_page.dart';

// The reusable folder prefix — stick any filename on the end to get its
// raw URL, e.g. repoRawBaseUrl + 'manifest.json', or repoRawBaseUrl + leaflet.path.
const String repoRawBaseUrl =
    'https://raw.githubusercontent.com/YangliDeng/Latvija-Discount/refs/heads/main/';

main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _State();
}

class _State extends State<HomePage> {
  List<Leaflet> leaflets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    getManifest();
  }

  Future<void> getManifest() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(repoRawBaseUrl + 'manifest.json'));

      print('Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final stores = data['stores'];

      setState(() {
        leaflets = stores.map<Leaflet>((store) => Leaflet.fromJson(store)).toList();
        _loading = false;
      });
    } catch (e) {
      print('getManifest failed: $e');
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _openLeaflet(Leaflet leaflet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPage(
          title: leaflet.name,
          pdfUrl: repoRawBaseUrl + leaflet.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 140, right: 140, top: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF9E3039),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(40),
                  right: Radius.circular(40),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Latvija Discount',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Could not load stores:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: getManifest, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (leaflets.isEmpty) {
      return const Center(child: Text('No stores available'));
    }

    return Center(
      child: CarouselSlider.builder(
        itemCount: leaflets.length,
        itemBuilder: (context, index, realIndex) {
          final leaflet = leaflets[index];
          final market = Images.marketIcons.firstWhere(
                (m) => m.id == leaflet.id,
            orElse: () => Images.marketIcons.first,
          );

          return GestureDetector(
            onTap: () => _openLeaflet(leaflet),
            child: Image.asset(market.url, fit: BoxFit.contain),
          );
        },
        options: CarouselOptions(height: 200, enlargeCenterPage: true),
      ),
    );
  }
}