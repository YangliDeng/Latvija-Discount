import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

/// Downloads a PDF from a URL and displays it, page by page.
class PdfPage extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  PdfController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final document = PdfDocument.openData(response.bodyBytes);
      setState(() {
        _controller = PdfController(document: document);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load PDF: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      )
          : PdfView(controller: _controller!),
    );
  }
}