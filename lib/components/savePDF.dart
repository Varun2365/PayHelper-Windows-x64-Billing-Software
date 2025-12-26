// ignore_for_file: prefer_if_null_operators, non_constant_identifier_names, use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
// ignore: unused_import
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:billing/components/pdfGenerator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'addItemComponenets.dart';

class My extends StatefulWidget {
  const My({super.key});

  @override
  State<My> createState() => MyState();
}

Future<String?> saveFile(
  BuildContext context,
  String key,
) async {
  String? outputFile = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Please Select File Location',
  );

  if (outputFile != null) {
    savePDF(key, outputFile);
  }
  return null;
}

Future<String?> saveFile2(
  BuildContext context,
  String year,
  String month,
  String key,
) async {
  String? outputFile = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Please Select File Location',
  );

  if (outputFile != null) {
    await savePDF2(year, month, key, outputFile, context);
  }
  return null;
}

class MyState extends State<My> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          saveFile(context, "");
        },
        child: const Text("File"));
  }
}

Future<String> savePDF(String key, String path) async {
  log("Called savePDF");
  File invoices = File("Database/Invoices/Invoices.json");
  File settings = File("Database/PDF/saveSettings.json");
  Uint8List sign = Uint8List(0);
  try {
    File signFile = File("Database/signFile.jpg");
    sign = signFile.readAsBytesSync();
  } catch (e) {
    print(e);
  }
  dynamic invoicesContent = invoices.readAsStringSync();
  dynamic settingContent = settings.readAsStringSync();
  settingContent = jsonDecode(settingContent);
  dynamic tempPdfContent;
  invoicesContent = jsonDecode(invoicesContent);
  tempPdfContent = invoicesContent[key];
  String invoiceNo = tempPdfContent['InvoiceNo'];
  String date = tempPdfContent['Date'];
  String? place = tempPdfContent['Place'];
  String? gr = tempPdfContent['GR'];
  String? transport = tempPdfContent['Transport'];
  String? vehicle = tempPdfContent['Vehicle'];
  dynamic poValue = tempPdfContent['PO'];
  String po = "";
  if (poValue != null && poValue != "null" && poValue != "") {
    String poStr = poValue.toString().trim();
    if (poStr.isNotEmpty && poStr != "null") {
      po = poStr;
    }
  }
  log("savePDF - PO Number: '$po' (raw value: $poValue)");
  String? eway = tempPdfContent['Eway'];
  String billName = tempPdfContent['BillingName'];
  String billAddress = tempPdfContent['BillingAdd'];
  String billGST = tempPdfContent['BillingGST'];
  String totalAmount = tempPdfContent['TaxAmount'].toString();
  String cgst = tempPdfContent['cgst'];
  String sgst = tempPdfContent['sgst'];
  bool igst = tempPdfContent['igst'];
  String igstV = tempPdfContent['igstV'];
  String grandTotal = tempPdfContent['grandtotal'];
  String taxRate = tempPdfContent['TaxRate'];
  String taxAmount = tempPdfContent['TaxAmount'].toString();
  String totalTax = tempPdfContent['TotalTax'];
  String grandTotalInWords = tempPdfContent['grandTotalInWords'];
  List items = tempPdfContent['Products'];
  String? shipAddress = tempPdfContent['ShippingAdd'];
  String? shipName = "";
  String? firmInfo1;
  String? firmInfo2;
  String? firmInfo3;
  String? bank1;
  String? bank2;
  String? bank3;
  String? tnc1;
  String? tnc2;
  String? tnc3;
  String? tnc4;
  File firmDetails = File('Database/Firm/firmDetails.json');
  dynamic firm = firmDetails.readAsStringSync();
  firm = jsonDecode(firm);
  String firmGST = firm['GSTNo'];
  String firmName = firm['FirmName'];
  firmInfo3 = firm['Address3'];
  firmInfo2 = firm['Address2'];
  firmInfo1 = firm['Address1'];
  bank1 = firm['Bank1'];
  bank2 = firm['Bank2'];
  bank3 = firm['Bank3'];
  tnc1 = firm['TNC1'];
  tnc2 = firm['TNC2'];
  tnc3 = firm['TNC3'];
  tnc4 = firm['TNC4'];
  final pdf = pw.Document();
  const pw.TextStyle text9 = pw.TextStyle(fontSize: 9.5);
  const pw.TextStyle text10 = pw.TextStyle(fontSize: 10.5);
  await generateAndSaveQRCodeSimple(
      "upi://pay?pa=${firm['QRUPI']}&pn=${firm['QRName']}&am=${convertIndianFormattedStringToNumber(grandTotal)}");
  final cwd = Directory.current;
  final qrPath = '${cwd.path}/tempqr.png';
  File qrImg = File(qrPath);
  Uint8List qr = qrImg.readAsBytesSync();
  for (var v = 0; v < settingContent['copies']; v++) {
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.fromLTRB(10, 10, 10, 10),
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Expanded(
                  child: pw.Container(
                      child: pw.Column(children: [
                        //
                        //
                        //
                        //First Box
                        pw.Container(
                            height: 90,
                            width: double.infinity,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black)),
                            ),
                            child: pw.Stack(children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(7),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text("GST NO. : $firmGST",
                                            style: text9),
                                        pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.end,
                                            children: [
                                              pw.Text("Tax Invoice",
                                                  style: text9),
                                              pw.Text(
                                                  v > 0
                                                      ? "(Duplicate Copy)"
                                                      : "(Original Copy)",
                                                  style: pw.TextStyle(
                                                      fontSize: 9,
                                                      fontStyle:
                                                          pw.FontStyle.italic))
                                            ])
                                      ])),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(7),
                                  child: pw.Center(
                                      child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.start,
                                          children: [
                                        pw.Text(firmName.toUpperCase(),
                                            style: pw.TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                        pw.SizedBox(height: 8),
                                        pw.Text(
                                            firmInfo1 == null ? "" : firmInfo1,
                                            style: pw.TextStyle(
                                                fontSize: 9,
                                                fontWeight:
                                                    pw.FontWeight.normal)),
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                            firmInfo2 == null ? "" : firmInfo2,
                                            style: pw.TextStyle(
                                                fontSize: 9,
                                                fontWeight:
                                                    pw.FontWeight.normal)),
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                            firmInfo3 == null ? "" : firmInfo3,
                                            style: pw.TextStyle(
                                                fontSize: 9,
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                      ])))
                            ])),
                        //
                        //
                        //
                        //
                        //Second Box
                        pw.Container(
                            child: pw.Row(children: [
                              pw.Container(
                                  width: 287,
                                  height: double.infinity,
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.all(7),
                                    child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        children: [
                                          pw.Row(children: [
                                            pw.Container(
                                                width: 80,
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Text("Invoice No.",
                                                          style: text10),
                                                      pw.Text(":",
                                                          style: text10)
                                                    ])),
                                            pw.SizedBox(width: 10),
                                            pw.Text(invoiceNo, style: text10)
                                          ]),
                                          pw.Container(height: 5),
                                          pw.Row(children: [
                                            pw.Container(
                                                width: 80,
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Text("Dated",
                                                          style: text10),
                                                      pw.Text(":",
                                                          style: text10)
                                                    ])),
                                            pw.SizedBox(width: 10),
                                            pw.Text(date, style: text10)
                                          ]),
                                          pw.Container(height: 5),
                                          pw.Row(children: [
                                            pw.Container(
                                                width: 80,
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Text("Place of Supply",
                                                          style: text10),
                                                      pw.Text(":",
                                                          style: text10)
                                                    ])),
                                            pw.SizedBox(width: 10),
                                            pw.Text(place == null ? "" : place,
                                                style: text10)
                                          ]),
                                          pw.Container(height: 5),
                                          pw.Row(children: [
                                            pw.Container(
                                                width: 80,
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      pw.Text("GR/LR No.",
                                                          style: text10),
                                                      pw.Text(":",
                                                          style: text10)
                                                    ])),
                                            pw.SizedBox(width: 10),
                                            pw.Text(gr == null ? "" : gr,
                                                style: text10)
                                          ])
                                        ]),
                                  ),
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black)))),
                              pw.Container(
                                width: 288,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(7),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Transport",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(
                                              transport == null
                                                  ? ""
                                                  : transport,
                                              style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Vehicle No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(
                                              vehicle == null ? "" : vehicle,
                                              style: text10)
                                        ]),
                                        // pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    // pw.Text("Station No.",
                                                    //     style: text10),
                                                    // pw.Text(":", style: text10)
                                                  ])),
                                          // pw.SizedBox(width: 10),
                                          // pw.Text(station == null ? "" : station,
                                          //     style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("E-Way Bill No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(eway == null ? "" : eway,
                                              style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("PO No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(po,
                                              style: text10)
                                        ]),
                                      ]),
                                ),
                              ),
                            ]),
                            height: 82,
                            width: double.infinity,
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.black)))),
                        //
                        //
                        //
                        //
                        //
                        //Third box
                        pw.Container(
                            height: 111,
                            width: double.infinity,
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black))),
                            child: pw.Row(children: [
                              pw.Container(
                                  width: 287,
                                  height: double.infinity,
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(
                                                  "Billed To",
                                                  style: pw.TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    fontStyle: pw.FontStyle
                                                        .italic, // Add this line to make the text italic
                                                  ),
                                                ),
                                                pw.SizedBox(height: 4),
                                                pw.Text(billName,
                                                    style: pw.TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: pw
                                                            .FontWeight.bold)),
                                                pw.SizedBox(height: 2),
                                                pw.Text(billAddress,
                                                    style: const pw.TextStyle(
                                                        fontSize: 9,
                                                        lineSpacing: 1.9))
                                              ]),
                                          pw.Text("GST No.: $billGST",
                                              style: text9)
                                        ]),
                                  ),
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black)))),
                              pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                "Shipped To",
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  fontWeight:
                                                      pw.FontWeight.normal,
                                                  fontStyle: pw.FontStyle
                                                      .italic, // Add this line to make the text italic
                                                ),
                                              ),
                                              pw.SizedBox(height: 4),
                                              pw.Text(
                                                  shipName == ""
                                                      ? billName
                                                      : shipName,
                                                  style: pw.TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.SizedBox(height: 2),
                                              pw.Text(
                                                  shipAddress == null
                                                      ? billAddress
                                                      : shipAddress,
                                                  style: const pw.TextStyle(
                                                      fontSize: 9,
                                                      lineSpacing: 1.9))
                                            ]),
                                      ]),
                                ),
                              ),
                            ])),
                        //
                        //
                        //
                        //
                        //
                        //
                        //
                        //Products Section
                        pw.Container(
                            width: double.infinity,
                            height: 25,
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black))),
                            child: pw.Row(children: [
                              pw.Container(
                                  height: double.infinity,
                                  width: 27,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: pw.Container(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text("S.No.",
                                              style: const pw.TextStyle(
                                                  fontSize: 7))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 209,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text("Description of Goods",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 51,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.center,
                                          child: pw.Text("HSN/SAC",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 57,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.center,
                                          child: pw.Text("Qty.",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 57,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.center,
                                          child: pw.Text("Units",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 85,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.centerRight,
                                          child: pw.Text("Rate",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                              pw.Container(
                                  height: double.infinity,
                                  width: 89,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: pw.Container(
                                          alignment: pw.Alignment.centerRight,
                                          child: pw.Text("Amount",
                                              style: const pw.TextStyle(
                                                  fontSize: 8))))),
                            ])),
                        //
                        //
                        //

                        pw.Container(
                          width: double.infinity,
                          height: 245,
                          child: pw.Stack(children: [
                            pw.Container(
                                width: double.infinity,
                                height: 245,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Row(children: [
                                  pw.Container(
                                      height: double.infinity,
                                      width: 27,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 12),
                                          child: pw.Container(
                                              // alignment: pw.Alignment.centerLeft,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 7))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 209,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              // alignment: pw.Alignment.centerLeft,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 51,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              // alignment: pw.Alignment.center,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 57,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              alignment: pw.Alignment.topCenter,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 57,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              alignment: pw.Alignment.topCenter,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 85,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              alignment: pw.Alignment.topRight,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                  pw.Container(
                                      height: double.infinity,
                                      width: 89,
                                      decoration: const pw.BoxDecoration(
                                          border: pw.Border(
                                              right: pw.BorderSide(
                                                  color: PdfColors.black))),
                                      child: pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 12),
                                          child: pw.Container(
                                              alignment: pw.Alignment.topRight,
                                              child: pw.Text("",
                                                  style: const pw.TextStyle(
                                                      fontSize: 8))))),
                                ])),

                            //
                            ///
                            ///
                            //////
                            /////
                            //////
                            /////
                            ////
                            /////
                            ///
                            ///
                            pw.Container(
                                width: double.infinity,
                                height: 245,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.ListView.builder(
                                    direction: pw.Axis.vertical,
                                    itemBuilder: (context, index) {
                                      return pw.Column(children: [
                                        pw.Container(
                                          height: 5,
                                        ),
                                        pw.Container(
                                            width: double.infinity,
                                            child: pw.Row(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Container(
                                                      width: 27,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding: const pw
                                                              .EdgeInsets.symmetric(
                                                              horizontal: 3,
                                                              vertical: 3),
                                                          child: pw.Container(
                                                              // alignment: pw.Alignment.centerLeft,
                                                              child: pw.Text(
                                                                  "${index + 1}",
                                                                  style: const pw
                                                                      .TextStyle(
                                                                      fontSize:
                                                                          9))))),
                                                  pw.Container(
                                                      width: 209,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding: const pw
                                                              .EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 3),
                                                          child: pw.Column(
                                                              crossAxisAlignment:
                                                                  pw.CrossAxisAlignment
                                                                      .start,
                                                              // alignment: pw.Alignment.centerLeft,
                                                              children: [
                                                                pw.Text(
                                                                    items[index]
                                                                        [
                                                                        'name'],
                                                                    style: pw.TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight: pw
                                                                            .FontWeight
                                                                            .bold)),
                                                                pw.Text(
                                                                    items[index]
                                                                        [
                                                                        'desc'],
                                                                    style: const pw
                                                                        .TextStyle(
                                                                        fontSize:
                                                                            9)),
                                                              ]))),
                                                  pw.Container(
                                                      width: 51,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding: const pw
                                                              .EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 3),
                                                          child: pw.Container(
                                                              // alignment: pw.Alignment.center,
                                                              child: pw.Text(
                                                                  textAlign: pw
                                                                      .TextAlign
                                                                      .center,
                                                                  items[index]
                                                                      ['hsn'],
                                                                  style: const pw
                                                                      .TextStyle(
                                                                      fontSize:
                                                                          9))))),
                                                  pw.Container(
                                                      width: 57,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding:
                                                              const pw.EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 3),
                                                          child: pw.Container(
                                                              alignment: pw
                                                                  .Alignment
                                                                  .topCenter,
                                                              child: pw.Text(
                                                                  items[index]
                                                                      ['qty'],
                                                                  style: const pw.TextStyle(
                                                                      fontSize:
                                                                          9))))),
                                                  pw.Container(
                                                      width: 57,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding:
                                                              const pw.EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 3),
                                                          child: pw.Container(
                                                              alignment: pw
                                                                  .Alignment
                                                                  .topCenter,
                                                              child: pw.Text("",
                                                                  style: const pw
                                                                      .TextStyle(
                                                                      fontSize:
                                                                          9))))),
                                                  pw.Container(
                                                      width: 85,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding:
                                                              const pw.EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 3),
                                                          child: pw.Container(
                                                              alignment: pw
                                                                  .Alignment
                                                                  .topRight,
                                                              child: pw.Text(
                                                                  items[index]
                                                                      ['rate'],
                                                                  style: const pw.TextStyle(
                                                                      fontSize:
                                                                          9))))),
                                                  pw.Container(
                                                      width: 89,
                                                      decoration: const pw
                                                          .BoxDecoration(),
                                                      child: pw.Padding(
                                                          padding: const pw
                                                              .EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 3),
                                                          child: pw.Container(
                                                              alignment: pw
                                                                  .Alignment
                                                                  .topRight,
                                                              child: pw.Text(
                                                                  makeFullDouble(
                                                                      items[index]['amount']),
                                                                  style: const pw.TextStyle(fontSize: 9))))),
                                                ])),
                                        // pw.SizedBox(height: 2),
                                      ]);
                                    },
                                    itemCount: items.length)),
                          ]),
                        ),

                        //
                        //
                        //
                        //
                        //
                        //
                        //
                        //
                        //
                        pw.Container(
                            width: double.infinity,
                            height: 38,
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black))),
                            child: pw.Row(children: [
                              pw.Row(children: [
                                pw.Container(
                                    width: 486,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Column(
                                      children: [
                                        pw.Container(
                                          width: double.infinity,
                                          height: 13,
                                        ),
                                        pw.Container(
                                            height: 25,
                                            width: double.infinity,
                                            child: pw.Padding(
                                                padding: const pw
                                                    .EdgeInsets.symmetric(
                                                    vertical: 1,
                                                    horizontal: 20),
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment.end,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      pw.Text("Add:",
                                                          style: pw.TextStyle(
                                                              fontSize: 9,
                                                              fontStyle: pw
                                                                  .FontStyle
                                                                  .normal)),
                                                      pw.SizedBox(width: 10),
                                                      pw.Column(
                                                          mainAxisAlignment: pw
                                                              .MainAxisAlignment
                                                              .start,
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            pw.Text(
                                                                igst
                                                                    ? "IGST($taxRate)"
                                                                    : "CGST (9%)",
                                                                style: pw.TextStyle(
                                                                    fontSize: 7,
                                                                    fontStyle: pw
                                                                        .FontStyle
                                                                        .italic)),
                                                            pw.Text(
                                                                igst
                                                                    ? ""
                                                                    : "SGST (9%)",
                                                                style: pw.TextStyle(
                                                                    fontSize: 7,
                                                                    fontStyle: pw
                                                                        .FontStyle
                                                                        .italic))
                                                          ])
                                                    ])))
                                      ],
                                    )),
                                pw.Container(
                                    width: 89,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            left: pw.BorderSide(
                                                color: PdfColors.black),
                                            bottom: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 7),
                                        child: pw.Column(
                                          children: [
                                            pw.Container(
                                                width: double.infinity,
                                                height: 10,
                                                child: pw.Text(totalAmount,
                                                    textAlign:
                                                        pw.TextAlign.right,
                                                    style: pw.TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: pw
                                                            .FontWeight.bold))),
                                            pw.SizedBox(height: 1),
                                            pw.Container(
                                                height: 25,
                                                width: double.infinity,
                                                child: pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            1),
                                                    child: pw.Row(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .end,
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          // pw.Text("Add:",style: pw.TextStyle(fontSize: 9,fontStyle: pw.FontStyle.normal)),
                                                          pw.SizedBox(
                                                              width: 10),
                                                          pw.Column(
                                                              mainAxisAlignment:
                                                                  pw.MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  pw.CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                pw.Text(
                                                                    igst
                                                                        ? igstV
                                                                        : cgst,
                                                                    style: pw.TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        fontStyle: pw
                                                                            .FontStyle
                                                                            .italic)),
                                                                pw.Text(
                                                                    igst
                                                                        ? ""
                                                                        : sgst,
                                                                    style: pw.TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        fontStyle: pw
                                                                            .FontStyle
                                                                            .italic))
                                                              ])
                                                        ])))
                                          ],
                                        )))
                              ])
                            ])),

                        pw.Stack(children: [
                          pw.Container(
                              width: double.infinity,
                              height: 96,
                              child: pw.Column(children: [
                                pw.Container(
                                    width: double.infinity,
                                    height: 31,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.white))),
                                    child: pw.Row(children: [
                                      pw.Row(children: [
                                        pw.Container(width: 486),
                                        pw.Container(
                                          width: 89,
                                          height: double.infinity,
                                          child: pw.Padding(
                                              padding:
                                                  const pw.EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                              child: pw.Text(grandTotal,
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          pw.FontWeight.bold))),
                                          decoration: const pw.BoxDecoration(
                                              border: pw.Border(
                                                  left: pw.BorderSide(
                                                      color: PdfColors.black),
                                                  bottom: pw.BorderSide(
                                                      color: PdfColors.black))),
                                        )
                                      ])
                                    ])),
                                pw.Container(
                                    height: 65,
                                    width: double.infinity,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            bottom: pw.BorderSide(
                                                color: PdfColors.black)))),
                              ])),
                          pw.Container(
                              width: 486,
                              height: 96,
                              child: pw.Container(
                                  height: double.infinity,
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.only(
                                          top: 5,
                                          right: 7,
                                          bottom: 10,
                                          left: 7),
                                      child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Container(
                                                height: 32,
                                                width: double.infinity,
                                                child: pw.Row(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      pw.Row(children: [
                                                        pw.Column(children: [
                                                          pw.Text("Tax Rate",
                                                              style: pw.TextStyle(
                                                                  fontSize: 10,
                                                                  decoration: pw
                                                                      .TextDecoration
                                                                      .underline,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold)),
                                                          pw.SizedBox(
                                                              height: 2),
                                                          pw.Text(taxRate,
                                                              style: const pw
                                                                  .TextStyle(
                                                                  fontSize: 10))
                                                        ]),
                                                        pw.SizedBox(width: 10),
                                                        pw.Column(children: [
                                                          pw.Text(
                                                              "Taxable Amount",
                                                              style: pw.TextStyle(
                                                                  fontSize: 10,
                                                                  decoration: pw
                                                                      .TextDecoration
                                                                      .underline,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold)),
                                                          pw.SizedBox(
                                                              height: 2),
                                                          pw.Text(
                                                              "Rs. $taxAmount",
                                                              style: const pw
                                                                  .TextStyle(
                                                                  fontSize: 10))
                                                        ]),
                                                        pw.SizedBox(width: 10),
                                                        pw.Column(children: [
                                                          pw.Text("Total Tax",
                                                              style: pw.TextStyle(
                                                                  fontSize: 10,
                                                                  decoration: pw
                                                                      .TextDecoration
                                                                      .underline,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold)),
                                                          pw.SizedBox(
                                                              height: 2),
                                                          pw.Text(
                                                              "Rs. $totalTax",
                                                              style: const pw
                                                                  .TextStyle(
                                                                  fontSize: 10))
                                                        ]),
                                                        pw.SizedBox(width: 10),
                                                      ]),
                                                      pw.Row(children: [
                                                        pw.Text(
                                                            "Grand Total (Rs.)",
                                                            style: pw.TextStyle(
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold,
                                                                fontSize: 10)),
                                                        // pw.Text("₹",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                                      ])
                                                    ])),
                                            pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text(
                                                      "Grand Total In Words",
                                                      style: const pw.TextStyle(
                                                          fontSize: 9)),
                                                  pw.SizedBox(height: 2),
                                                  pw.Text(
                                                      "$grandTotalInWords Only",
                                                      style: pw.TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: pw
                                                              .FontWeight.bold))
                                                ])
                                          ])))),
                        ]),

                        pw.Container(
                            height: 43,
                            width: double.infinity,
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                    bottom:
                                        pw.BorderSide(color: PdfColors.black))),
                            child: pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 7),
                                child: pw.Row(children: [
                                  pw.Container(
                                      height: double.infinity,
                                      width: 83,
                                      child: pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text("Banking Details",
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 10)),
                                            pw.Text(":",
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 10))
                                          ])),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 7),
                                      child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.start,
                                          children: [
                                            pw.Text(bank1 == null ? "" : bank1,
                                                style: text9),
                                            pw.Text(bank2 == null ? "" : bank2,
                                                style: text9),
                                            pw.Text(bank3 == null ? "" : bank3,
                                                style: text9),
                                          ]))
                                ]))),
                        pw.Container(
                            height: 91,
                            width: double.infinity,
                            decoration: const pw.BoxDecoration(),
                            child: pw.Row(children: [
                              pw.Container(
                                  width: 287,
                                  height: double.infinity,
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(7),
                                      child: pw.Column(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("Terms And Conditions",
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 10)),
                                            pw.SizedBox(height: 5),
                                            pw.Text(
                                                tnc1 == null ? "" : "- $tnc1",
                                                style: text9),
                                            pw.Text(
                                                tnc2 == null ? "" : "- $tnc2",
                                                style: text9),
                                            pw.Text(
                                                tnc3 == null ? "" : "- $tnc3",
                                                style: text9),
                                            pw.Text(
                                                tnc4 == null ? "" : "- $tnc4",
                                                style: text9),
                                          ])),
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(
                                              color: PdfColors.black)))),
                              pw.Container(
                                  width: 288,
                                  height: double.infinity,
                                  child: pw.Column(children: [
                                    // pw.Container(
                                    //     width: double.infinity,
                                    //     height: 31,
                                    //     child: pw.Padding(
                                    //         padding: const pw.EdgeInsets.all(7),
                                    //         child: pw.Text(
                                    //             "Reciever's Signature : ",
                                    //             style: const pw.TextStyle(
                                    //                 fontSize: 10))),
                                    //     decoration: const pw.BoxDecoration(
                                    //         border: pw.Border(
                                    //             bottom: pw.BorderSide(
                                    //                 color: PdfColors.black)))),
                                    pw.Container(
                                        width: double.infinity,
                                        height: 91,
                                        child: pw.Stack(children: [
                                          pw.Padding(
                                              padding:
                                                  const pw.EdgeInsets.all(7),
                                              child: pw.Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: pw.Column(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      crossAxisAlignment: pw
                                                          .CrossAxisAlignment
                                                          .end,
                                                      children: [
                                                        pw.Text(
                                                            "For ${firmName.toUpperCase()}",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.Text(
                                                            "Authorised Signatory",
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 7))
                                                      ]))),
                                          settingContent['sign'] &&
                                                  sign.length != 0
                                              ? pw.Positioned(
                                                  right: 20,
                                                  top: 2.5,
                                                  child: pw.Opacity(
                                                      opacity: 0.9,
                                                      child: pw.Container(
                                                        height: 85,
                                                        width: 85,
                                                        decoration: pw.BoxDecoration(
                                                            image: pw.DecorationImage(
                                                                image: pw
                                                                    .MemoryImage(
                                                                        sign))),
                                                      )))
                                              : pw.SizedBox(),
                                          settingContent['qr']
                                              ? pw.Positioned(
                                                  top: 0,
                                                  left: 5,
                                                  child: pw.Container(
                                                      padding:
                                                          pw.EdgeInsets.only(
                                                              right: 5),
                                                      decoration: pw.BoxDecoration(
                                                          border: pw.Border(
                                                              right: pw.BorderSide(
                                                                  color:
                                                                      PdfColors
                                                                          .black,
                                                                  width: 1))),
                                                      height: 91,
                                                      width: 70,
                                                      child:
                                                          pw.Column(children: [
                                                        pw.SizedBox(height: 5),
                                                        pw.Image(
                                                            fit: pw
                                                                .BoxFit.contain,
                                                            pw.MemoryImage(qr)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text("Payment QR",
                                                            style: pw.TextStyle(
                                                                fontSize: 7,
                                                                color: PdfColors
                                                                    .black)),
                                                      ])))
                                              : pw.SizedBox(),
                                        ])),
                                  ])),
                            ])),
                      ]),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 1)))));
        },
      ),
    );
  }
  // Save the PDF to a file
  final Uint8List bytes = await pdf.save();
  final file = File('$path\\Bill No.$invoiceNo $billName.pdf');

  await file.writeAsBytes(bytes);
  return 'PDF Saved';
}

Future<String> savePDF2(String year, String month, String key, String path,
    BuildContext context, {bool showSuccessDialog = true}) async {
  File invoices = File("Database/Invoices/In.json");
  File settings = File("Database/PDF/saveSettings.json");
  dynamic invoicesContent = invoices.readAsStringSync();
  log("Called savePDF2");
  Uint8List sign = Uint8List(0);
  try {
    File signFile = File("Database/signFile.jpg");
    sign = signFile.readAsBytesSync();
  } catch (e) {
    print(e);
  }

  dynamic tempPdfContent;
  invoicesContent = jsonDecode(invoicesContent);
  tempPdfContent = invoicesContent[year][month][key];
  dynamic settingContent = settings.readAsStringSync();
  settingContent = jsonDecode(settingContent);
  String invoiceNo = tempPdfContent['InvoiceNo'];
  String date = tempPdfContent['Date'];
  String? place = tempPdfContent['Place'];
  // GR/LR number from database 'GR' field - must be used in GR/LR No. field in PDF
  String? gr = tempPdfContent['GR'];
  String? transport = tempPdfContent['Transport'];
  String? vehicle = tempPdfContent['Vehicle'];
  // PO number from database 'PO' field - must be used in PO No. field in PDF
  dynamic poValue = tempPdfContent['PO'];
  String po = "";
  if (poValue != null && poValue != "null" && poValue != "") {
    String poStr = poValue.toString().trim();
    if (poStr.isNotEmpty && poStr != "null") {
      po = poStr;
    }
  }
  log("savePDF2 - PO Number: '$po' (raw value: $poValue)");
  String? eway = tempPdfContent['Eway'];
  String billName = tempPdfContent['BillingName'];
  String billAddress = tempPdfContent['BillingAdd'];
  String billGST = tempPdfContent['BillingGST'];
  String totalAmount = tempPdfContent['TaxAmount'].toString();
  String cgst = tempPdfContent['cgst'];
  String sgst = tempPdfContent['sgst'];
  bool igst = tempPdfContent['igst'];
  String igstV = tempPdfContent['igstV'];
  String grandTotal = tempPdfContent['grandtotal'];
  String taxRate = tempPdfContent['TaxRate'];
  String taxAmount = tempPdfContent['TaxAmount'].toString();
  String totalTax = tempPdfContent['TotalTax'];
  String grandTotalInWords = tempPdfContent['grandTotalInWords'];
  List items = tempPdfContent['Products'];
  String? shipAddress = tempPdfContent['ShippingAdd'];
  String? shipName = "";
  String? firmInfo1;
  String? firmInfo2;
  String? firmInfo3;
  String? bank1;
  String? bank2;
  String? bank3;
  String? tnc1;
  String? tnc2;
  String? tnc3;
  String? tnc4;
  File firmDetails = File('Database/Firm/firmDetails.json');
  dynamic firm = firmDetails.readAsStringSync();
  firm = jsonDecode(firm);
  String firmGST = firm['GSTNo'];
  String firmName = firm['FirmName'];
  firmInfo3 = firm['Address3'];
  firmInfo2 = firm['Address2'];
  firmInfo1 = firm['Address1'];
  bank1 = firm['Bank1'];
  bank2 = firm['Bank2'];
  bank3 = firm['Bank3'];
  tnc1 = firm['TNC1'];
  tnc2 = firm['TNC2'];
  tnc3 = firm['TNC3'];
  tnc4 = firm['TNC4'];
  final pdf = pw.Document();
  const pw.TextStyle text9 = pw.TextStyle(fontSize: 9.5);
  const pw.TextStyle text10 = pw.TextStyle(fontSize: 10.5);
  await generateAndSaveQRCodeSimple(
      "upi://pay?pa=${firm['QRUPI']}&pn=${firm['QRName']}&am=${convertIndianFormattedStringToNumber(grandTotal)}");
  final cwd = Directory.current;
  final qrPath = '${cwd.path}/tempqr.png';
  File qrImg = File(qrPath);
  Uint8List qr = qrImg.readAsBytesSync();
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.fromLTRB(10, 10, 10, 10),
      build: (pw.Context context) {
        return pw.Center(
            child: pw.Expanded(
                child: pw.Container(
                    child: pw.Column(children: [
                      //
                      //
                      //
                      //First Box
                      pw.Container(
                          height: 90,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.black)),
                          ),
                          child: pw.Stack(children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("GST NO. : $firmGST",
                                          style: text9),
                                      pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.end,
                                          children: [
                                            pw.Text("Tax Invoice",
                                                style: text9),
                                            pw.Text("(Original Copy)",
                                                style: pw.TextStyle(
                                                    fontSize: 9,
                                                    fontStyle:
                                                        pw.FontStyle.italic))
                                          ])
                                    ])),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Center(
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        children: [
                                      pw.Text(firmName.toUpperCase(),
                                          style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 8),
                                      pw.Text(
                                          firmInfo1 == null ? "" : firmInfo1,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                                  pw.FontWeight.normal)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          firmInfo2 == null ? "" : firmInfo2,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                                  pw.FontWeight.normal)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          firmInfo3 == null ? "" : firmInfo3,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight: pw.FontWeight.bold)),
                                    ])))
                          ])),
                      //
                      //
                      //
                      //
                      //Second Box
                      pw.Container(
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(7),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      children: [
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Invoice No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(invoiceNo, style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Dated",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(date, style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Place of Supply",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(place == null ? "" : place,
                                              style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("GR/LR No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(gr == null ? "" : gr,
                                              style: text10)
                                        ])
                                      ]),
                                ),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                              width: 288,
                              height: double.infinity,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    children: [
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("Transport",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                            transport == null ? "" : transport,
                                            style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("Vehicle No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(vehicle == null ? "" : vehicle,
                                            style: text10)
                                      ]),
                                      // pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  // pw.Text("Station No.",
                                                  //     style: text10),
                                                  // pw.Text(":", style: text10)
                                                ])),
                                        // pw.SizedBox(width: 10),
                                        // pw.Text(station == null ? "" : station,
                                        //     style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("E-Way Bill No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(eway == null ? "" : eway,
                                            style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("PO No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(po,
                                            style: text10)
                                      ]),
                                    ]),
                              ),
                            ),
                          ]),
                          height: 82,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black)))),
                      //
                      //
                      //
                      //
                      //
                      //Third box
                      pw.Container(
                          height: 111,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                "Billed To",
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  fontWeight:
                                                      pw.FontWeight.normal,
                                                  fontStyle: pw.FontStyle
                                                      .italic, // Add this line to make the text italic
                                                ),
                                              ),
                                              pw.SizedBox(height: 4),
                                              pw.Text(billName,
                                                  style: pw.TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.SizedBox(height: 2),
                                              pw.Text(billAddress,
                                                  style: const pw.TextStyle(
                                                      fontSize: 9,
                                                      lineSpacing: 1.9))
                                            ]),
                                        pw.Text("GST No.: $billGST",
                                            style: text9)
                                      ]),
                                ),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                              width: 287,
                              height: double.infinity,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              "Shipped To",
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                fontWeight:
                                                    pw.FontWeight.normal,
                                                fontStyle: pw.FontStyle
                                                    .italic, // Add this line to make the text italic
                                              ),
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Text(
                                                shipName == ""
                                                    ? billName
                                                    : shipName,
                                                style: pw.TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        pw.FontWeight.bold)),
                                            pw.SizedBox(height: 2),
                                            pw.Text(
                                                shipAddress == null
                                                    ? billAddress
                                                    : shipAddress,
                                                style: const pw.TextStyle(
                                                    fontSize: 9,
                                                    lineSpacing: 1.9))
                                          ]),
                                    ]),
                              ),
                            ),
                          ])),
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //Products Section
                      pw.Container(
                          width: double.infinity,
                          height: 25,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Container(
                                height: double.infinity,
                                width: 27,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text("S.No.",
                                            style: const pw.TextStyle(
                                                fontSize: 7))))),
                            pw.Container(
                                height: double.infinity,
                                width: 209,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text("Description of Goods",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 51,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("HSN/SAC",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 57,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("Qty.",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 57,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("Units",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 85,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Rate",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 89,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Amount",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                          ])),
                      //
                      //
                      //

                      pw.Container(
                        width: double.infinity,
                        height: 245,
                        child: pw.Stack(children: [
                          pw.Container(
                              width: double.infinity,
                              height: 245,
                              decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.black))),
                              child: pw.Row(children: [
                                pw.Container(
                                    height: double.infinity,
                                    width: 27,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.centerLeft,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 7))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 209,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.centerLeft,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 51,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.center,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 57,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topCenter,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 57,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topCenter,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 85,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topRight,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 89,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topRight,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                              ])),

                          //
                          ///
                          ///
                          //////
                          /////
                          //////
                          /////
                          ////
                          /////
                          ///
                          ///
                          pw.Container(
                              width: double.infinity,
                              height: 245,
                              decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.black))),
                              child: pw.ListView.builder(
                                  direction: pw.Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return pw.Column(children: [
                                      pw.Container(
                                        height: 5,
                                      ),
                                      pw.Container(
                                          width: double.infinity,
                                          child: pw.Row(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Container(
                                                    width: 27,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            // alignment: pw.Alignment.centerLeft,
                                                            child: pw.Text(
                                                                "${index + 1}",
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 209,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Column(
                                                            crossAxisAlignment: pw
                                                                .CrossAxisAlignment
                                                                .start,
                                                            // alignment: pw.Alignment.centerLeft,
                                                            children: [
                                                              pw.Text(
                                                                  items[index]
                                                                      ['name'],
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                              pw.Text(
                                                                  items[index]
                                                                      ['desc'],
                                                                  style: const pw
                                                                      .TextStyle(
                                                                      fontSize:
                                                                          9)),
                                                            ]))),
                                                pw.Container(
                                                    width: 51,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            // alignment: pw.Alignment.center,
                                                            child: pw.Text(
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                items[index]
                                                                    ['hsn'],
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 57,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topCenter,
                                                            child: pw.Text(
                                                                items[index]
                                                                    ['qty'],
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                                pw.Container(
                                                    width: 57,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding:
                                                            const pw.EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topCenter,
                                                            child: pw.Text("",
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 85,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topRight,
                                                            child: pw.Text(
                                                                items[index]
                                                                    ['rate'],
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                                pw.Container(
                                                    width: 89,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding:
                                                            const pw.EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topRight,
                                                            child: pw.Text(
                                                                makeFullDouble(items[index]
                                                                    ['amount']),
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                              ])),
                                      // pw.SizedBox(height: 2),
                                    ]);
                                  },
                                  itemCount: items.length)),
                        ]),
                      ),

                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      pw.Container(
                          width: double.infinity,
                          height: 38,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Row(children: [
                              pw.Container(
                                  width: 486,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Column(
                                    children: [
                                      pw.Container(
                                        width: double.infinity,
                                        height: 13,
                                      ),
                                      pw.Container(
                                          height: 25,
                                          width: double.infinity,
                                          child: pw.Padding(
                                              padding:
                                                  const pw.EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 20),
                                              child: pw.Row(
                                                  mainAxisAlignment:
                                                      pw.MainAxisAlignment.end,
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text("Add:",
                                                        style: pw.TextStyle(
                                                            fontSize: 9,
                                                            fontStyle: pw
                                                                .FontStyle
                                                                .normal)),
                                                    pw.SizedBox(width: 10),
                                                    pw.Column(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                              igst
                                                                  ? "IGST($taxRate)"
                                                                  : "CGST (9%)",
                                                              style: pw.TextStyle(
                                                                  fontSize: 7,
                                                                  fontStyle: pw
                                                                      .FontStyle
                                                                      .italic)),
                                                          pw.Text(
                                                              igst
                                                                  ? ""
                                                                  : "SGST (9%)",
                                                              style: pw.TextStyle(
                                                                  fontSize: 7,
                                                                  fontStyle: pw
                                                                      .FontStyle
                                                                      .italic))
                                                        ])
                                                  ])))
                                    ],
                                  )),
                              pw.Container(
                                  width: 89,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          left: pw.BorderSide(
                                              color: PdfColors.black),
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          vertical: 1, horizontal: 7),
                                      child: pw.Column(
                                        children: [
                                          pw.Container(
                                              width: double.infinity,
                                              height: 10,
                                              child: pw.Text(totalAmount,
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          pw.FontWeight.bold))),
                                          pw.SizedBox(height: 1),
                                          pw.Container(
                                              height: 25,
                                              width: double.infinity,
                                              child: pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          1),
                                                  child: pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      crossAxisAlignment: pw
                                                          .CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        // pw.Text("Add:",style: pw.TextStyle(fontSize: 9,fontStyle: pw.FontStyle.normal)),
                                                        pw.SizedBox(width: 10),
                                                        pw.Column(
                                                            mainAxisAlignment: pw
                                                                .MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment: pw
                                                                .CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              pw.Text(
                                                                  igst
                                                                      ? igstV
                                                                      : cgst,
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontStyle: pw
                                                                          .FontStyle
                                                                          .italic)),
                                                              pw.Text(
                                                                  igst
                                                                      ? ""
                                                                      : sgst,
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontStyle: pw
                                                                          .FontStyle
                                                                          .italic))
                                                            ])
                                                      ])))
                                        ],
                                      )))
                            ])
                          ])),

                      pw.Stack(children: [
                        pw.Container(
                            width: double.infinity,
                            height: 96,
                            child: pw.Column(children: [
                              pw.Container(
                                  width: double.infinity,
                                  height: 31,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.white))),
                                  child: pw.Row(children: [
                                    pw.Row(children: [
                                      pw.Container(width: 486),
                                      pw.Container(
                                        width: 89,
                                        height: double.infinity,
                                        child: pw.Padding(
                                            padding:
                                                const pw.EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                            child: pw.Text(grandTotal,
                                                textAlign: pw.TextAlign.right,
                                                style: pw.TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        pw.FontWeight.bold))),
                                        decoration: const pw.BoxDecoration(
                                            border: pw.Border(
                                                left: pw.BorderSide(
                                                    color: PdfColors.black),
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.black))),
                                      )
                                    ])
                                  ])),
                              pw.Container(
                                  height: 65,
                                  width: double.infinity,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black)))),
                            ])),
                        pw.Container(
                            width: 486,
                            height: 96,
                            child: pw.Container(
                                height: double.infinity,
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        top: 5, right: 7, bottom: 10, left: 7),
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Container(
                                              height: 32,
                                              width: double.infinity,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Row(children: [
                                                      pw.Column(children: [
                                                        pw.Text("Tax Rate",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text(taxRate,
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                      pw.Column(children: [
                                                        pw.Text(
                                                            "Taxable Amount",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text(
                                                            "Rs. $taxAmount",
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                      pw.Column(children: [
                                                        pw.Text("Total Tax",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text("Rs. $totalTax",
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                    ]),
                                                    pw.Row(children: [
                                                      pw.Text(
                                                          "Grand Total (Rs.)",
                                                          style: pw.TextStyle(
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              fontSize: 10)),
                                                      // pw.Text("₹",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                                    ])
                                                  ])),
                                          pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text("Grand Total In Words",
                                                    style: const pw.TextStyle(
                                                        fontSize: 9)),
                                                pw.SizedBox(height: 2),
                                                pw.Text(
                                                    "$grandTotalInWords Only",
                                                    style: pw.TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            pw.FontWeight.bold))
                                              ])
                                        ])))),
                      ]),

                      pw.Container(
                          height: 43,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 7),
                              child: pw.Row(children: [
                                pw.Container(
                                    height: double.infinity,
                                    width: 83,
                                    child: pw.Row(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text("Banking Details",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10)),
                                          pw.Text(":",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10))
                                        ])),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 7),
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        children: [
                                          pw.Text(bank1 == null ? "" : bank1,
                                              style: text9),
                                          pw.Text(bank2 == null ? "" : bank2,
                                              style: text9),
                                          pw.Text(bank3 == null ? "" : bank3,
                                              style: text9),
                                        ]))
                              ]))),
                      pw.Container(
                          height: 91,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(),
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.all(7),
                                    child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text("Terms And Conditions",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10)),
                                          pw.SizedBox(height: 5),
                                          pw.Text(tnc1 == null ? "" : "- $tnc1",
                                              style: text9),
                                          pw.Text(tnc2 == null ? "" : "- $tnc2",
                                              style: text9),
                                          pw.Text(tnc3 == null ? "" : "- $tnc3",
                                              style: text9),
                                          pw.Text(tnc4 == null ? "" : "- $tnc4",
                                              style: text9),
                                        ])),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                                width: 288,
                                height: double.infinity,
                                child: pw.Column(children: [
                                  // pw.Container(
                                  //     width: double.infinity,
                                  //     height: 31,
                                  //     child: pw.Padding(
                                  //         padding: const pw.EdgeInsets.all(7),
                                  //         child: pw.Text(
                                  //             "Reciever's Signature : ",
                                  //             style: const pw.TextStyle(
                                  //                 fontSize: 10))),
                                  //     decoration: const pw.BoxDecoration(
                                  //         border: pw.Border(
                                  //             bottom: pw.BorderSide(
                                  //                 color: PdfColors.black)))),
                                  pw.Container(
                                      width: double.infinity,
                                      height: 91,
                                      child: pw.Stack(children: [
                                        pw.Padding(
                                            padding: const pw.EdgeInsets.all(7),
                                            child: pw.Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: pw.Column(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment.end,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment.end,
                                                    children: [
                                                      pw.Text(
                                                          "For ${firmName.toUpperCase()}",
                                                          style: pw.TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold)),
                                                      pw.Text(
                                                          "Authorised Signatory",
                                                          style: const pw
                                                              .TextStyle(
                                                              fontSize: 7))
                                                    ]))),
                                        settingContent['sign'] &&
                                                sign.length != 0
                                            ? pw.Positioned(
                                                right: 20,
                                                top: 2.5,
                                                child: pw.Opacity(
                                                    opacity: 0.9,
                                                    child: pw.Container(
                                                      height: 85,
                                                      width: 85,
                                                      decoration: pw.BoxDecoration(
                                                          image: pw.DecorationImage(
                                                              fit: pw.BoxFit
                                                                  .contain,
                                                              image: pw
                                                                  .MemoryImage(
                                                                      sign))),
                                                    )))
                                            : pw.SizedBox(),
                                        settingContent['qr']
                                            ? pw.Positioned(
                                                top: 0,
                                                left: 5,
                                                child: pw.Container(
                                                    padding: pw.EdgeInsets.only(
                                                        right: 5),
                                                    decoration: pw.BoxDecoration(
                                                        border: pw.Border(
                                                            right: pw.BorderSide(
                                                                color: PdfColors
                                                                    .black,
                                                                width: 1))),
                                                    height: 91,
                                                    width: 70,
                                                    child: pw.Column(children: [
                                                      pw.SizedBox(height: 5),
                                                      pw.Image(
                                                          fit:
                                                              pw.BoxFit.contain,
                                                          pw.MemoryImage(qr)),
                                                      pw.SizedBox(height: 2),
                                                      pw.Text("Payment QR",
                                                          style: pw.TextStyle(
                                                              fontSize: 7,
                                                              color: PdfColors
                                                                  .black)),
                                                    ])))
                                            : pw.SizedBox(),
                                      ])),
                                ])),
                          ])),
                    ]),
                    decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PdfColors.black, width: 1)))));
      },
    ),
  );

  // Save the PDF to a file
  final Uint8List bytes = await pdf.save();
  final file = File('$path\\Bill No.$invoiceNo $billName.pdf');

  await file.writeAsBytes(bytes);
  if (showSuccessDialog) {
    showDialog(
        context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
              height: 190,
              width: 450,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Message",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 24),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              "Invoice PDF Was Saved Successfully!",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 89, 89, 89),
                                  fontFamily: 'Poppins'),
                            )),
                        const SizedBox(
                          height: 3,
                        ),
                        SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              "$path\\Bill No.$invoiceNo $billName.pdf",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 89, 89, 89),
                                  fontFamily: 'Poppins'),
                            )),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 30,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xff3049AA))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              child: Text(
                                "OK",
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              )),
        );
      });
  }
  return 'PDF Saved';
}

Future<String> PreviewSave(String year, String month, String key) async {
  File tempPdf = File("Database/Invoices/tempPdf.json");
  File settings = File("Database/PDF/saveSettings.json");
  Uint8List sign = Uint8List(0);
  try {
    File signFile = File("Database/signFile.jpg");
    sign = signFile.readAsBytesSync();
  } catch (e) {
    print(e);
  }
  dynamic settingContent = settings.readAsStringSync();
  settingContent = jsonDecode(settingContent);
  File invoices = File("Database/Invoices/In.json");
  dynamic invoicesContent = invoices.readAsStringSync();

  dynamic tempPdfContent;
  invoicesContent = jsonDecode(invoicesContent);
  tempPdfContent = invoicesContent[year][month][key];
  String path = "Database/Invoices/tempInvoice.pdf";
  String invoiceNo = tempPdfContent['InvoiceNo'];
  String date = tempPdfContent['Date'];
  String? place = tempPdfContent['Place'];
  String? gr = tempPdfContent['GR'];
  String? transport = tempPdfContent['Transport'];
  String? vehicle = tempPdfContent['Vehicle'];
  // ignore: unused_local_variable
  String? station = tempPdfContent['Station'];
  String? eway = tempPdfContent['Eway'];
  String billName = tempPdfContent['BillingName'];
  String billAddress = tempPdfContent['BillingAdd'];
  String billGST = tempPdfContent['BillingGST'];
  String totalAmount = tempPdfContent['TaxAmount'];
  String cgst = tempPdfContent['cgst'];
  String sgst = tempPdfContent['sgst'];
  bool igst = tempPdfContent['igst'];
  String igstV = tempPdfContent['igstV'];
  dynamic poValue = tempPdfContent['PO'];
  String po = "";
  if (poValue != null && poValue != "null" && poValue != "") {
    String poStr = poValue.toString().trim();
    if (poStr.isNotEmpty && poStr != "null") {
      po = poStr;
    }
  }
  log("PreviewSave - PO Number: '$po' (raw value: $poValue)");
  String grandTotal = tempPdfContent['grandtotal'];
  String taxRate = tempPdfContent['TaxRate'];
  String taxAmount = tempPdfContent['TaxAmount'];
  String totalTax = tempPdfContent['TotalTax'];
  String grandTotalInWords = tempPdfContent['grandTotalInWords'];
  List items = tempPdfContent['Products'];
  String? shipAddress = tempPdfContent['ShippingAdd'];
  String? shipName = "";
  String? firmInfo1;
  String? firmInfo2;
  String? firmInfo3;
  String? bank1;
  String? bank2;
  String? bank3;
  String? tnc1;
  String? tnc2;
  String? tnc3;
  String? tnc4;
  File firmDetails = File('Database/Firm/firmDetails.json');
  dynamic firm = firmDetails.readAsStringSync();
  firm = jsonDecode(firm);
  await generateAndSaveQRCodeSimple(
      "upi://pay?pa=${firm['QRUPI']}&pn=${firm['QRName']}&am=${convertIndianFormattedStringToNumber(grandTotal)}");
  final cwd = Directory.current;
  final qrPath = '${cwd.path}/tempqr.png';
  File qrImg = File(qrPath);
  Uint8List qr = qrImg.readAsBytesSync();
  final imageWidget = await createImageWidgetFromStringPath(qrPath);
  String firmGST = firm['GSTNo'];
  String firmName = firm['FirmName'];
  firmInfo3 = firm['Address3'];
  firmInfo2 = firm['Address2'];
  firmInfo1 = firm['Address1'];
  bank1 = firm['Bank1'];
  bank2 = firm['Bank2'];
  bank3 = firm['Bank3'];
  tnc1 = firm['TNC1'];
  tnc2 = firm['TNC2'];
  tnc3 = firm['TNC3'];
  tnc4 = firm['TNC4'];
  final pdf = pw.Document();
  const pw.TextStyle text9 = pw.TextStyle(fontSize: 9.5);
  const pw.TextStyle text10 = pw.TextStyle(fontSize: 10.5);
  log("called PreviewSave");
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.fromLTRB(10, 10, 10, 10),
      build: (pw.Context context) {
        return pw.Center(
            child: pw.Expanded(
                child: pw.Container(
                    child: pw.Column(children: [
                      //
                      //
                      //
                      //First Box
                      pw.Container(
                          height: 90,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.black)),
                          ),
                          child: pw.Stack(children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("GST NO. : $firmGST",
                                          style: text9),
                                      pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.end,
                                          children: [
                                            pw.Text("Tax Invoice",
                                                style: text9),
                                            pw.Text("(Original Copy)",
                                                style: pw.TextStyle(
                                                    fontSize: 9,
                                                    fontStyle:
                                                        pw.FontStyle.italic))
                                          ])
                                    ])),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Center(
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        children: [
                                      pw.Text(firmName.toUpperCase(),
                                          style: pw.TextStyle(
                                              fontSize: 16,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 8),
                                      pw.Text(
                                          firmInfo1 == null ? "" : firmInfo1,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                                  pw.FontWeight.normal)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          firmInfo2 == null ? "" : firmInfo2,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                                  pw.FontWeight.normal)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          firmInfo3 == null ? "" : firmInfo3,
                                          style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight: pw.FontWeight.bold)),
                                    ])))
                          ])),
                      //
                      //
                      //
                      //
                      //Second Box
                      pw.Container(
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(7),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      children: [
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Invoice No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(invoiceNo, style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Dated",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(date, style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("Place of Supply",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(place == null ? "" : place,
                                              style: text10)
                                        ]),
                                        pw.Container(height: 5),
                                        pw.Row(children: [
                                          pw.Container(
                                              width: 80,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    pw.Text("GR/LR No.",
                                                        style: text10),
                                                    pw.Text(":", style: text10)
                                                  ])),
                                          pw.SizedBox(width: 10),
                                          pw.Text(gr == null ? "" : gr,
                                              style: text10)
                                        ])
                                      ]),
                                ),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                              width: 288,
                              height: double.infinity,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(7),
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    children: [
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("Transport",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                            transport == null ? "" : transport,
                                            style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("Vehicle No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(vehicle == null ? "" : vehicle,
                                            style: text10)
                                      ]),
                                      // pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  // pw.Text("Station No.",
                                                  //     style: text10),
                                                  // pw.Text(":", style: text10)
                                                ])),
                                        // pw.SizedBox(width: 10),
                                        // pw.Text(station == null ? "" : station,
                                        //     style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("E-Way Bill No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(eway == null ? "" : eway,
                                            style: text10)
                                      ]),
                                      pw.Container(height: 5),
                                      pw.Row(children: [
                                        pw.Container(
                                            width: 80,
                                            child: pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Text("PO No.",
                                                      style: text10),
                                                  pw.Text(":", style: text10)
                                                ])),
                                        pw.SizedBox(width: 10),
                                        pw.Text(po,
                                            style: text10)
                                      ]),
                                    ]),
                              ),
                            ),
                          ]),
                          height: 82,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black)))),
                      //
                      //
                      //
                      //
                      //
                      //Third box
                      pw.Container(
                          height: 111,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                "Billed To",
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  fontWeight:
                                                      pw.FontWeight.normal,
                                                  fontStyle: pw.FontStyle
                                                      .italic, // Add this line to make the text italic
                                                ),
                                              ),
                                              pw.SizedBox(height: 4),
                                              pw.Text(billName,
                                                  style: pw.TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          pw.FontWeight.bold)),
                                              pw.SizedBox(height: 2),
                                              pw.Text(billAddress,
                                                  style: const pw.TextStyle(
                                                      fontSize: 9,
                                                      lineSpacing: 1.9))
                                            ]),
                                        pw.Text("GST No.: $billGST",
                                            style: text9)
                                      ]),
                                ),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                              width: 287,
                              height: double.infinity,
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              "Shipped To",
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                fontWeight:
                                                    pw.FontWeight.normal,
                                                fontStyle: pw.FontStyle
                                                    .italic, // Add this line to make the text italic
                                              ),
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Text(
                                                shipName == ""
                                                    ? billName
                                                    : shipName,
                                                style: pw.TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        pw.FontWeight.bold)),
                                            pw.SizedBox(height: 2),
                                            pw.Text(
                                                shipAddress == null
                                                    ? billAddress
                                                    : shipAddress,
                                                style: const pw.TextStyle(
                                                    fontSize: 9,
                                                    lineSpacing: 1.9))
                                          ]),
                                    ]),
                              ),
                            ),
                          ])),
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //Products Section
                      pw.Container(
                          width: double.infinity,
                          height: 25,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Container(
                                height: double.infinity,
                                width: 27,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text("S.No.",
                                            style: const pw.TextStyle(
                                                fontSize: 7))))),
                            pw.Container(
                                height: double.infinity,
                                width: 209,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text("Description of Goods",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 51,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("HSN/SAC",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 57,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("Qty.",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 57,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.center,
                                        child: pw.Text("Units",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 85,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Rate",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                            pw.Container(
                                height: double.infinity,
                                width: 89,
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black))),
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: pw.Container(
                                        alignment: pw.Alignment.centerRight,
                                        child: pw.Text("Amount",
                                            style: const pw.TextStyle(
                                                fontSize: 8))))),
                          ])),
                      //
                      //
                      //

                      pw.Container(
                        width: double.infinity,
                        height: 245,
                        child: pw.Stack(children: [
                          pw.Container(
                              width: double.infinity,
                              height: 245,
                              decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.black))),
                              child: pw.Row(children: [
                                pw.Container(
                                    height: double.infinity,
                                    width: 27,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.centerLeft,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 7))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 209,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.centerLeft,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 51,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            // alignment: pw.Alignment.center,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 57,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topCenter,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 57,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topCenter,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 85,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topRight,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                                pw.Container(
                                    height: double.infinity,
                                    width: 89,
                                    decoration: const pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(
                                                color: PdfColors.black))),
                                    child: pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 12),
                                        child: pw.Container(
                                            alignment: pw.Alignment.topRight,
                                            child: pw.Text("",
                                                style: const pw.TextStyle(
                                                    fontSize: 8))))),
                              ])),

                          //
                          ///
                          ///
                          //////
                          /////
                          //////
                          /////
                          ////
                          /////
                          ///
                          ///
                          pw.Container(
                              width: double.infinity,
                              height: 245,
                              decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(
                                          color: PdfColors.black))),
                              child: pw.ListView.builder(
                                  direction: pw.Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return pw.Column(children: [
                                      pw.Container(
                                        height: 5,
                                      ),
                                      pw.Container(
                                          width: double.infinity,
                                          child: pw.Row(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Container(
                                                    width: 27,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            // alignment: pw.Alignment.centerLeft,
                                                            child: pw.Text(
                                                                "${index + 1}",
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 209,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Column(
                                                            crossAxisAlignment: pw
                                                                .CrossAxisAlignment
                                                                .start,
                                                            // alignment: pw.Alignment.centerLeft,
                                                            children: [
                                                              pw.Text(
                                                                  items[index]
                                                                      ['name'],
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                              pw.Text(
                                                                  items[index]
                                                                      ['desc'],
                                                                  style: const pw
                                                                      .TextStyle(
                                                                      fontSize:
                                                                          9)),
                                                            ]))),
                                                pw.Container(
                                                    width: 51,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            // alignment: pw.Alignment.center,
                                                            child: pw.Text(
                                                                textAlign: pw
                                                                    .TextAlign
                                                                    .center,
                                                                items[index]
                                                                    ['hsn'],
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 57,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topCenter,
                                                            child: pw.Text(
                                                                items[index]
                                                                    ['qty'],
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                                pw.Container(
                                                    width: 57,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding:
                                                            const pw.EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topCenter,
                                                            child: pw.Text("",
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9))))),
                                                pw.Container(
                                                    width: 85,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding: const pw
                                                            .EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topRight,
                                                            child: pw.Text(
                                                                items[index]
                                                                    ['rate'],
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                                pw.Container(
                                                    width: 89,
                                                    decoration: const pw
                                                        .BoxDecoration(),
                                                    child: pw.Padding(
                                                        padding:
                                                            const pw.EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 3),
                                                        child: pw.Container(
                                                            alignment: pw
                                                                .Alignment
                                                                .topRight,
                                                            child: pw.Text(
                                                                makeFullDouble(items[index]
                                                                    ['amount']),
                                                                style: const pw.TextStyle(
                                                                    fontSize: 9))))),
                                              ])),
                                      // pw.SizedBox(height: 2),
                                    ]);
                                  },
                                  itemCount: items.length)),
                        ]),
                      ),

                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      //
                      pw.Container(
                          width: double.infinity,
                          height: 38,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Row(children: [
                            pw.Row(children: [
                              pw.Container(
                                  width: 486,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Column(
                                    children: [
                                      pw.Container(
                                        width: double.infinity,
                                        height: 13,
                                      ),
                                      pw.Container(
                                          height: 25,
                                          width: double.infinity,
                                          child: pw.Padding(
                                              padding:
                                                  const pw.EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 20),
                                              child: pw.Row(
                                                  mainAxisAlignment:
                                                      pw.MainAxisAlignment.end,
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Text("Add:",
                                                        style: pw.TextStyle(
                                                            fontSize: 9,
                                                            fontStyle: pw
                                                                .FontStyle
                                                                .normal)),
                                                    pw.SizedBox(width: 10),
                                                    pw.Column(
                                                        mainAxisAlignment: pw
                                                            .MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: pw
                                                            .CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          pw.Text(
                                                              igst
                                                                  ? "IGST($taxRate)"
                                                                  : "CGST (9%)",
                                                              style: pw.TextStyle(
                                                                  fontSize: 7,
                                                                  fontStyle: pw
                                                                      .FontStyle
                                                                      .italic)),
                                                          pw.Text(
                                                              igst
                                                                  ? ""
                                                                  : "SGST (9%)",
                                                              style: pw.TextStyle(
                                                                  fontSize: 7,
                                                                  fontStyle: pw
                                                                      .FontStyle
                                                                      .italic))
                                                        ])
                                                  ])))
                                    ],
                                  )),
                              pw.Container(
                                  width: 89,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          left: pw.BorderSide(
                                              color: PdfColors.black),
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black))),
                                  child: pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          vertical: 1, horizontal: 7),
                                      child: pw.Column(
                                        children: [
                                          pw.Container(
                                              width: double.infinity,
                                              height: 10,
                                              child: pw.Text(totalAmount,
                                                  textAlign: pw.TextAlign.right,
                                                  style: pw.TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          pw.FontWeight.bold))),
                                          pw.SizedBox(height: 1),
                                          pw.Container(
                                              height: 25,
                                              width: double.infinity,
                                              child: pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          1),
                                                  child: pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      crossAxisAlignment: pw
                                                          .CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        // pw.Text("Add:",style: pw.TextStyle(fontSize: 9,fontStyle: pw.FontStyle.normal)),
                                                        pw.SizedBox(width: 10),
                                                        pw.Column(
                                                            mainAxisAlignment: pw
                                                                .MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment: pw
                                                                .CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              pw.Text(
                                                                  igst
                                                                      ? igstV
                                                                      : cgst,
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontStyle: pw
                                                                          .FontStyle
                                                                          .italic)),
                                                              pw.Text(
                                                                  igst
                                                                      ? ""
                                                                      : sgst,
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      fontStyle: pw
                                                                          .FontStyle
                                                                          .italic))
                                                            ])
                                                      ])))
                                        ],
                                      )))
                            ])
                          ])),

                      pw.Stack(children: [
                        pw.Container(
                            width: double.infinity,
                            height: 96,
                            child: pw.Column(children: [
                              pw.Container(
                                  width: double.infinity,
                                  height: 31,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.white))),
                                  child: pw.Row(children: [
                                    pw.Row(children: [
                                      pw.Container(width: 486),
                                      pw.Container(
                                        width: 89,
                                        height: double.infinity,
                                        child: pw.Padding(
                                            padding:
                                                const pw.EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                            child: pw.Text(grandTotal,
                                                textAlign: pw.TextAlign.right,
                                                style: pw.TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        pw.FontWeight.bold))),
                                        decoration: const pw.BoxDecoration(
                                            border: pw.Border(
                                                left: pw.BorderSide(
                                                    color: PdfColors.black),
                                                bottom: pw.BorderSide(
                                                    color: PdfColors.black))),
                                      )
                                    ])
                                  ])),
                              pw.Container(
                                  height: 65,
                                  width: double.infinity,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              color: PdfColors.black)))),
                            ])),
                        pw.Container(
                            width: 486,
                            height: 96,
                            child: pw.Container(
                                height: double.infinity,
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        top: 5, right: 7, bottom: 10, left: 7),
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Container(
                                              height: 32,
                                              width: double.infinity,
                                              child: pw.Row(
                                                  mainAxisAlignment: pw
                                                      .MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    pw.Row(children: [
                                                      pw.Column(children: [
                                                        pw.Text("Tax Rate",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text(taxRate,
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                      pw.Column(children: [
                                                        pw.Text(
                                                            "Taxable Amount",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text(
                                                            "Rs. $taxAmount",
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                      pw.Column(children: [
                                                        pw.Text("Total Tax",
                                                            style: pw.TextStyle(
                                                                fontSize: 10,
                                                                decoration: pw
                                                                    .TextDecoration
                                                                    .underline,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(height: 2),
                                                        pw.Text("Rs. $totalTax",
                                                            style: const pw
                                                                .TextStyle(
                                                                fontSize: 10))
                                                      ]),
                                                      pw.SizedBox(width: 10),
                                                    ]),
                                                    pw.Row(children: [
                                                      pw.Text(
                                                          "Grand Total (Rs.)",
                                                          style: pw.TextStyle(
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              fontSize: 10)),
                                                      // pw.Text("₹",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                                    ])
                                                  ])),
                                          pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text("Grand Total In Words",
                                                    style: const pw.TextStyle(
                                                        fontSize: 9)),
                                                pw.SizedBox(height: 2),
                                                pw.Text(
                                                    "$grandTotalInWords Only",
                                                    style: pw.TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            pw.FontWeight.bold))
                                              ])
                                        ])))),
                      ]),

                      pw.Container(
                          height: 43,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom:
                                      pw.BorderSide(color: PdfColors.black))),
                          child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 7),
                              child: pw.Row(children: [
                                pw.Container(
                                    height: double.infinity,
                                    width: 83,
                                    child: pw.Row(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text("Banking Details",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10)),
                                          pw.Text(":",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10))
                                        ])),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 7),
                                    child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        children: [
                                          pw.Text(bank1 == null ? "" : bank1,
                                              style: text9),
                                          pw.Text(bank2 == null ? "" : bank2,
                                              style: text9),
                                          pw.Text(bank3 == null ? "" : bank3,
                                              style: text9),
                                        ]))
                              ]))),
                      pw.Container(
                          height: 91,
                          width: double.infinity,
                          decoration: const pw.BoxDecoration(),
                          child: pw.Row(children: [
                            pw.Container(
                                width: 287,
                                height: double.infinity,
                                child: pw.Padding(
                                    padding: const pw.EdgeInsets.all(7),
                                    child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text("Terms And Conditions",
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  fontSize: 10)),
                                          pw.SizedBox(height: 5),
                                          pw.Text(tnc1 == null ? "" : "- $tnc1",
                                              style: text9),
                                          pw.Text(tnc2 == null ? "" : "- $tnc2",
                                              style: text9),
                                          pw.Text(tnc3 == null ? "" : "- $tnc3",
                                              style: text9),
                                          pw.Text(tnc4 == null ? "" : "- $tnc4",
                                              style: text9),
                                        ])),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        right: pw.BorderSide(
                                            color: PdfColors.black)))),
                            pw.Container(
                                width: 288,
                                height: double.infinity,
                                child: pw.Column(children: [
                                  pw.Container(
                                      width: double.infinity,
                                      height: 91,
                                      child: pw.Stack(children: [
                                        pw.Padding(
                                            padding: const pw.EdgeInsets.all(7),
                                            child: pw.Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: pw.Column(
                                                    mainAxisAlignment: pw
                                                        .MainAxisAlignment.end,
                                                    crossAxisAlignment: pw
                                                        .CrossAxisAlignment.end,
                                                    children: [
                                                      pw.Text(
                                                          "For ${firmName.toUpperCase()}",
                                                          style: pw.TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold)),
                                                      pw.Text(
                                                          "Authorised Signatory",
                                                          style: const pw
                                                              .TextStyle(
                                                              fontSize: 7))
                                                    ]))),
                                        sign.length != 0
                                            ? pw.Positioned(
                                                right: 20,
                                                top: 2.5,
                                                child: pw.Opacity(
                                                    opacity: 0.9,
                                                    child: pw.Container(
                                                      height: 85,
                                                      width: 85,
                                                      decoration: pw.BoxDecoration(
                                                          image: pw.DecorationImage(
                                                              image: pw
                                                                  .MemoryImage(
                                                                      sign))),
                                                    )))
                                            : pw.SizedBox(),
                                        pw.Positioned(
                                            top: 0,
                                            left: 5,
                                            child: pw.Container(
                                                padding: pw.EdgeInsets.only(
                                                    right: 5),
                                                decoration: pw.BoxDecoration(
                                                    border: pw.Border(
                                                        right: pw.BorderSide(
                                                            color:
                                                                PdfColors.black,
                                                            width: 1))),
                                                height: 91,
                                                width: 70,
                                                child: pw.Column(children: [
                                                  pw.SizedBox(height: 5),
                                                  pw.Image(
                                                      fit: pw.BoxFit.contain,
                                                      pw.MemoryImage(qr)),
                                                  pw.SizedBox(height: 2),
                                                  pw.Text("Payment QR",
                                                      style: pw.TextStyle(
                                                          fontSize: 7,
                                                          color:
                                                              PdfColors.black)),
                                                ]))),
                                      ])),
                                ])),
                          ])),
                    ]),
                    decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PdfColors.black, width: 1)))));
      },
    ),
  );

  // Save the PDF to a file
  final Uint8List bytes = await pdf.save();
  final file = File(path);
  await file.writeAsBytes(bytes);
  return 'PDF Saved';
}
