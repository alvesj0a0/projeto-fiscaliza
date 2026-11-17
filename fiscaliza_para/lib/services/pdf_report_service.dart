import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vistoria_model.dart';
import '../models/item_vistoria_model.dart';

class PdfReportService {
  /// Gera o documento PDF em memória e abre o menu de impressão/partilha
  static Future<void> gerarECompartilharRelatorio({
    required VistoriaModel vistoria,
    required List<ItemVistoriaModel> itens,
    required String nomeEscola,
    required String inepEscola,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- CABEÇALHO INSTITUCIONAL ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GOVERNO DO ESTADO DO PARÁ',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        'SEDUC - Secretaria de Estado de Educação',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Fiscaliza Pará - Sistema de Monitoramento',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.teal900),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'TERMO DE VISTORIA',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              // --- DADOS DA UNIDADE E VISTORIA ---
              pw.Text(
                '1. IDENTIFICAÇÃO DA UNIDADE',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Escola: $nomeEscola (INEP: $inepEscola)'),
                    pw.Text('Programa Fiscalizado: ${vistoria.tipoPrograma}'),
                    pw.Text('Data/Hora UTC: ${vistoria.dataUtc}'),
                    pw.Text(
                      'Localização GPS: ${vistoria.latitude ?? 0.0}, ${vistoria.longitude ?? 0.0} (Precisão: ${vistoria.precisao ?? 0.0}m)',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // --- ITENS FISCALIZADOS ---
              pw.Text(
                '2. ITENS E CONDIÇÕES VERIFICADAS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qtd. Rec.', 'Qtd. Nota', 'Lote', 'Status'],
                data: itens.map((item) {
                  return [
                    item.nomeItem,
                    '${item.qtdRecebida ?? '-'}',
                    '${item.qtdNota ?? '-'}',
                    item.lote ?? '-',
                    item.status,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.teal800,
                ),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),

              // --- AUDITORIA E HASH SHA-256 ---
              pw.Text(
                '3. CHAVE DE AUTENTICIDADE E AUDITORIA',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: vistoria.hashSha256,
                    width: 70,
                    height: 70,
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'HASH SHA-256 (Assinatura Digital):',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          vistoria.hashSha256,
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Documento assinado digitalmente no dispositivo fiscal sem dependência de sinal de internet.',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // --- ASSINATURAS DO RODAPÉ ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 160, child: pw.Divider(thickness: 1)),
                      pw.Text(
                        'Fiscal Responsável',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 160, child: pw.Divider(thickness: 1)),
                      pw.Text(
                        'Direção / Responsável pela Escolar',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Abre a pré-visualização de impressão ou diálogo de partilha/guardar em PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Termo_Vistoria_${vistoria.id.substring(0, 8)}.pdf',
    );
  }
}
