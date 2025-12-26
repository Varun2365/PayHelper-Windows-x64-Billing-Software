// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/NavBar/LargeNavbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';

void showPartyLedgerDialog(BuildContext context, String partyName) {
  showDialog(
    context: context,
    builder: (c) {
      return Dialog(
        child: PartyLedgerDialog(partyName: partyName),
      );
    },
  );
}

class PartyLedgerDialog extends StatefulWidget {
  String partyName;
  PartyLedgerDialog({super.key, required this.partyName});

  @override
  State<PartyLedgerDialog> createState() => _PartyLedgerDialogState();
}

class _PartyLedgerDialogState extends State<PartyLedgerDialog> {
  List<Map<String, dynamic>> ledgerEntries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  double totalCredit = 0.0;
  double totalDebit = 0.0;
  double balance = 0.0;
  String selectedYear = "";
  List<DropdownMenuEntry<String>> yearOptions = [];
  TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadYears();
    loadLedgerData();
  }

  void loadYears() {
    File invoicesFile = File("Database/Invoices/In.json");
    if (invoicesFile.existsSync()) {
      dynamic invoicesContent = invoicesFile.readAsStringSync();
      invoicesContent = jsonDecode(invoicesContent);
      List<String> years = invoicesContent.keys.toList();
      years.sort((a, b) => b.compareTo(a));
      
      yearOptions = [
        const DropdownMenuEntry(value: "All", label: "All Years"),
        ...years.map((year) => DropdownMenuEntry(value: year, label: year)),
      ];
      
      if (years.isNotEmpty) {
        selectedYear = years[0];
        yearController.text = years[0];
      } else {
        selectedYear = "All";
        yearController.text = "All";
      }
    }
  }

  void loadLedgerData() {
    ledgerEntries.clear();
    totalCredit = 0.0;
    totalDebit = 0.0;
    balance = 0.0;

    // Read invoices from In.json
    File invoicesFile = File("Database/Invoices/In.json");
    if (invoicesFile.existsSync()) {
      dynamic invoicesContent = invoicesFile.readAsStringSync();
      invoicesContent = jsonDecode(invoicesContent);

      // Iterate through all years and months
      invoicesContent.forEach((year, yearData) {
        if (selectedYear != "All" && year != selectedYear) return;
        
        if (yearData is Map) {
          yearData.forEach((month, monthData) {
            if (monthData is Map) {
              monthData.forEach((invoiceNo, invoiceData) {
                if (invoiceData is Map &&
                    invoiceData['BillingName'] == widget.partyName) {
                  // This is an invoice for this party
                  double amount = convertIndianFormattedStringToNumber(
                      invoiceData['grandtotal'] ?? '0');
                  
                  ledgerEntries.add({
                    'date': invoiceData['Date'] ?? '',
                    'invoiceNo': invoiceNo,
                    'description': 'Invoice $invoiceNo',
                    'credit': amount,
                    'debit': 0.0,
                    'type': 'Invoice',
                    'year': year,
                    'month': month,
                  });
                  
                  totalCredit += amount;
                }
              });
            }
          });
        }
      });
    }

    // Sort by date (newest first)
    ledgerEntries.sort((a, b) {
      // Parse dates in DD/MM/YYYY format
      List aDate = a['date'].toString().split('/');
      List bDate = b['date'].toString().split('/');
      if (aDate.length == 3 && bDate.length == 3) {
        DateTime aDateTime = DateTime(
            int.parse(aDate[2]), int.parse(aDate[1]), int.parse(aDate[0]));
        DateTime bDateTime = DateTime(
            int.parse(bDate[2]), int.parse(bDate[1]), int.parse(bDate[0]));
        return bDateTime.compareTo(aDateTime);
      }
      return 0;
    });

    filteredEntries = List.from(ledgerEntries);
    balance = totalCredit - totalDebit;
    setState(() {});
  }

  Future<void> exportLedgerToPDF() async {
    try {
      String? outputPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save ledger PDF',
      );

      if (outputPath == null) return;

      final pdf = pw.Document();
      File firmDetails = File('Database/Firm/firmDetails.json');
      dynamic firm = {};
      if (firmDetails.existsSync()) {
        firm = jsonDecode(firmDetails.readAsStringSync());
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
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
                          firm['FirmName'] ?? 'Firm Name',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Party Ledger Statement',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Date: ${DateTime.now().toString().split(' ')[0]}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Party: ${widget.partyName}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (selectedYear != "All")
                  pw.Text(
                    'Year: $selectedYear',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                pw.SizedBox(height: 20),
                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Credit: Rs. ${formatIntegerToIndian(totalCredit)}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Total Debit: Rs. ${formatIntegerToIndian(totalDebit)}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Balance: Rs. ${formatIntegerToIndian(balance)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Invoice No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Credit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Debit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
                // Table Rows
                ...filteredEntries.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> item = entry.value;
                  double runningBalance = 0.0;
                  for (int i = 0; i <= index; i++) {
                    runningBalance += filteredEntries[i]['credit'] ?? 0.0;
                    runningBalance -= filteredEntries[i]['debit'] ?? 0.0;
                  }
                  
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 2, child: pw.Text(item['date'] ?? '', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(flex: 2, child: pw.Text(item['invoiceNo'] ?? '', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(flex: 3, child: pw.Text(item['description'] ?? '', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(flex: 2, child: pw.Text(item['credit'] > 0 ? 'Rs. ${formatIntegerToIndian(item['credit'])}' : '-', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(flex: 2, child: pw.Text(item['debit'] > 0 ? 'Rs. ${formatIntegerToIndian(item['debit'])}' : '-', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(flex: 2, child: pw.Text('Rs. ${formatIntegerToIndian(runningBalance)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      final Uint8List bytes = await pdf.save();
      String fileName = 'Ledger_${widget.partyName.replaceAll(' ', '_')}_${selectedYear == "All" ? "AllYears" : selectedYear}.pdf';
      File file = File('$outputPath\\$fileName');
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ledger exported to: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting ledger: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 1200,
        height: 700,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: ColorPalette.offWhite.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Party Ledger",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.darkBlue),
                      ),
                      Text(
                        widget.partyName,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Year Filter
                      Container(
                        width: 180,
                        child: DropdownMenu<String>(
                          menuStyle: const MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.white),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                          trailingIcon: const Icon(Icons.keyboard_arrow_down),
                          onSelected: (value) {
                            setState(() {
                              selectedYear = value ?? "All";
                              yearController.text = selectedYear;
                              loadLedgerData();
                            });
                          },
                          inputDecorationTheme: InputDecorationTheme(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                width: 1.5,
                                color: ColorPalette.blueAccent,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: ColorPalette.offWhite.withOpacity(0.8),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: ColorPalette.offWhite.withOpacity(0.8),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            filled: true,
                            fillColor: ColorPalette.offWhite.withOpacity(0.2),
                          ),
                          controller: yearController,
                          dropdownMenuEntries: yearOptions,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Export PDF Button
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(ColorPalette.dark),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        onPressed: exportLedgerToPDF,
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                        label: const Text(
                          "Export PDF",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: ColorPalette.offWhite.withOpacity(0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: ColorPalette.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColorPalette.offWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: ColorPalette.offWhite.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Credit",
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹ ${formatIntegerToIndian(totalCredit)}",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.darkBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColorPalette.offWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: ColorPalette.offWhite.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Debit",
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹ ${formatIntegerToIndian(totalDebit)}",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.darkBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColorPalette.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: ColorPalette.blueAccent.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Balance",
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹ ${formatIntegerToIndian(balance)}",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ledger Table Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: LinearGradient(
                    colors: [
                      ColorPalette.dark,
                      ColorPalette.dark.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildHeaderText("Date", FontWeight.w600)),
                    Expanded(
                        flex: 2,
                        child: _buildHeaderText("Invoice No.", FontWeight.w600)),
                    Expanded(
                        flex: 3,
                        child: _buildHeaderText("Description", FontWeight.w600)),
                    Expanded(
                        flex: 2,
                        child: _buildHeaderText("Credit", FontWeight.w600)),
                    Expanded(
                        flex: 2,
                        child: _buildHeaderText("Debit", FontWeight.w600)),
                    Expanded(
                        flex: 2,
                        child: _buildHeaderText("Balance", FontWeight.w600)),
                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Ledger Entries
            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            "No transactions found",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        double runningBalance = 0.0;
                        for (int i = 0; i <= index; i++) {
                          runningBalance += filteredEntries[i]['credit'] ?? 0.0;
                          runningBalance -= filteredEntries[i]['debit'] ?? 0.0;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: index % 2 == 0
                                ? ColorPalette.offWhite.withOpacity(0.2)
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: _buildCellText(
                                      filteredEntries[index]['date'] ?? '')),
                              Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      String year = filteredEntries[index]['year'];
                                      String month = filteredEntries[index]['month'];
                                      String invoiceNo =
                                          filteredEntries[index]['invoiceNo'];
                                      showEditInvoiceWindow2(
                                          context, invoiceNo, year, month, () {},
                                          () {});
                                    },
                                    child: _buildCellText(
                                        filteredEntries[index]['invoiceNo'] ?? '',
                                        color: ColorPalette.blueAccent),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: _buildCellText(
                                      filteredEntries[index]['description'] ?? '')),
                              Expanded(
                                  flex: 2,
                                  child: _buildCellText(
                                      filteredEntries[index]['credit'] > 0
                                          ? "₹ ${formatIntegerToIndian(filteredEntries[index]['credit'])}"
                                          : "-")),
                              Expanded(
                                  flex: 2,
                                  child: _buildCellText(
                                      filteredEntries[index]['debit'] > 0
                                          ? "₹ ${formatIntegerToIndian(filteredEntries[index]['debit'])}"
                                          : "-")),
                              Expanded(
                                  flex: 2,
                                  child: _buildCellText(
                                      "₹ ${formatIntegerToIndian(runningBalance)}",
                                      fontWeight: FontWeight.w600)),
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      String year = filteredEntries[index]['year'];
                                      String month = filteredEntries[index]['month'];
                                      String invoiceNo =
                                          filteredEntries[index]['invoiceNo'];
                                      showEditInvoiceWindow2(
                                          context, invoiceNo, year, month, () {},
                                          () {});
                                    },
                                    child: const Icon(
                                      Icons.open_in_new,
                                      color: Colors.pink,
                                      size: 20,
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: fontWeight,
        fontSize: 14,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCellText(String text,
      {Color? color, FontWeight fontWeight = FontWeight.w500}) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? ColorPalette.darkBlue,
        fontFamily: 'Poppins',
        fontWeight: fontWeight,
        fontSize: 13,
        letterSpacing: 0.1,
      ),
    );
  }
}
