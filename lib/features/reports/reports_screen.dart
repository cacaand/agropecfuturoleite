import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Relatórios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Exportar dados em PDF', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SectionHeader(title: 'Relatórios disponíveis'),
        _ReportCard(icon: Icons.pets_rounded,                    color: AppColors.green700, bg: AppColors.green50,
          title: 'Relatório do Rebanho',       subtitle: 'Lista completa de animais',          onPdf: () => _animalsPdf(context, db)),
        _ReportCard(icon: Icons.water_drop_rounded,              color: AppColors.blue600,  bg: AppColors.blue50,
          title: 'Produção Leiteira',           subtitle: 'Histórico de produção',              onPdf: () => _milkPdf(context, db)),
        _ReportCard(icon: Icons.account_balance_wallet_rounded,  color: AppColors.amber500, bg: AppColors.amber50,
          title: 'Relatório Financeiro',        subtitle: 'Receitas, despesas e lucro',         onPdf: () => _financePdf(context, db)),
        _ReportCard(icon: Icons.vaccines_rounded,                color: AppColors.purple600,bg: AppColors.purple100,
          title: 'Calendário de Vacinas',       subtitle: 'Vacinas aplicadas e próximas doses', onPdf: () => _vaccinePdf(context, db)),
        _ReportCard(icon: Icons.local_hospital_rounded,          color: AppColors.red600,   bg: AppColors.red50,
          title: 'Relatório Sanitário',         subtitle: 'Doenças, tratamentos e exames',      onPdf: () => _healthPdf(context, db)),
        _ReportCard(icon: Icons.favorite_rounded,                color: AppColors.purple600,bg: AppColors.purple100,
          title: 'Reprodução',                  subtitle: 'Inseminações, diagnósticos e partos',onPdf: () => _reproPdf(context, db)),
      ]),
    );
  }

  // ─── PDF BUILDERS ──────────────────────────────────────────────────────────

  pw.Widget _header(String title) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('GadoLeite ERP', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
    pw.Text(title, style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
    pw.Text('Gerado: ${DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now())}',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
    pw.Divider(color: PdfColors.green200),
    pw.SizedBox(height: 8),
  ]);

  pw.Widget _footer(pw.Context ctx) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
    pw.Text('Desenvolvido por IAmina', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
    pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
  ]);

  pw.Widget _stat(String label, String value) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
    pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
  ]);

  Future<void> _animalsPdf(BuildContext context, AppDatabase db) async {
    final animals = await db.watchAnimals().first;
    final fmt = DateFormat('dd/MM/yyyy');
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _header('Relatório do Rebanho'),
      footer: _footer,
      build: (ctx) => [
        pw.Text('Total: ${animals.length} animais', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['Código','Nome','Raça','Sexo','Categoria','Status','Peso','Nascimento'],
          data: animals.map<List<String>>((a) => [
            '#${a.code}', a.name ?? '—', a.breed,
            a.sex == 'FEMALE' ? 'F' : 'M',
            _catLabel(a.category), _statusLabel(a.status),
            a.weight != null ? '${a.weight!.toStringAsFixed(0)}kg' : '—',
            a.birthDate != null ? fmt.format(a.birthDate!) : '—',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> _milkPdf(BuildContext context, AppDatabase db) async {
    final records = await db.watchMilkRecords().first;
    final total = records.fold<double>(0, (s, r) => s + r.volume);
    final avg   = records.isNotEmpty ? total / records.length : 0.0;
    final pdf   = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        _header('Produção Leiteira'),
        pw.Row(children: [
          _stat('Registros', '${records.length}'), pw.SizedBox(width: 32),
          _stat('Total', '${total.toStringAsFixed(1)}L'), pw.SizedBox(width: 32),
          _stat('Média', '${avg.toStringAsFixed(1)}L/ordenha'),
        ]),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Data','Turno','Volume (L)','Gordura %','Proteína %'],
          data: records.take(100).map<List<String>>((r) => [
            DateFormat('dd/MM/yy HH:mm').format(r.date),
            r.shift == 'MORNING' ? 'Manhã' : r.shift == 'AFTERNOON' ? 'Tarde' : 'Noite',
            r.volume.toStringAsFixed(2),
            r.fat?.toStringAsFixed(2) ?? '—',
            r.protein?.toStringAsFixed(2) ?? '—',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> _financePdf(BuildContext context, AppDatabase db) async {
    final records  = await db.watchFinances().first;
    final fin      = await db.getMonthFinancials();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final pdf      = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        _header('Relatório Financeiro'),
        pw.Row(children: [
          _stat('Receitas', currency.format(fin['income'])), pw.SizedBox(width: 32),
          _stat('Despesas', currency.format(fin['expense'])), pw.SizedBox(width: 32),
          _stat('Lucro', currency.format(fin['profit'])),
        ]),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Data','Tipo','Categoria','Descrição','Valor'],
          data: records.map<List<String>>((r) => [
            DateFormat('dd/MM/yy').format(r.date),
            r.type == 'INCOME' ? 'Receita' : 'Despesa',
            r.category.toLowerCase().replaceAll('_', ' '),
            r.description, currency.format(r.amount),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> _vaccinePdf(BuildContext context, AppDatabase db) async {
    final records = await db.watchVaccineRecords().first;
    final fmt = DateFormat('dd/MM/yyyy');
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        _header('Calendário de Vacinas'),
        pw.TableHelper.fromTextArray(
          headers: ['Vacina','Doença','Aplicação','Próx. Dose','Lote','Status'],
          data: records.map<List<String>>((r) {
            final overdue = r.nextDose != null && r.nextDose!.isBefore(DateTime.now());
            return [r.vaccineName, r.disease, fmt.format(r.date),
              r.nextDose != null ? fmt.format(r.nextDose!) : '—',
              r.batch ?? '—', overdue ? 'VENCIDA' : 'Em dia'];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> _healthPdf(BuildContext context, AppDatabase db) async {
    final records = await db.watchHealthEvents().first;
    final fmt = DateFormat('dd/MM/yyyy');
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        _header('Relatório Sanitário'),
        pw.TableHelper.fromTextArray(
          headers: ['Data','Tipo','Diagnóstico','Tratamento','Medicamento'],
          data: records.map<List<String>>((h) => [
            fmt.format(h.date), h.type,
            h.diagnosis ?? '—', h.treatment ?? '—', h.medication ?? '—',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> _reproPdf(BuildContext context, AppDatabase db) async {
    final records = await db.watchReproductions().first;
    final fmt = DateFormat('dd/MM/yyyy');
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        _header('Relatório Reprodutivo'),
        pw.TableHelper.fromTextArray(
          headers: ['Data','Tipo','Touro','Status','Parto Previsto'],
          data: records.map<List<String>>((r) => [
            fmt.format(r.date), r.type, r.sireName ?? '—', r.status,
            r.expectedBirth != null ? fmt.format(r.expectedBirth!) : '—',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellStyle: const pw.TextStyle(fontSize: 9),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.green50),
          border: pw.TableBorder.all(color: PdfColors.green200, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  String _catLabel(String c) => switch (c) {
    'DAIRY_COW' => 'V.Leiteira', 'HEIFER' => 'Novilha',
    'CALF' => 'Bezerra(o)', 'BULL' => 'Touro', _ => c,
  };
  String _statusLabel(String s) => switch (s) {
    'ACTIVE' => 'Ativa', 'PREGNANT' => 'Prenhe', 'DRY' => 'Seca', 'SICK' => 'Doente', _ => s,
  };
}

class _ReportCard extends StatelessWidget {
  final IconData icon; final Color color, bg;
  final String title, subtitle; final VoidCallback onPdf;
  const _ReportCard({required this.icon, required this.color, required this.bg,
    required this.title, required this.subtitle, required this.onPdf});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
      ])),
      const SizedBox(width: 8),
      GestureDetector(onTap: onPdf, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.red600.withOpacity(0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.red600),
          const SizedBox(width: 4),
          Text('PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.red600)),
        ]),
      )),
    ]),
  );
}
