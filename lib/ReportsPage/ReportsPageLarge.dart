// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:billing/InvoicesPageSection/InvoicePageLarge.dart';
import 'package:billing/NavBar/LargeNavbar.dart';
import 'package:billing/ReportsPage/ReportsConstants.dart';
import 'package:billing/ReportsPage/excelCreate.dart';
import 'package:billing/ReportsPage/functions.dart';
// ignore: unused_import
import 'package:billing/Settings%20Page/settingsPageLarge.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:flutter/material.dart';

class ReportsPageLarge extends StatefulWidget {
  const ReportsPageLarge({super.key});

  @override
  State<ReportsPageLarge> createState() => _ReportsPageLargeState();
}

class _ReportsPageLargeState extends State<ReportsPageLarge> {
  List Months = [
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
  late String startMonth, endMonth;
  List<DropdownMenuEntry<dynamic>> yearDrop = [];
  TextEditingController startMonthController = TextEditingController();
  TextEditingController startMonthControllerSales = TextEditingController();
  TextEditingController endMonthController = TextEditingController();
  TextEditingController endMonthControllerSales = TextEditingController();
  TextEditingController yearControllerSales =
      TextEditingController(text: currentYear());
  List<DropdownMenuEntry<dynamic>> drop = [
    const DropdownMenuEntry(value: "January", label: "January"),
    const DropdownMenuEntry(value: "February", label: "February"),
    const DropdownMenuEntry(value: "March", label: "March"),
    const DropdownMenuEntry(value: "April", label: "April"),
    const DropdownMenuEntry(value: "May", label: "May"),
    const DropdownMenuEntry(value: "June", label: "June"),
    const DropdownMenuEntry(value: "July", label: "July"),
    const DropdownMenuEntry(value: "August", label: "August"),
    const DropdownMenuEntry(value: "September", label: "September"),
    const DropdownMenuEntry(value: "October", label: "October"),
    const DropdownMenuEntry(value: "November", label: "November"),
    const DropdownMenuEntry(value: "December", label: "December"),
  ];
  void setYears() {
    File file = File("Database/Invoices/In.json");
    dynamic tempContent = file.readAsStringSync();
    tempContent = jsonDecode(tempContent);
    List keyss = tempContent.keys.toList();
    keyss.sort();
    for (var i = 0; i < keyss.length; i++) {
      yearDrop.add(DropdownMenuEntry(
          value: keyss[i].toString(), label: keyss[i].toString()));
    }
  }

  String calculateSalesandPurchase(
      String year, String startMonth, String endMonth) {
    File sales = File("Database/Invoices/In.json");
    dynamic salesContent = sales.readAsStringSync();
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
    double totalSales = 0;
    String totalSalesW = "";
    salesContent = jsonDecode(salesContent);
    List yearKeys = salesContent.keys.toList();

    if (yearKeys.contains(year)) {
      List monthKeys = salesContent[year].keys.toList();
      String startMonthKey = months.indexOf(startMonth).toString();
      String endMonthKey = months.indexOf(endMonth).toString();
      if (startMonthKey.length == 1) {
        startMonthKey = "0$startMonthKey";
      }
      if (endMonthKey.length == 1) {
        endMonthKey = "0$endMonthKey";
      }

      for (var i = int.parse(startMonthKey); i <= int.parse(endMonthKey); i++) {
        var tempKey = i.toString();
        if (tempKey.length == 1) {
          tempKey = "0$tempKey";
        }
        if (monthKeys.contains(tempKey)) {
          dynamic content = salesContent[year][tempKey];
          List contentKeys = content.keys.toList();
          for (var j = 0; j < contentKeys.length; j++) {
            totalSales += convertIndianFormattedStringToNumber(
                content[contentKeys[j]]['grandtotal']);
          }
        }
      }
      totalSalesW = formatIntegerToIndian(totalSales);
      return totalSalesW;
    } else {
      return "Year Not Available";
    }
  }

  String calculatePurchase(String year, String startMonth, String endMonth) {
    File purchase = File("Database/Invoices/purchase.json");
    dynamic purchaseContent = purchase.readAsStringSync();
    purchaseContent = jsonDecode(purchaseContent);
    List yearKeys = purchaseContent.keys.toList();
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
    double totalPurchase = 0;
    String totalPurchaseW = "";
    String startMonthKey = months.indexOf(startMonth).toString();
    String endMonthKey = months.indexOf(endMonth).toString();
    if (yearKeys.contains(year)) {
      if (startMonthKey.length == 1) {
        startMonthKey = "0$startMonthKey";
      }
      if (endMonthKey.length == 1) {
        endMonthKey = "0$endMonthKey";
      }
      if (yearKeys.contains(year)) {
        List monthKeys = purchaseContent[year].keys.toList();
        for (var i = int.parse(startMonthKey);
            i <= int.parse(endMonthKey);
            i++) {
          var temp = i.toString();
          temp.length == 1 ? temp = "0$temp" : temp = i.toString();
          if (monthKeys.contains(temp)) {
            dynamic monthRecord = purchaseContent[year][temp];
            for (var j = 0; j < monthRecord.length; j++) {
              var tempContent = purchaseContent[year][temp][j];
              var tempKey = tempContent.keys.toList();
              totalPurchase += convertIndianFormattedStringToNumber(
                  tempContent[tempKey[0]]['grandTotal']);
            }
          }
        }
        totalPurchaseW = formatIntegerToIndian(totalPurchase);
        return totalPurchaseW;
      } else {
        return "Year Not Found";
      }
    } else {
      return "Year Not Found";
    }
  }

  String calculateNetRevenue(TextEditingController year,
      TextEditingController start, TextEditingController end) {
    double sales = 0, purchase = 0;
    // ignore: prefer_typing_uninitialized_variables
    var temp;
    if (calculateSalesandPurchase(year.text, start.text, end.text) ==
        "Year Not Available") {
      sales = 0;
    } else {
      sales = convertIndianFormattedStringToNumber(
          calculateSalesandPurchase(year.text, start.text, end.text));
    }
    if (calculatePurchase(year.text, start.text, end.text) ==
        "Year Not Found") {
      purchase = 0;
    } else {
      purchase = convertIndianFormattedStringToNumber(
          calculatePurchase(year.text, start.text, end.text));
    }

    temp = sales - purchase;
    return makeFullDouble(formatIntegerToIndian(temp));
  }

  @override
  void initState() {
    startMonth = Months[ReportConstants.startMonth];
    endMonth = Months[ReportConstants.endMonth];
    startMonthController.text = startMonth;
    endMonthController.text = endMonth;
    startMonthControllerSales.text = startMonth;
    endMonthControllerSales.text = endMonth;
    setYears();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenWidth2 = MediaQuery.of(context).devicePixelRatio;
    double actualWidth = screenWidth / screenWidth2;
    double fontSize = 17;
    if (actualWidth < 1500) {
      fontSize = 13;
    } else if (actualWidth < 1700) {
      fontSize = 14;
    } else if (actualWidth < 1800) {
      fontSize = 16;
    }

    return Container(
        width: double.infinity,
        color: ColorPalette.offWhite.withOpacity(0.5),
        padding: const EdgeInsets.fromLTRB(30, 38, 30, 0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 1050,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: "Revenue",
                              style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          TextSpan(
                              text: " Report",
                              style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                  color: ColorPalette.blueAccent)),
                        ])),
                        Row(
                          children: [
                            DropdownMenu(
                                menuStyle: const MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromARGB(255, 245, 245, 245))),
                                menuHeight: 900,
                                textStyle: const TextStyle(
                                    fontSize: 13, fontFamily: 'Poppins'),
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  setState(() {
                                    yearControllerSales.text = value;
                                  });
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            width: 1.3, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                                controller: yearControllerSales,
                                width: 160,
                                dropdownMenuEntries: yearDrop),
                            const SizedBox(
                              width: 60,
                            ),
                            const Text(
                              "Duration: ",
                              style: TextStyle(
                                  fontSize: 13, fontFamily: 'Poppins'),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            DropdownMenu(
                                menuStyle: const MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromARGB(255, 245, 245, 245))),
                                menuHeight: 900,
                                textStyle: const TextStyle(
                                    fontSize: 13, fontFamily: 'Poppins'),
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  setState(() {
                                    startMonthControllerSales.text = value;
                                    startMonthController.text = value;
                                  });
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            width: 1.3, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                                controller: startMonthControllerSales,
                                width: 160,
                                dropdownMenuEntries: drop),
                            const SizedBox(
                              width: 15,
                            ),
                            const Text(
                              "To",
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 13),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            DropdownMenu(
                                menuStyle: const MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromARGB(255, 245, 245, 245))),
                                menuHeight: 900,
                                textStyle: const TextStyle(
                                    fontSize: 13, fontFamily: 'Poppins'),
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  setState(() {
                                    endMonthControllerSales.text = value;
                                    endMonthController.text = value;
                                  });
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            width: 1.3, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                                controller: endMonthControllerSales,
                                width: 160,
                                dropdownMenuEntries: drop),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SalesReportCard(
                            //     heading: "Total Sales",
                            //     value: ""),
                            SalesReportCard(
                                fontSize: fontSize,
                                heading: "Total Sales",
                                value: makeFullDouble(calculateSalesandPurchase(
                                            yearControllerSales.text,
                                            startMonthControllerSales.text,
                                            endMonthControllerSales.text) ==
                                        "Year Not Available"
                                    ? "0.00"
                                    : calculateSalesandPurchase(
                                        yearControllerSales.text,
                                        startMonthControllerSales.text,
                                        endMonthControllerSales.text))),
                            const SizedBox(
                              width: 36,
                            ),

                            SalesReportCard(
                                fontSize: fontSize,
                                heading: "Total Purchase",
                                value: makeFullDouble(calculatePurchase(
                                            yearControllerSales.text,
                                            startMonthControllerSales.text,
                                            endMonthControllerSales.text) ==
                                        "Year Not Found"
                                    ? "0.00"
                                    : calculatePurchase(
                                        yearControllerSales.text,
                                        startMonthControllerSales.text,
                                        endMonthControllerSales.text))),
                          ],
                        ),
                        const SizedBox(
                          height: 36,
                        ),
                        SalesReportCard(
                          fontSize: fontSize,
                          heading: "Net Revenue",
                          value: makeFullDouble(calculateNetRevenue(
                              yearControllerSales,
                              startMonthControllerSales,
                              endMonthControllerSales)),
                        )
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: "Generate",
                              style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          TextSpan(
                              text: " Reports",
                              style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                  color: ColorPalette.blueAccent)),
                        ])),
                        Row(
                          children: [
                            const Text(
                              "Duration:",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            DropdownMenu(
                                menuStyle: const MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromARGB(255, 245, 245, 245))),
                                menuHeight: 900,
                                textStyle: const TextStyle(
                                    fontSize: 13, fontFamily: 'Poppins'),
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  setState(() {
                                    startMonthController.text = value;
                                  });
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            width: 1.3, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                                controller: startMonthController,
                                width: 160,
                                dropdownMenuEntries: drop),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              "To",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            DropdownMenu(
                                menuStyle: const MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromARGB(255, 245, 245, 245))),
                                initialSelection: 1,
                                menuHeight: 900,
                                textStyle: const TextStyle(
                                    fontSize: 13, fontFamily: 'Poppins'),
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  setState(() {
                                    endMonthController.text = value;
                                  });
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            width: 1.3, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                                controller: endMonthController,
                                width: 160,
                                dropdownMenuEntries: drop),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Sales Report: ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    backgroundColor: WidgetStatePropertyAll(
                                        ColorPalette.darkBlue)),
                                onPressed: () {
                                  excelGenerate(
                                      yearControllerSales.text,
                                      startMonthControllerSales.text,
                                      endMonthControllerSales.text);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Export As XLSX",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                          height: 21,
                                          width: 21,
                                          child: Image.asset(
                                            'assets/images/excel.png',
                                            fit: BoxFit.contain,
                                          ))
                                    ],
                                  ),
                                )),
                            // const SizedBox(
                            //   width: 30,
                            // ),
                            // TextButton(
                            //     style: ButtonStyle(
                            //         shape: WidgetStatePropertyAll(
                            //             RoundedRectangleBorder(
                            //                 borderRadius:
                            //                     BorderRadius.circular(3))),
                            //         backgroundColor: WidgetStatePropertyAll(
                            //             ColorPalette.darkBlue)),
                            //     onPressed: () {},
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 25.0, vertical: 8),
                            //       child: Row(
                            //         children: [
                            //           const Text(
                            //             "Save As PDF",
                            //             style: TextStyle(color: Colors.white),
                            //           ),
                            //           const SizedBox(
                            //             width: 10,
                            //           ),
                            //           SizedBox(
                            //               height: 23,
                            //               width: 23,
                            //               child:
                            //                   Image.asset('assets/images/pdf.png'))
                            //         ],
                            //       ),
                            //     )),

                            // TextButton(
                            //     style: ButtonStyle(
                            //         shape: WidgetStatePropertyAll(
                            //             RoundedRectangleBorder(
                            //                 borderRadius:
                            //                     BorderRadius.circular(3))),
                            //         backgroundColor: WidgetStatePropertyAll(
                            //             ColorPalette.darkBlue)),
                            //     onPressed: () {},
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 14.0, vertical: 8),
                            //       child: Row(
                            //         children: [
                            //           const Text(
                            //             "Export As JSON",
                            //             style: TextStyle(color: Colors.white),
                            //           ),
                            //           const SizedBox(
                            //             width: 10,
                            //           ),
                            //           SizedBox(
                            //               height: 23,
                            //               width: 23,
                            //               child:
                            //                   Image.asset('assets/images/json.png'))
                            //         ],
                            //       ),
                            //     )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Purchase Report: ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    backgroundColor: WidgetStatePropertyAll(
                                        ColorPalette.darkBlue)),
                                onPressed: () {
                                  generatePurchase(
                                      yearControllerSales.text,
                                      startMonthControllerSales.text,
                                      endMonthControllerSales.text);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Export As XLSX",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                          height: 21,
                                          width: 21,
                                          child: Image.asset(
                                            'assets/images/excel.png',
                                            fit: BoxFit.contain,
                                          ))
                                    ],
                                  ),
                                )),
                            // const SizedBox(
                            //   width: 30,
                            // ),
                            // TextButton(
                            //     style: ButtonStyle(
                            //         shape: WidgetStatePropertyAll(
                            //             RoundedRectangleBorder(
                            //                 borderRadius:
                            //                     BorderRadius.circular(3))),
                            //         backgroundColor: WidgetStatePropertyAll(
                            //             ColorPalette.darkBlue)),
                            //     onPressed: () {},
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 25.0, vertical: 8),
                            //       child: Row(
                            //         children: [
                            //           const Text(
                            //             "Save As PDF",
                            //             style: TextStyle(color: Colors.white),
                            //           ),
                            //           const SizedBox(
                            //             width: 10,
                            //           ),
                            //           SizedBox(
                            //               height: 23,
                            //               width: 23,
                            //               child:
                            //                   Image.asset('assets/images/pdf.png'))
                            //         ],
                            //       ),
                            //     )),

                            // TextButton(
                            //     style: ButtonStyle(
                            //         shape: WidgetStatePropertyAll(
                            //             RoundedRectangleBorder(
                            //                 borderRadius:
                            //                     BorderRadius.circular(3))),
                            //         backgroundColor: WidgetStatePropertyAll(
                            //             ColorPalette.darkBlue)),
                            //     onPressed: () {},
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 14.0, vertical: 8),
                            //       child: Row(
                            //         children: [
                            //           const Text(
                            //             "Export As JSON",
                            //             style: TextStyle(color: Colors.white),
                            //           ),
                            //           const SizedBox(
                            //             width: 10,
                            //           ),
                            //           SizedBox(
                            //               height: 23,
                            //               width: 23,
                            //               child:
                            //                   Image.asset('assets/images/json.png'))
                            //         ],
                            //       ),
                            //     )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

Widget PurchaseRecordHeader2(
    {required BuildContext context,
    required int index,
    required Function fn,
    required String month,
    required String year,
    required String sno,
    required String partyName,
    required String partyAddress,
    required String gst,
    required String date,
    required String desc,
    required String grandTotal}) {
  int color = 1;

  return Column(
    children: [
      const SizedBox(
        height: 12,
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: index % 2 == 0
              ? const Color.fromARGB(255, 225, 225, 225)
              : const Color.fromARGB(255, 239, 239, 239),
        ),
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InvoiceRecordHeaderText2(40, sno, color, 199),
            InvoiceRecordHeaderText2(330, partyName, color, 199),
            InvoiceRecordHeaderText2(320, partyAddress, color, 199),
            InvoiceRecordHeaderText2(230, gst, color, 199),
            InvoiceRecordHeaderText2(180, date, color, 199),
            InvoiceRecordHeaderText2(260, desc, color, 199),
            InvoiceRecordHeaderText2(180, grandTotal, color, 199),
            Container(
              width: 180,
              height: 50,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        showEditInvoiceWindow2(
                            context, sno, year, month, () {}, fn);
                      },
                      child: const Tooltip(
                          message: "Edit Invoice",
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ))),
                  const SizedBox(width: 15),
                ],
              ),
            )
          ],
        ),
      ),
    ],
  );
}

Widget SalesReportCard(
    {required String heading,
    required String value,
    required double fontSize}) {
  return Container(
    height: fontSize * 8.89,
    width: 500,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(boxShadow: const [
      BoxShadow(
          color: Color.fromARGB(95, 207, 207, 207),
          spreadRadius: 2,
          blurRadius: 8,
          offset: Offset(0, 2))
    ], borderRadius: BorderRadius.circular(7), color: Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          heading,
          style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
        ),
        const SizedBox(
          height: 1,
        ),
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "₹ ",
              style: TextStyle(
                  color: ColorPalette.dark,
                  fontFamily: 'Gilroy',
                  fontSize: fontSize * 2.5,
                  fontWeight: FontWeight.w400)),
          TextSpan(
              text: value,
              style: TextStyle(
                  letterSpacing: 1.5,
                  fontFamily: 'Gilroy',
                  color: const Color.fromARGB(255, 41, 41, 41),
                  fontSize: fontSize * 2.5,
                  fontWeight: FontWeight.w400)),
        ]))
      ],
    ),
  );
}
