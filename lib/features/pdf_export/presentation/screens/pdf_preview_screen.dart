import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_flow/features/pdf_export/services/pdf_generator_service.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final CvTemplate template;

  const PdfPreviewScreen({super.key, required this.template});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  CvLanguage _currentLanguage = CvLanguage.en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Önizleme'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                'TR',
                style: TextStyle(
                  color: _currentLanguage == CvLanguage.tr ? Colors.white : Colors.white70,
                  fontWeight: _currentLanguage == CvLanguage.tr ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Switch(
                value: _currentLanguage == CvLanguage.en,
                activeColor: Colors.white,
                activeTrackColor: Colors.blue.shade200,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.blue.shade200,
                onChanged: (value) {
                  setState(() {
                    _currentLanguage = value ? CvLanguage.en : CvLanguage.tr;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  'EN',
                  style: TextStyle(
                    color: _currentLanguage == CvLanguage.en ? Colors.white : Colors.white70,
                    fontWeight: _currentLanguage == CvLanguage.en ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => ref.read(pdfGeneratorServiceProvider).generateCv(widget.template, language: _currentLanguage),
        canDebug: false,
        canChangePageFormat: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        pdfFileName: 'CV_${_currentLanguage == CvLanguage.en ? 'EN' : 'TR'}.pdf',
        key: ValueKey(_currentLanguage), // Force rebuild when language changes
      ),
    );
  }
}
