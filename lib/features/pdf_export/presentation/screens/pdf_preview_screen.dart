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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('CV Stüdyosu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withRed(100),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          _buildLanguageToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 4.0,
        minScale: 1.0,
        child: PdfPreview(
          build: (format) => ref
              .read(pdfGeneratorServiceProvider)
              .generateCv(widget.template, language: _currentLanguage),
          canDebug: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          loadingWidget: const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3))),
          pdfFileName:
              'CV_${_currentLanguage == CvLanguage.en ? 'EN' : 'TR'}.pdf',
          key: ValueKey('${_currentLanguage}_${widget.template}'),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'TR',
            isSelected: _currentLanguage == CvLanguage.tr,
            onTap: () => setState(() => _currentLanguage = CvLanguage.tr),
          ),
          _LanguageButton(
            label: 'EN',
            isSelected: _currentLanguage == CvLanguage.en,
            onTap: () => setState(() => _currentLanguage = CvLanguage.en),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] 
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2196F3) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
