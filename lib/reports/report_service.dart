// lib/reports/report_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../checkin/checkin_service.dart';
import '../lessons/lesson_service.dart';

/// Service for generating progress reports and certificates
class ReportService {
  final CheckInService _checkInService = CheckInService();
  final LessonService _lessonService = LessonService();

  /// Generate weekly completion certificate
  Future<pw.Document> generateWeeklyCertificate(int week) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final lessons = _lessonService.getLessonsForWeek(week);
    final completed = await _lessonService.getWeeklyCompletedCount(week);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 20),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.indigo700,
                        width: 3,
                      ),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ClearPath Recovery',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo700,
                        ),
                      ),
                      pw.Text(
                        DateFormat('MMM d, y').format(now),
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Certificate title
                pw.Center(
                  child: pw.Text(
                    'Certificate of Completion',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 30),

                // Week info
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Week $week',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _getWeekTitle(week),
                        style: const pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Completion stats
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Program Completion Details',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Lessons Completed:'),
                          pw.Text(
                            '$completed / ${lessons.length}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Completion Rate:'),
                          pw.Text(
                            '${((completed / lessons.length) * 100).toInt()}%',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 20),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'This certificate confirms participation in the ClearPath Recovery educational program.',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Document ID: CERT-W$week-${now.millisecondsSinceEpoch}',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Generate compliance report for court/probation
  Future<pw.Document> generateComplianceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    
    // Get data
    final allCheckIns = await _checkInService.getAllCheckIns();
    final checkIns = allCheckIns.where((c) {
      return c.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             c.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    final totalLessons = await _lessonService.getTotalCompletedCount();
    final streak = await _checkInService.getCurrentStreak();
    final daysSober = await _checkInService.getDaysSinceLastUse();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ClearPath Recovery',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Progress & Compliance Report',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Generated: ${DateFormat('MMM d, y').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Period: ${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Summary section
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildReportRow('Current Streak:', '$streak days'),
                      pw.SizedBox(height: 8),
                      _buildReportRow('Days Substance-Free:', '$daysSober days'),
                      pw.SizedBox(height: 8),
                      _buildReportRow('Total Check-Ins:', '${checkIns.length}'),
                      pw.SizedBox(height: 8),
                      _buildReportRow('Lessons Completed:', '$totalLessons'),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                // Check-in history
                pw.Text(
                  'Daily Check-In History',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                if (checkIns.isEmpty)
                  pw.Text(
                    'No check-ins recorded for this period.',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  )
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey200,
                        ),
                        children: [
                          _buildTableCell('Date', isHeader: true),
                          _buildTableCell('Mood', isHeader: true),
                          _buildTableCell('Cravings', isHeader: true),
                          _buildTableCell('Substance Free', isHeader: true),
                        ],
                      ),
                      // Data rows
                      ...checkIns.map((checkIn) {
                        return pw.TableRow(
                          children: [
                            _buildTableCell(DateFormat('MMM d').format(checkIn.date)),
                            _buildTableCell('${checkIn.moodRating}/10'),
                            _buildTableCell('${checkIn.cravingIntensity}/10'),
                            _buildTableCell(checkIn.substanceUsed ? 'No' : 'Yes'),
                          ],
                        );
                      }),
                    ],
                  ),

                pw.Spacer(),

                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 20),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Disclaimer: This report documents participation in a psycho-educational recovery support program. It is not a substitute for clinical treatment or medical advice.',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Report ID: RPT-${DateTime.now().millisecondsSinceEpoch}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Helper: Build report row
  pw.Widget _buildReportRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Helper: Build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Save PDF to device
  Future<File> savePdfToDevice(pw.Document pdf, String filename) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Share PDF
  Future<void> sharePdf(pw.Document pdf, String filename) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  /// Print PDF
  Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  /// Preview PDF
  Future<void> previewPdf(pw.Document pdf, String title) async {
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: title,
    );
  }

  String _getWeekTitle(int week) {
    switch (week) {
      case 1: return 'Understanding Addiction';
      case 2: return 'Triggers & Cravings';
      case 3: return 'Thinking Patterns';
      case 4: return 'Emotional Regulation';
      case 5: return 'Trauma & Substance Use';
      case 6: return 'Relapse Prevention';
      case 7: return 'Relationships & Accountability';
      case 8: return 'Identity & Purpose';
      case 9: return 'Anxiety, Depression & Stress';
      case 10: return 'Spirituality (Optional)';
      case 11: return 'Lifestyle & Structure';
      case 12: return 'Long-Term Recovery';
      default: return 'Recovery';
    }
  }
}