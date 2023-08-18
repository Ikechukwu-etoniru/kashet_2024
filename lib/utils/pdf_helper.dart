import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' as im;
import 'package:intl/intl.dart';
import 'package:kasheto_flutter/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/widgets.dart';
// import 'package:printing/printing.dart';

class PdfInvoiceApi {
  static Future<File> generate(
      {required List<Transaction> transaction,
      required num balance,
      required double moneyInBal,
      required double moneyOutBal}) async {
    // final netImage = pw.Image
     

    final pdf = Document();
    // final image = pdf.

    pdf.addPage(
      MultiPage(
          header: (context) {
            if (context.pageNumber != 1) {
              return SizedBox();
            }
            return SizedBox();
            // return buildHeader(netImage);
          },
          build: ((context) => [
                buildTitle(
                    moneyOutBal: moneyOutBal,
                    moneyInBal: moneyInBal,
                    currentBal: double.parse(balance.toString())),
                buildTable(transaction)
              ])),
    );

    return PdfApi.saveDocument(
        name: 'My Statement of Account ${DateTime.now()}', pdf: pdf);
  }
}

Widget buildHeader(ImageProvider netImage) {
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      color: PdfColors.green300,
      child: Row(children: [
        SizedBox(height: 70, child: Image(netImage)),
        Spacer(),
        Text(
          'Account Statement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )
      ]));
}

Widget buildTitle(
    {required double moneyOutBal,
    required double moneyInBal,
    required double currentBal}) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        Text('Summary',
            style: const TextStyle(fontSize: 24, color: PdfColors.green)),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(color: PdfColors.green),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Money Out'),
                  SizedBox(height: 0.5 * PdfPageFormat.cm),
                  Text(
                    moneyOutBal.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PdfColors.red,
                      fontSize: 18,
                    ),
                  )
                ]),
            SizedBox(width: 40),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Money In'),
                  SizedBox(height: 0.5 * PdfPageFormat.cm),
                  Text(
                    moneyInBal.toStringAsFixed(2),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green200,
                        fontSize: 18),
                  )
                ]),
            SizedBox(width: 40),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Balance'),
                  SizedBox(height: 0.5 * PdfPageFormat.cm),
                  Text(
                    currentBal.toStringAsFixed(2),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PdfColors.green,
                        fontSize: 18),
                  )
                ]),
          ]),
        ),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
      ]);
}

Widget buildTable(List<Transaction> tx) {
  final headers = ['Date', 'Money In', 'Money Out', 'Title', 'Description'];
  final data = tx.map((e) {
    String _txDate() {
      var time = e.createDate;
      var inDateTime = DateTime(
        int.parse(time.substring(0, 4)),
        int.parse(time.substring(5, 7)),
        int.parse(time.substring(8, 10)),
        int.parse(time.substring(11, 13)),
        int.parse(time.substring(14, 16)),
      );
      return DateFormat.yMMMEd().format(inDateTime);
    }

    String txTitle() {
      if (e.description.contains('AIRTIME')) {
        return 'Airtime Purchase';
      } else if (e.description.contains('You sent')) {
        return 'Fund Transfer';
      } else if (e.description.contains('Credited wallet')) {
        return 'Account Funding';
      } else if (e.description.contains('DStv') ||
          e.description.contains('DSTV')) {
        return 'DSTV Subscription ';
      } else if (e.description.contains('GOTV') ||
          e.description.contains('GOtv')) {
        return 'GOTV Subscription';
      } else if (e.description.contains('One')) {
        return 'Startimes Subscription';
      } else if (e.description.contains('Transferred')) {
        return 'Fund Transfer';
      } else if (e.description.contains('TOPUP')) {
        return 'Electricity Topup';
      } else if (e.description.contains('Withdrawal')) {
        return 'Withdrawal';
      } else if (e.description.contains('recieved')) {
        return 'Received Funds';
      } else if (e.description.contains('MTN') &&
          (e.description.contains('DATA') || e.description.contains('data'))) {
        return 'MTN Data Purchase';
      } else if (e.description.contains('GLO') &&
          (e.description.contains('DATA') || e.description.contains('data'))) {
        return 'GLO Data Purchase';
      } else if (e.description.contains('9MOBILE') &&
          (e.description.contains('DATA') || e.description.contains('data'))) {
        return '9MOBILE Data Purchase';
      } else if (e.description.contains('AIRTEL') &&
          (e.description.contains('DATA') || e.description.contains('data'))) {
        return 'AIRTEL Data Purchase';
      } else {
        return e.description;
      }
    }

    return [
      _txDate(),
      !e.amount.contains('-')
          ? 'KTC ${double.parse(e.amount.replaceAll(r'-', '')).toStringAsFixed(2)}'
          : '',
      e.amount.contains('-')
          ? 'KTC ${double.parse(e.amount.replaceAll(r'-', '')).toStringAsFixed(2)}'
          : '',
      txTitle(),
      e.description
    ];
  }).toList();
  return Table.fromTextArray(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 3),
      border: const TableBorder(
          bottom: BorderSide.none,
          horizontalInside: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          top: BorderSide.none),
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerPadding: const EdgeInsets.symmetric(horizontal: 5),
      headerDecoration: const BoxDecoration(color: PdfColors.green100),
      cellPadding: const EdgeInsets.symmetric(horizontal: 5),
      cellHeight: 40,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
      },
      headers: headers,
      data: data);
}

class PdfApi {
  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    // await OpenFilex.open(url, type: "application/pdf");
  }
}

pw.Document generatePdf() {
  final pdf = pw.Document();


  final image = pw.MemoryImage(
  File('test.webp').readAsBytesSync(),
);

pdf.addPage(pw.Page(build: (pw.Context context) {
  return pw.Center(
    child: pw.Image(image),
  ); // Center
}));

  return pdf;
}
