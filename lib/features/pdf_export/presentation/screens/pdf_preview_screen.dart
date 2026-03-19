import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_flow/features/pdf_export/services/pdf_generator_service.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final CvTemplate template;

  const PdfPreviewScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Önizleme'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => ref.read(pdfGeneratorServiceProvider).generateCv(template),
        canDebug: false,
        canChangePageFormat: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        pdfFileName: 'CV_Optimized.pdf',
      ),
    );
  }
}
