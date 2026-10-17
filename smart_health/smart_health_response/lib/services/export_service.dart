import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/constants/enums.dart';
import '../providers/admin_provider.dart';

class ExportService {
  ExportService._();

  // ── PDF ──────────────────────────────────────────────────────────────
  static Future<File> generatePdf(AdminProvider data) async {
    // Load Unicode-capable fonts from Google Fonts.
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document();
    final now = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    final baseStyle = pw.TextStyle(font: font, fontSize: 10);
    final headerStyle = pw.TextStyle(font: boldFont, fontSize: 9);
    final cellStyle = pw.TextStyle(font: font, fontSize: 8);
    final titleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 20,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Smart Health Response - System Report',
                style: titleStyle),
          ),
          pw.Text('Generated: $now\n', style: baseStyle),

          // -- Summary --
          pw.Header(level: 1, text: 'System Overview'),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            cellStyle: cellStyle,
            headers: ['Metric', 'Count'],
            data: [
              ['Users', '${data.users.length}'],
              ['Reporters', '${data.reporters.length}'],
              ['Responders', '${data.responders.length}'],
              ['Facilities', '${data.facilities.length}'],
              ['AEDs', '${data.aeds.length}'],
              ['Cases', '${data.allCases.length}'],
            ],
          ),
          pw.SizedBox(height: 16),

          // -- Cases table --
          pw.Header(level: 1, text: 'Cases'),
          if (data.allCases.isEmpty)
            pw.Text('No cases.', style: baseStyle)
          else
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Type', 'Status', 'Created'],
              headerStyle: headerStyle,
              cellStyle: cellStyle,
              data: data.allCases.map((c) {
                final id = c.caseId.length > 12
                    ? '${c.caseId.substring(0, 12)}...'
                    : c.caseId;
                return [
                  id,
                  c.incidentType.label,
                  c.caseStatus.label,
                  DateFormat('dd/MM/yy HH:mm').format(c.createdAt),
                ];
              }).toList(),
            ),
          pw.SizedBox(height: 16),

          // -- Facilities table --
          pw.Header(level: 1, text: 'Facilities'),
          if (data.facilities.isEmpty)
            pw.Text('No facilities.', style: baseStyle)
          else
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Type', 'Capacity', 'Available', 'Active'],
              headerStyle: headerStyle,
              cellStyle: cellStyle,
              data: data.facilities.map((f) => [
                f.facilityName,
                f.facilityType.name,
                '${f.capacity}',
                '${f.availableBeds}',
                f.isActive ? 'Yes' : 'No',
              ]).toList(),
            ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/shr_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Excel ────────────────────────────────────────────────────────────
  static Future<File> generateExcel(AdminProvider data) async {
    final excel = xl.Excel.createExcel();

    // -- Cases sheet --
    final casesSheet = excel['Cases'];
    casesSheet.appendRow([
      xl.TextCellValue('Case ID'),
      xl.TextCellValue('Type'),
      xl.TextCellValue('Status'),
      xl.TextCellValue('Reporter'),
      xl.TextCellValue('Responder'),
      xl.TextCellValue('Facility'),
      xl.TextCellValue('Created'),
    ]);
    for (final c in data.allCases) {
      casesSheet.appendRow([
        xl.TextCellValue(c.caseId),
        xl.TextCellValue(c.incidentType.label),
        xl.TextCellValue(c.caseStatus.label),
        xl.TextCellValue(c.reporterId),
        xl.TextCellValue(c.responderId ?? ''),
        xl.TextCellValue(c.facilityId ?? ''),
        xl.TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(c.createdAt)),
      ]);
    }

    // -- Users sheet --
    final usersSheet = excel['Users'];
    usersSheet.appendRow([
      xl.TextCellValue('User ID'),
      xl.TextCellValue('Name'),
      xl.TextCellValue('Email'),
      xl.TextCellValue('Role'),
      xl.TextCellValue('Active'),
      xl.TextCellValue('Created'),
    ]);
    for (final u in data.users) {
      usersSheet.appendRow([
        xl.TextCellValue(u.userId),
        xl.TextCellValue(u.fullName),
        xl.TextCellValue(u.email),
        xl.TextCellValue(u.userType.name),
        xl.TextCellValue(u.isActive ? 'Yes' : 'No'),
        xl.TextCellValue(DateFormat('dd/MM/yyyy').format(u.createdAt)),
      ]);
    }

    // -- Facilities sheet --
    final facSheet = excel['Facilities'];
    facSheet.appendRow([
      xl.TextCellValue('Facility ID'),
      xl.TextCellValue('Name'),
      xl.TextCellValue('Type'),
      xl.TextCellValue('Address'),
      xl.TextCellValue('Phone'),
      xl.TextCellValue('Capacity'),
      xl.TextCellValue('Available'),
      xl.TextCellValue('Active'),
    ]);
    for (final f in data.facilities) {
      facSheet.appendRow([
        xl.TextCellValue(f.facilityId),
        xl.TextCellValue(f.facilityName),
        xl.TextCellValue(f.facilityType.name),
        xl.TextCellValue(f.address),
        xl.TextCellValue(f.contactNumber),
        xl.IntCellValue(f.capacity),
        xl.IntCellValue(f.availableBeds),
        xl.TextCellValue(f.isActive ? 'Yes' : 'No'),
      ]);
    }

    // Remove default Sheet1 if it exists.
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/shr_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }
}
