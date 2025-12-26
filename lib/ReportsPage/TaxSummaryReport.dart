// ignore_for_file: must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:flutter/material.dart';

class TaxSummaryReport extends StatefulWidget {
  final String year;
  final String startMonth;
  final String endMonth;
  final double fontSize;

  TaxSummaryReport({
    super.key,
    required this.year,
    required this.startMonth,
    required this.endMonth,
    required this.fontSize,
  });

  @override
  State<TaxSummaryReport> createState() => _TaxSummaryReportState();
}

class _TaxSummaryReportState extends State<TaxSummaryReport> {
  Map<String, dynamic> calculateTaxSummary() {
    File invoicesFile = File("Database/Invoices/In.json");
    Map<String, dynamic> summary = {
      'totalSales': 0.0,
      'totalIGST': 0.0,
      'totalCGST': 0.0,
      'totalSGST': 0.0,
      'totalTax': 0.0,
      'monthlyBreakdown': <String, Map<String, double>>{},
    };

    if (!invoicesFile.existsSync()) {
      return summary;
    }

    dynamic invoicesContent = invoicesFile.readAsStringSync();
    invoicesContent = jsonDecode(invoicesContent);

    List months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    int startMonthIndex = months.indexOf(widget.startMonth);
    int endMonthIndex = months.indexOf(widget.endMonth);

    if (invoicesContent[widget.year] != null && invoicesContent[widget.year] is Map) {
      invoicesContent[widget.year].forEach((month, monthData) {
        if (monthData is Map) {
          int monthNum = int.tryParse(month) ?? 0;
          if (monthNum >= startMonthIndex && monthNum <= endMonthIndex) {
            String monthName = months[monthNum];
            summary['monthlyBreakdown'][monthName] = {
              'sales': 0.0,
              'igst': 0.0,
              'cgst': 0.0,
              'sgst': 0.0,
              'tax': 0.0,
            };

            monthData.forEach((invoiceNo, invoiceData) {
              if (invoiceData is Map) {
                double sales = convertIndianFormattedStringToNumber(
                    invoiceData['grandtotal'] ?? '0');
                double igst = 0.0;
                double cgst = 0.0;
                double sgst = 0.0;

                if (invoiceData['igst'] == true) {
                  igst = convertIndianFormattedStringToNumber(
                      invoiceData['igstV'] ?? '0');
                } else {
                  cgst = convertIndianFormattedStringToNumber(
                      invoiceData['cgst'] ?? '0');
                  sgst = convertIndianFormattedStringToNumber(
                      invoiceData['sgst'] ?? '0');
                }

                double tax = igst + cgst + sgst;

                summary['totalSales'] += sales;
                summary['totalIGST'] += igst;
                summary['totalCGST'] += cgst;
                summary['totalSGST'] += sgst;
                summary['totalTax'] += tax;

                summary['monthlyBreakdown'][monthName]!['sales'] += sales;
                summary['monthlyBreakdown'][monthName]!['igst'] += igst;
                summary['monthlyBreakdown'][monthName]!['cgst'] += cgst;
                summary['monthlyBreakdown'][monthName]!['sgst'] += sgst;
                summary['monthlyBreakdown'][monthName]!['tax'] += tax;
              }
            });
          }
        }
      });
    }

    return summary;
  }

  Future<void> exportTaxSummaryToExcel() async {
    try {
      String? outputPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save tax summary Excel',
      );

      if (outputPath == null) return;

      Map<String, dynamic> taxSummary = calculateTaxSummary();
      
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = "Tax Summary";

      // Header Style
      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.hAlign = xlsio.HAlignType.center;
      headerStyle.vAlign = xlsio.VAlignType.center;
      headerStyle.bold = true;
      headerStyle.fontSize = 14;
      headerStyle.backColor = '#3049AA';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      headerStyle.borders.all.color = '#000000';

      // Summary Style
      final xlsio.Style summaryStyle = workbook.styles.add('summaryStyle');
      summaryStyle.bold = true;
      summaryStyle.fontSize = 12;

      // Data Style
      final xlsio.Style dataStyle = workbook.styles.add('dataStyle');
      dataStyle.fontSize = 11;
      dataStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      dataStyle.borders.all.color = '#000000';

      int row = 1;

      // Title
      sheet.getRangeByName('A$row:E$row').merge();
      sheet.getRangeByName('A$row').setText('Tax Summary Report');
      sheet.getRangeByName('A$row').cellStyle = summaryStyle;
      sheet.getRangeByName('A$row').cellStyle.hAlign = xlsio.HAlignType.center;
      row += 2;

      // Period
      sheet.getRangeByName('A$row').setText('Year: ${widget.year}');
      row++;
      sheet.getRangeByName('A$row').setText('Period: ${widget.startMonth} to ${widget.endMonth}');
      row += 2;

      // Summary Section
      sheet.getRangeByName('A$row').setText('Total Sales');
      sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(taxSummary['totalSales'])}');
      sheet.getRangeByName('A$row:B$row').cellStyle = summaryStyle;
      row++;
      sheet.getRangeByName('A$row').setText('Total IGST');
      sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(taxSummary['totalIGST'])}');
      row++;
      sheet.getRangeByName('A$row').setText('Total CGST');
      sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(taxSummary['totalCGST'])}');
      row++;
      sheet.getRangeByName('A$row').setText('Total SGST');
      sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(taxSummary['totalSGST'])}');
      row++;
      sheet.getRangeByName('A$row').setText('Total Tax');
      sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(taxSummary['totalTax'])}');
      sheet.getRangeByName('A$row:B$row').cellStyle = summaryStyle;
      row += 2;

      // Table Header
      sheet.getRangeByName('A$row').setText('Month');
      sheet.getRangeByName('B$row').setText('Sales');
      sheet.getRangeByName('C$row').setText('IGST');
      sheet.getRangeByName('D$row').setText('CGST');
      sheet.getRangeByName('E$row').setText('SGST');
      sheet.getRangeByName('F$row').setText('Total Tax');
      sheet.getRangeByName('A$row:F$row').cellStyle = headerStyle;
      row++;

      // Table Data
      List months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      ((taxSummary['monthlyBreakdown'] as Map<String, Map<String, double>>)
              .entries
              .toList()
            ..sort((a, b) {
              return months.indexOf(a.key).compareTo(months.indexOf(b.key));
            }))
          .forEach((entry) {
            sheet.getRangeByName('A$row').setText(entry.key);
            sheet.getRangeByName('B$row').setText('₹ ${formatIntegerToIndian(entry.value['sales'] ?? 0.0)}');
            sheet.getRangeByName('C$row').setText('₹ ${formatIntegerToIndian(entry.value['igst'] ?? 0.0)}');
            sheet.getRangeByName('D$row').setText('₹ ${formatIntegerToIndian(entry.value['cgst'] ?? 0.0)}');
            sheet.getRangeByName('E$row').setText('₹ ${formatIntegerToIndian(entry.value['sgst'] ?? 0.0)}');
            sheet.getRangeByName('F$row').setText('₹ ${formatIntegerToIndian(entry.value['tax'] ?? 0.0)}');
            sheet.getRangeByName('A$row:F$row').cellStyle = dataStyle;
            row++;
          });

      // Auto fit columns
      sheet.getRangeByName('A1:F${row - 1}').autoFitColumns();

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      String fileName = 'TaxSummary_${widget.year}_${widget.startMonth}_to_${widget.endMonth}.xlsx';
      File file = File('$outputPath\\$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tax summary exported to: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting tax summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> taxSummary = calculateTaxSummary();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(95, 207, 207, 207),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Tax ",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Gilroy')),
                TextSpan(
                    text: "Summary",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.blueAccent,
                        fontFamily: 'Gilroy')),
              ])),
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
                onPressed: exportTaxSummaryToExcel,
                icon: const Icon(Icons.file_download, color: Colors.white, size: 18),
                label: const Text(
                  "Export Excel",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Summary Cards - 2 cards per row
          Column(
            children: [
              // Row 1: Total Sales, Total IGST
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Total Sales",
                      formatIntegerToIndian(taxSummary['totalSales']),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSummaryCard(
                      "Total IGST",
                      formatIntegerToIndian(taxSummary['totalIGST']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Row 2: Total CGST, Total SGST
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Total CGST",
                      formatIntegerToIndian(taxSummary['totalCGST']),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSummaryCard(
                      "Total SGST",
                      formatIntegerToIndian(taxSummary['totalSGST']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Row 3: Total Tax (centered)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Total Tax",
                      formatIntegerToIndian(taxSummary['totalTax']),
                      isHighlight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Monthly Breakdown Table
          Text(
            "Monthly Breakdown",
            style: TextStyle(
              fontSize: widget.fontSize * 1.2,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              color: ColorPalette.darkBlue,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: ColorPalette.offWhite.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        ColorPalette.dark,
                        ColorPalette.dark.withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("Month", FontWeight.w600)),
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("Sales", FontWeight.w600)),
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("IGST", FontWeight.w600)),
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("CGST", FontWeight.w600)),
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("SGST", FontWeight.w600)),
                      Expanded(
                          flex: 2,
                          child: _buildHeaderText("Total Tax", FontWeight.w600)),
                    ],
                  ),
                ),
                // Table Rows
                ...((taxSummary['monthlyBreakdown'] as Map<String, Map<String, double>>)
                        .entries
                        .toList()
                      ..sort((a, b) {
                        List months = [
                          '',
                          'January',
                          'February',
                          'March',
                          'April',
                          'May',
                          'June',
                          'July',
                          'August',
                          'September',
                          'October',
                          'November',
                          'December',
                        ];
                        return months.indexOf(a.key)
                            .compareTo(months.indexOf(b.key));
                      }))
                    .map((entry) {
                      int index = (taxSummary['monthlyBreakdown'] as Map)
                          .keys
                          .toList()
                          .indexOf(entry.key);
                      return Container(
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? ColorPalette.offWhite.withOpacity(0.2)
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                                color: ColorPalette.offWhite.withOpacity(0.3)),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: _buildCellText(entry.key,
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                                flex: 2,
                                child: _buildCellText(
                                    "₹ ${formatIntegerToIndian(entry.value['sales'] ?? 0.0)}")),
                            Expanded(
                                flex: 2,
                                child: _buildCellText(
                                    "₹ ${formatIntegerToIndian(entry.value['igst'] ?? 0.0)}")),
                            Expanded(
                                flex: 2,
                                child: _buildCellText(
                                    "₹ ${formatIntegerToIndian(entry.value['cgst'] ?? 0.0)}")),
                            Expanded(
                                flex: 2,
                                child: _buildCellText(
                                    "₹ ${formatIntegerToIndian(entry.value['sgst'] ?? 0.0)}")),
                            Expanded(
                                flex: 2,
                                child: _buildCellText(
                                    "₹ ${formatIntegerToIndian(entry.value['tax'] ?? 0.0)}",
                                    fontWeight: FontWeight.w600,
                                    color: ColorPalette.blueAccent)),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlight
            ? ColorPalette.blueAccent.withOpacity(0.1)
            : ColorPalette.offWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isHighlight
              ? ColorPalette.blueAccent.withOpacity(0.3)
              : ColorPalette.offWhite.withOpacity(0.5),
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
            title,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ $value",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              color: isHighlight ? ColorPalette.blueAccent : ColorPalette.darkBlue,
            ),
          ),
        ],
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
