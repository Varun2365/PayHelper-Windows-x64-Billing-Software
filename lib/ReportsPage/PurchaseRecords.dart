// ignore_for_file: non_constant_identifier_names, camel_case_types, must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'dart:io';

import 'package:billing/InvoicesPageSection/InvoicePageLarge.dart';
import 'package:billing/InvoicesPageSection/InvoiesPageFiles/InvoiceDefaults.dart';
import 'package:billing/ReportsPage/ReportsConstants.dart';
import 'package:billing/ReportsPage/addItemDialog.dart';
import 'package:billing/ReportsPage/functions.dart';
import 'package:billing/ReportsPage/purchaseGrandTotalSection.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:billing/createInvoiceLayout.dart';
import 'package:flutter/material.dart';

class PurchaseRecord extends StatefulWidget {
  const PurchaseRecord({super.key});

  @override
  State<PurchaseRecord> createState() => _PurchaseRecordState();
}

class _PurchaseRecordState extends State<PurchaseRecord> {
  //This sections holds the logic for the functioning of Year
  // and month selecting dropdowns.
  List availableMonths = [];
  List<DropdownMenuEntry> yearDropdownEntries = [];
  List availableYears = [];
  List selectedMonths = [];
  bool validMonth = false;
  String selectedYear = currentYear();
  File purchaseRecordFile = File("Database/Invoices/purchase.json");
  TextEditingController yearController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Initialize with the current year's data on startup
    setFile(selectedYear);
  }

  void stateFn() {
    setState(() {});
  }

  void setFile(String year) {
    availableMonths = [];
    yearDropdownEntries = [];

    log(availableMonths.toString());
    yearController.text = selectedYear;
    //Reading the file content
    dynamic purchaseRecordContent = purchaseRecordFile.readAsStringSync();
    purchaseRecordContent = jsonDecode(purchaseRecordContent);
    List keyss = purchaseRecordContent.keys.toList();

    if (keyss.contains(year)) {
      //Setting parameter Lists
      availableYears = purchaseRecordContent.keys.toList();
      availableYears.sort();
      setState(() {
        availableMonths = purchaseRecordContent[year].keys.toList();
        // Convert month numbers to month names for selectedMonths
        selectedMonths.clear(); // Clear existing selections
        for (var monthNumber in availableMonths) {
          selectedMonths.add(Months[int.parse(monthNumber) - 1]);
        }
        validMonth =
            selectedMonths.isNotEmpty; // Set validMonth based on availability
      });

      // Setting up  year dropdown related to
      // "availableYear" list
      for (var i = 0; i < availableYears.length; i++) {
        yearDropdownEntries.add(DropdownMenuEntry(
            value: availableYears[i], label: availableYears[i]));
      }
    } else {
      // If the selected year has no data, clear available months and selected months
      setState(() {
        availableMonths.clear();
        selectedMonths.clear();
        validMonth = false;
      });
    }
  }

  //This function updates the list of selected Months
  void updateSelectedMonthsinParent(List selectedMonths) {
    setState(() {
      this.selectedMonths = selectedMonths;
      // Re-evaluate validMonth based on the updated selectedMonths
      validMonth = selectedMonths.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calling setFile here will cause it to run on every rebuild.
    // It's better to manage data loading in initState or based on events.
    // If you need to re-fetch data based on external changes, consider
    // a more specific trigger. For initial load, initState is sufficient.
    // setFile(currentYear()); // Remove this line from build

    log(selectedMonths.toString());
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
    dynamic purchaseRecordContent = purchaseRecordFile.readAsStringSync();
    purchaseRecordContent = jsonDecode(purchaseRecordContent);

    return Container(
      padding: const EdgeInsets.only(top: 38, right: 30, left: 30),
      color: ColorPalette.offWhite.withOpacity(0.5),
      child: Container(
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(95, 207, 207, 207),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 2))
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13), topRight: Radius.circular(13))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Purchase",
                            style: TextStyle(
                                fontSize: fontSize * 1.7,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        TextSpan(
                            text: " Records",
                            style: TextStyle(
                                fontSize: fontSize * 1.7,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.blueAccent)),
                      ])),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3))),
                              backgroundColor: WidgetStatePropertyAll(
                                  ColorPalette.blueAccent)),
                          onPressed: () {
                            showPurchaseEntryDialog(context: context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: fontSize * .6,
                                vertical: fontSize * 00.6),
                            child: Text(
                              "Add New Record",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize * 0.8),
                            ),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      Tooltip(
                        message: "Refresh",
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                // Re-run setFile with the currently selected year to refresh
                                setFile(selectedYear);
                              });
                            },
                            child: const Icon(Icons.refresh)),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownMenu(
                          textStyle: TextStyle(fontSize: fontSize * 0.9),
                          trailingIcon: const Icon(Icons.keyboard_arrow_down),
                          onSelected: (value) {
                            setState(() {
                              selectedYear = value.toString();
                              // When the year changes, re-run setFile to update months for the new year
                              setFile(selectedYear);
                            });
                          },
                          inputDecorationTheme: InputDecorationTheme(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      width: 1.3, color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey))),
                          controller: yearController,
                          width: 160,
                          dropdownMenuEntries: yearDropdownEntries),
                      const SizedBox(
                        width: 14,
                      ),
                      Container(
                        height: 47,
                        width: 180,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                width: 0.5,
                                color: const Color.fromARGB(255, 21, 21, 21))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedMonths.length == 1
                                    ? selectedMonths[0]
                                    : selectedMonths.isEmpty
                                        ? "Select Month"
                                        : "Custom",
                                style: TextStyle(fontSize: fontSize * 0.8),
                              ),
                              InkWell(
                                  onTap: () {
                                    showMonthsPurchase(
                                        updateSelectedMonthsinParent:
                                            updateSelectedMonthsinParent,
                                        context: context,
                                        yearController: yearController);
                                  },
                                  child: const Icon(Icons.keyboard_arrow_down))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              PurchaseRecordHeader(fontSize),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: selectedMonths.isEmpty || !validMonth
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          nullRecord2(),
                        ],
                      )
                    : SingleChildScrollView(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: selectedMonths.length,
                            itemBuilder: (c, i) {
                              //Acquiring The Month Index
                              dynamic monthIndex =
                                  Months.indexOf(selectedMonths[i]) + 1;
                              monthIndex = monthIndex.toString();
                              if (monthIndex.length == 1) {
                                monthIndex = "0$monthIndex";
                              }

                              //Setting up parameters
                              dynamic content =
                                  purchaseRecordContent[selectedYear]
                                      [monthIndex];

                              return Column(
                                children: [
                                  Text(selectedMonths[i].toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: content.length,
                                      itemBuilder: (c1, i1) {
                                        dynamic temp2 = content[i1];
                                        List keys = temp2.keys.toList();
                                        dynamic fin = temp2[keys[0]];
                                        List dateList = fin['date'].split("/");
                                        return Column(
                                          children: [
                                            PurchaseRecordTile(
                                                fontSize: fontSize,
                                                setFile: stateFn,
                                                sno: i1,
                                                uid: keys[0],
                                                year: dateList[2],
                                                month: dateList[1],
                                                companyName: fin['name'],
                                                companyAddress: fin['address'],
                                                companyPhone: fin['contact'],
                                                companyGST: fin['gst'],
                                                date: fin['date'],
                                                totalAmount: fin['totalAmount'],
                                                totalTax: fin['totalTax'],
                                                grandTotal: fin['grandTotal'],
                                                products: fin['products']),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      }),
                                ],
                              );
                            })),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget PurchaseRecordHeader(double fontSize) {
  double containerWidth = 40;
  if (fontSize < 15) {
    containerWidth = fontSize * 2;
  }
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), color: ColorPalette.blueAccent),
    padding: const EdgeInsets.only(left: 10, right: 10),
    height: 40,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InvoiceRecordHeaderText(containerWidth * 1.3, "S.No.", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 8.2, "Company Details", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 3.75, "Date", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 6.7, "Products", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 4.5, "Total Amount", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 6.5, "Total Tax", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 4.5, "Grand Total", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 4.5, "Options", 0, fontSize),
      ],
    ),
  );
}

class PurchaseRecordTile extends StatefulWidget {
  int sno;
  double fontSize;
  Function setFile;
  String companyName,
      companyAddress,
      companyPhone,
      companyGST,
      date,
      totalAmount,
      totalTax,
      year,
      month,
      uid,
      grandTotal;
  List products;
  PurchaseRecordTile(
      {super.key,
      required this.fontSize,
      required this.sno,
      required this.companyName,
      required this.setFile,
      required this.companyAddress,
      required this.companyPhone,
      required this.companyGST,
      required this.date,
      required this.year,
      required this.month,
      required this.uid,
      required this.totalAmount,
      required this.totalTax,
      required this.grandTotal,
      required this.products});

  @override
  State<PurchaseRecordTile> createState() => _PurchaseRecordTileState();
}

class _PurchaseRecordTileState extends State<PurchaseRecordTile> {
  @override
  Widget build(BuildContext context) {
    String productsS = "";
    for (var i = 0; i < widget.products.length; i++) {
      productsS += "${widget.products[i]['name']}\n";
    }
    double containerWidth = 40;
    if (widget.fontSize < 15) {
      containerWidth = widget.fontSize * 2;
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorPalette.offWhite.withOpacity(0.4)),
      padding: const EdgeInsets.only(left: 10, right: 10),
      // height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PurchaseRecordHeaderText(
                containerWidth * 1, "${widget.sno + 1}", 1, widget.fontSize),
            PurchaseRecordHeaderTextBold(
                containerWidth * 8.2,
                widget.companyName,
                "GST: ${widget.companyGST}\nPh: ${widget.companyPhone}",
                1,
                widget.fontSize),
            PurchaseRecordHeaderText(
                containerWidth * 3.75, widget.date, 1, widget.fontSize),
            PurchaseRecordHeaderText(
                containerWidth * 6.7, productsS, 1, widget.fontSize),
            PurchaseRecordHeaderText(
                containerWidth * 4.5, widget.totalAmount, 1, widget.fontSize),
            PurchaseRecordHeaderText(
                containerWidth * 6.5, widget.totalTax, 1, widget.fontSize),
            PurchaseRecordHeaderText(
                containerWidth * 4.5, widget.grandTotal, 1, widget.fontSize),
            SizedBox(
              width: containerWidth * 4.5,
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        showEditPurchaseDialog(
                            context: context,
                            year: widget.year,
                            month: widget.month,
                            uid: widget.uid);
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      )),
                  const SizedBox(width: 15),
                  InkWell(
                      onTap: () {
                        deletePurchaseEntry(
                            context: context,
                            year: widget.year,
                            month: widget.month,
                            uid: widget.uid,
                            setFile: widget.setFile);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void deletePurchaseEntry({
  required Function setFile,
  required BuildContext context,
  required String year,
  required String month,
  required String uid,
}) {
  month = month.padLeft(2, "0");
  int tempIndex1 = 0;
  File purchaseRecords = File("Database/Invoices/purchase.json");
  dynamic purchaseRecordContent = purchaseRecords.readAsStringSync();
  purchaseRecordContent = jsonDecode(purchaseRecordContent);
  dynamic subContent = purchaseRecordContent[year][month];
  for (var i = 0; i < subContent.length; i++) {
    var tempKey = subContent[i].keys.toList();
    if (tempKey[0] == uid) {
      tempIndex1 = i;
    }
  }
  purchaseRecordContent[year][month].removeAt(tempIndex1);
  purchaseRecords.writeAsStringSync(jsonEncode(purchaseRecordContent));
  setFile();
}

Widget PurchaseRecordHeaderText(
    double width, String text, int? color, double fontSize) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      style: TextStyle(
          color:
              color == 0 ? Colors.white : const Color.fromARGB(255, 32, 32, 32),
          fontFamily: 'Poppins',
          fontSize: fontSize <= 14 ? fontSize : 14,
          fontWeight: FontWeight.w400),
    ),
  );
}

Widget PurchaseRecordHeaderTextBold(
  double width,
  String heading,
  String text,
  int? color,
  double fontSize,
) {
  return SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
              color: color == 0
                  ? Colors.white
                  : const Color.fromARGB(255, 32, 32, 32),
              fontFamily: 'Poppins',
              fontSize: fontSize < 15 ? fontSize * 1.2 : 15,
              fontWeight: FontWeight.w500),
        ),
        Text(
          text,
          style: TextStyle(
              color: color == 0
                  ? Colors.white
                  : const Color.fromARGB(255, 32, 32, 32),
              fontFamily: 'Poppins',
              fontSize: fontSize < 14 ? fontSize : 14,
              fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}

void showMonthsPurchase(
    {required BuildContext context,
    required Function updateSelectedMonthsinParent,
    required TextEditingController yearController}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: PurchaseMonths(
              year: yearController.text,
              month: "10",
              updateSelectedMonthsinParent: updateSelectedMonthsinParent,
            ));
      });
}

class PurchaseMonths extends StatefulWidget {
  String year;
  String month;
  Function updateSelectedMonthsinParent;
  PurchaseMonths(
      {super.key,
      required this.year,
      required this.month,
      required this.updateSelectedMonthsinParent});

  @override
  State<PurchaseMonths> createState() => _PurchaseMonthsState();
}

class _PurchaseMonthsState extends State<PurchaseMonths> {
  File file = File("Database/Invoices/purchase.json");

  List<String> Months = [
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
    'December'
  ];
  List availableMonths = [];
  dynamic availableMonthsState = {};

  void toggleSelectedMonthState(String month) {
    setState(() {
      availableMonthsState[month] = !availableMonthsState[month];
    });
  }

  @override
  void initState() {
    dynamic purchaseData = file.readAsStringSync();
    purchaseData = jsonDecode(purchaseData);
    List keyss = purchaseData.keys.toList();

    if (keyss.contains(widget.year)) {
      purchaseData = purchaseData[widget.year];

      List availableMonthsInt = purchaseData.keys.toList();
      availableMonthsInt.sort();
      for (var i = 0; i < availableMonthsInt.length; i++) {
        availableMonths.add(Months[int.parse(availableMonthsInt[i]) - 1]);
        if (i == availableMonthsInt.length - 1) {
          availableMonthsState[Months[int.parse(availableMonthsInt[i]) - 1]] =
              true;
        } else {
          availableMonthsState[Months[int.parse(availableMonthsInt[i]) - 1]] =
              false;
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
        ),
        height: 650,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available Months",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 27,
                          fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: const WidgetStatePropertyAll(Colors.white),
                      splashColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        backgroundColor: ColorPalette.offWhite,
                        radius: 18,
                        child: const Icon(Icons.close),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "This is a list of  available months for year ${widget.year} containing Purchase Records. Select from them to show record for each month",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 93, 93, 93),
                      fontFamily: 'Poppins',
                      fontSize: 14),
                ),
                const SizedBox(
                  height: 9,
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                    itemCount: availableMonths.length,
                    shrinkWrap: true,
                    itemBuilder: (c, i) {
                      var value = availableMonthsState[availableMonths[i]];
                      return purchaseMonthCheckbox(
                          value: value,
                          text: availableMonths[i],
                          updateFunction: toggleSelectedMonthState);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(ColorPalette.dark),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)))),
                    onPressed: () {
                      var selectedMonths1 = [];
                      var keys = availableMonthsState.keys.toList();
                      for (var i = 0; i < keys.length; i++) {
                        if (availableMonthsState[keys[i]] == true) {
                          selectedMonths1.add(keys[i]);
                        }
                      }
                      if (selectedMonths1.isEmpty) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                child: Container(
                                    height: 170,
                                    width: 390,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0, horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    "Alert",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 24),
                                                  ),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
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
                                                    "Please Select Atleast One Month To Display Records",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromARGB(
                                                            255, 89, 89, 89),
                                                        fontFamily: 'Poppins'),
                                                  )),
                                            ],
                                          ),
                                          // const SizedBox(
                                          //   height: 30,
                                          // ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                  style: ButtonStyle(
                                                      shape: WidgetStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                      backgroundColor:
                                                          const WidgetStatePropertyAll(
                                                              Color(
                                                                  0xff3049AA))),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 14.0),
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ),
                                    )),
                              );
                            });
                      } else {
                        widget.updateSelectedMonthsinParent(selectedMonths1);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        "Apply",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class purchaseMonthCheckbox extends StatefulWidget {
  String text;
  bool value;
  Function updateFunction;
  purchaseMonthCheckbox(
      {super.key,
      required this.value,
      required this.text,
      required this.updateFunction});

  @override
  State<purchaseMonthCheckbox> createState() => _purchaseMonthCheckboxState();
}

class _purchaseMonthCheckboxState extends State<purchaseMonthCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              widget.updateFunction(month: widget.text);
            });
          },
          child: Checkbox(
              activeColor: ColorPalette.dark,
              value: widget.value,
              onChanged: (v) {
                widget.updateFunction(widget.text);
              }),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          widget.text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3d3d3d)),
        )
      ],
    );
  }
}

void showEditPurchaseDialog({
  required BuildContext context,
  required String year,
  required String month,
  required String uid,
}) {
  showDialog(
      context: (context),
      builder: (c) {
        return EditPurchaseDialog(
          year: year,
          month: month,
          uid: uid,
        );
      });
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

class EditPurchaseDialog extends StatefulWidget {
  String year, month, uid;
  EditPurchaseDialog(
      {super.key, required this.year, required this.month, required this.uid});

  @override
  State<EditPurchaseDialog> createState() => _EditPurchaseDialogState();
}

class _EditPurchaseDialogState extends State<EditPurchaseDialog> {
  late dynamic content;
  late dynamic renderContent;
  late int index;
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();
  TextEditingController companyGSTController = TextEditingController();
  TextEditingController companyContactController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  File tempProducts = File("Database/Invoices/tempPurchase.json");
  @override
  void initState() {
    File db = File("Database/Invoices/purchase.json");
    dynamic tempContentDB = db.readAsStringSync();
    tempContentDB = jsonDecode(tempContentDB);
    widget.month = widget.month.padLeft(2, '0');
    log(widget.year + widget.month);
    List<dynamic> monthRecord = tempContentDB[widget.year][widget.month];
    List<String> monthUID = [];
    for (var i = 0; i < monthRecord.length; i++) {
      String stringWithParentheses = monthRecord[i].keys.toString();
      String stringWithoutParentheses =
          stringWithParentheses.replaceAll(RegExp(r"[\(\)]"), "");
      monthUID.add(stringWithoutParentheses);
    }
    for (var i = 0; i < monthRecord.length; i++) {
      if (monthUID[i] == widget.uid) {
        renderContent = monthRecord[i][monthUID[i]];
        index = i;
      }
    }
    companyNameController.text = renderContent['name'];
    companyAddressController.text = renderContent['address'];
    companyGSTController.text = renderContent['gst'];
    companyContactController.text = renderContent['contact'];
    dateController.text = renderContent['date'];
    // noteController.text = renderContent['name'];
    noteController.text = "";
    dynamic tempPurchaseContent = tempProducts.readAsStringSync();
    tempPurchaseContent = jsonDecode(tempPurchaseContent);
    tempPurchaseContent['items'] = renderContent['products'];
    tempProducts.writeAsStringSync(jsonEncode(tempPurchaseContent));
    super.initState();
  }

  void stateFn() {
    setState(() {
      var temp = File("Database/Invoices/tempPurchase.json");
      tempProducts = temp;
    });
  }

  void removeProduct(index) {
    dynamic fileContent = tempProducts.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List list = fileContent['items'];
    list.removeAt(index);
    Map temp = {"items": list};
    tempProducts.writeAsStringSync(jsonEncode(temp));
    setState(() {
      tempProducts = File('Database/Invoices/tempPurchase.json');
    });
  }

  @override
  Widget build(BuildContext context) {
    content = tempProducts.readAsStringSync();
    content = jsonDecode(content);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: 800,
        width: 1100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 800,
            child: Stack(
              children: [
                SizedBox(
                  height: 660,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Add Purchase Record",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Container(
                            height: 3,
                            width: 290,
                            color: ColorPalette.blueAccent,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          PurchaseDateField(
                              context, dateController, 150, "Date"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NoSuffixTextField(
                                  companyNameController, 490, "Vendor Name"),
                              NoSuffixTextField(
                                  companyGSTController, 490, "GST No.")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  NoSuffixTextField(companyContactController,
                                      490, "Contact No."),
                                  NoSuffixTextField(
                                      noteController, 490, "Additional Note"),
                                ],
                              ),
                              AddressTextField(companyAddressController, 490,
                                  "Company Address")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Products",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 17),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6))),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            Color(0xff3049AA))),
                                onPressed: () {
                                  showPurchaseAddItemDialog(context, stateFn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Add Item",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Poppins",
                                            fontSize: 12),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RowHeader(),
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: content['items'].length,
                              itemBuilder: (c, i) {
                                dynamic temp = content['items'][i];
                                return ProductRow2(
                                    set: () {},
                                    remove: removeProduct,
                                    index: i,
                                    sno: "${i + 1}",
                                    product: temp['name'],
                                    hsn: temp['hsn'],
                                    rate: temp['rate'],
                                    qty: temp['qty']);
                              })
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: EditPurchaseBottomBar(
                      content: content,
                      nameController: companyNameController,
                      gstController: companyGSTController,
                      dateController: dateController,
                      contactController: companyContactController,
                      addressController: companyAddressController,
                      noteController: noteController,
                      uid: '14',
                      index: index,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget PurchaseDateField(
  BuildContext context,
  TextEditingController controller,
  double width,
  String label,
) {
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
      enabled: false,
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 1,
                color: Color.fromARGB(181, 102, 128, 232),
              ),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Color.fromARGB(154, 102, 128, 232),
              ),
              borderRadius: BorderRadius.circular(5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  const BorderSide(color: Color.fromARGB(177, 33, 149, 243))),
          labelText: label, // This will act as the floating label
          labelStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xff6681e8),
              fontWeight: FontWeight.w600),
          // This will act as the hint text
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffixIcon: GestureDetector(
              onTap: () async {
                controller.text = await date(context);
              },
              child: const Icon(Icons.arrow_drop_down))),
    ),
  );
}
