import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';

/// Generates a formatted PDF health report and shares it.
class PdfExportService {
  static Future<void> generateAndShareReport({
    required String userName,
    required List<Medicine> medicines,
    required List<HistoryEntry> history,
    required List<HealthMeasurement> healthData,
  }) async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    final fmtLong = DateFormat('dd MMM yyyy, HH:mm');
    final now = DateTime.now();

    // Calculate adherence stats
    final taken = history.where((h) => h.status == 'taken').length;
    final skipped = history.where((h) => h.status == 'skipped').length;
    final missed = history.where((h) => h.status == 'missed').length;
    final total = history.length;
    final pct = total == 0 ? 0 : (taken / total * 100).round();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('MediFlow — Health Report',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated: ${fmt.format(now)}',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text('Patient: $userName',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (pw.Context context) => pw.Column(
          children: [
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Text(
              '⚠️ MEDICAL DISCLAIMER: MediFlow is a medication organization tool only. '
              'It does not provide medical advice, diagnosis, or treatment. '
              'Always consult your healthcare provider.',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
        build: (pw.Context context) => [
          // ── Medicines section
          pw.Text('MEDICINES (${medicines.length})',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (medicines.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Form', 'Strength', 'Category'],
              data: medicines
                  .map((m) => [
                        m.verifiedName,
                        m.form ?? '—',
                        m.strength ?? '—',
                        m.category ?? '—',
                      ])
                  .toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              cellAlignment: pw.Alignment.centerLeft,
            )
          else
            pw.Text('No medicines recorded.',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 20),

          // ── Adherence summary
          pw.Text('ADHERENCE SUMMARY',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _statBox('Total Doses', '$total'),
              pw.SizedBox(width: 16),
              _statBox('Taken', '$taken'),
              pw.SizedBox(width: 16),
              _statBox('Skipped', '$skipped'),
              pw.SizedBox(width: 16),
              _statBox('Missed', '$missed'),
              pw.SizedBox(width: 16),
              _statBox('Adherence', '$pct%'),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Recent history
          pw.Text('RECENT DOSE HISTORY (Last 30 entries)',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (history.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: ['Date/Time', 'Medicine', 'Status'],
              data: history.take(30).map((h) {
                final medName = medicines
                    .where((m) => m.id == h.medicineId)
                    .map((m) => m.verifiedName)
                    .firstOrNull ?? 'Unknown';
                return [
                  fmtLong.format(h.scheduledTime),
                  medName,
                  h.status.toUpperCase(),
                ];
              }).toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              cellAlignment: pw.Alignment.centerLeft,
            )
          else
            pw.Text('No dose history recorded.',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 20),

          // ── Health data
          if (healthData.isNotEmpty) ...[
            pw.Text('HEALTH MEASUREMENTS (Last 20 entries)',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Type', 'Value', 'Unit'],
              data: healthData.take(20).map((h) {
                return [
                  fmtLong.format(h.recordedAt),
                  h.type,
                  h.value % 1 == 0
                      ? h.value.toInt().toString()
                      : h.value.toStringAsFixed(1),
                  h.unit,
                ];
              }).toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ],
      ),
    );

    final bytes = await pdf.save();
    final now2 = DateTime.now();
    final fileName = 'mediflow_report_${now2.year}${now2.month.toString().padLeft(2, '0')}${now2.day.toString().padLeft(2, '0')}.pdf';

    Directory? dir;
    try {
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
    } catch (_) {}
    dir ??= await getTemporaryDirectory();

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
      subject: 'MediFlow Health Report — $userName',
      text: 'Your MediFlow medication report generated on ${fmt.format(now2)}',
    ));
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }
}
