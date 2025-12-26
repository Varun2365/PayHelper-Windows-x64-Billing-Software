// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:billing/InvoicesPageSection/InvoiesPageFiles/InvoiceDefaults.dart';
import 'package:billing/InvoicesPageSection/InvoiesPageFiles/MonthCheckBox.dart';
import 'package:billing/NavBar/LargeNavbar.dart';
import 'package:billing/New%20Features/PostInvoiceCreationFeatures.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/savePDF.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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
  'December',
];

class InvoicePageLarge extends StatefulWidget {
  const InvoicePageLarge({super.key});

  @override
  State<InvoicePageLarge> createState() => _InvoicePageLargeState();
}

class _InvoicePageLargeState extends State<InvoicePageLarge> {
  List selectedMonths = [Months[int.parse(InvoiceDefaults.defaultMonth) - 1]];
  String searchKey = "";
  bool validMonth = false;
  
  // Helper function to validate if selected months exist in the data
  void validateSelectedMonths(String year) {
    File invoices = File("Database/Invoices/In.json");
    dynamic invoicesContent = invoices.readAsStringSync();
    invoicesContent = jsonDecode(invoicesContent);
    dynamic content = invoicesContent[year.toString()];
    
    if (content != null && selectedMonths.isNotEmpty) {
      List availableMonths = content.keys.toList();
      bool hasValidMonth = false;
      
      for (var i = 0; i < selectedMonths.length; i++) {
        String monthNumber = (Months.indexOf(selectedMonths[i]) + 1)
            .toString()
            .padLeft(2, '0');
        if (availableMonths.contains(monthNumber)) {
          hasValidMonth = true;
          break;
        }
      }
      
      setState(() {
        validMonth = hasValidMonth;
      });
    } else {
      setState(() {
        validMonth = false;
      });
    }
  }
  
  void updateSelectedMonths(List l) {
    setState(() {
      selectedMonths = l;
    });
    // Validate the newly selected months
    validateSelectedMonths(selectedYear);
  }

  void setAvailableMonths(selectedYear) {
    File invoices = File("Database/Invoices/In.json");
    dynamic invoicesContent = invoices.readAsStringSync();
    invoicesContent = jsonDecode(invoicesContent);
    dynamic content = invoicesContent[selectedYear.toString()];
    if (content != null) {
      List availableMonths = content.keys.toList();

      List availableMonths1 = [];
      for (var i = 0; i < availableMonths.length; i++) {
        availableMonths1.add(int.parse(availableMonths[i]));
      }
      availableMonths1.sort();

      List tempList = [];
      for (var i = 0; i < availableMonths1.length; i++) {
        tempList.add(Months[availableMonths1[i] - 1]);
      }

      tempList = tempList.reversed.toList();

      setState(() {
        selectedMonths = tempList;
      });
      
      // Validate the updated months after setting them
      validateSelectedMonths(selectedYear);
    } else {
      setState(() {
        selectedMonths = [];
        validMonth = false;
      });
    }
  }

  void changeFile() {
    setState(() {
      invoiceContent = Invoices.readAsStringSync();
      invoiceContent = jsonDecode(invoiceContent);
    });
  }


  late dynamic invoiceContent;
  String selectedYear = InvoiceDefaults.defaultYear;
  TextEditingController YearController =
      TextEditingController(text: InvoiceDefaults.defaultYear);
  TextEditingController MonthController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  File textSize = File("Database/Firm/firmDetails.json");
  List<DropdownMenuEntry<dynamic>> drop = [];
  List<DropdownMenuEntry<dynamic>> monthsMenu = [];
  File Invoices = File("Database/Invoices/In.json");
  void showMonths(String year) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: MonthCheckBox(
                year: year,
                HeadingSize: HeadingSize,
                selectedMonths: updateSelectedMonths,
                selected: selectedMonths,
              ));
        });
  }

  late int fontSize;
  late double HeadingSize, HeadingSize2, paraSize;
  void initializeSettings() {
    MonthController.text = Months[int.parse(InvoiceDefaults.defaultMonth) - 1];
    invoiceContent = Invoices.readAsStringSync();
    invoiceContent = jsonDecode(invoiceContent);
    List keys = invoiceContent.keys.toList();
    keys.sort();
    log(invoiceContent.keys.toList().toString());
    if (keys.contains(selectedYear)) {
      List months = invoiceContent[selectedYear].keys.toList();
      months.sort();
      for (var i = 0; i < months.length; i++) {
        monthsMenu.add(DropdownMenuEntry(
            value: months[i], label: Months[int.parse(months[i]) - 1]));
      }
      keys = keys.reversed.toList();
      for (var i = 0; i < keys.length; i++) {
        drop.add(DropdownMenuEntry(value: keys[i], label: keys[i]));
      }
    } else {
      log("Year for Invoice Details Not Present in the database.");
    }
    dynamic fileContent = textSize.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    fontSize = int.parse(fileContent['FontSize']);
    HeadingSize = 1.7 * fontSize;
    HeadingSize2 = 0.9 * fontSize;
    paraSize = 0.8 * fontSize;
  }

  @override
  void initState() {
    initializeSettings();
    setAvailableMonths(selectedYear);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(validMonth.toString());
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
      padding: const EdgeInsets.only(top: 38, right: 40, left: 40, bottom: 30),
      color: ColorPalette.offWhite.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: const Color.fromARGB(40, 0, 0, 0),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: ColorPalette.offWhite.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "All ",
                            style: TextStyle(
                                fontSize: fontSize * 1.8,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy',
                                color: ColorPalette.darkBlue,
                                letterSpacing: -0.5)),
                        TextSpan(
                            text: "Invoices",
                            style: TextStyle(
                                fontSize: fontSize * 1.8,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy',
                                color: ColorPalette.blueAccent,
                                letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Filters and Search Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorPalette.offWhite.withOpacity(0.8),
                              width: 1,
                            ),
                            color: ColorPalette.offWhite.withOpacity(0.2),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (v) {
                              setState(() {
                                searchKey = v;
                              });
                            },
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: paraSize,
                              color: ColorPalette.darkBlue,
                            ),
                            decoration: InputDecoration(
                                suffixIcon: searchKey.isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          searchController.clear();
                                          setState(() {
                                            searchKey = "";
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.grey.shade600,
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    : null,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ),
                                hintText: "Search by party name...",
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: paraSize,
                                  color: Colors.grey.shade500,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: ColorPalette.blueAccent,
                                      width: 1.5,
                                    )),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Filters Section
                      Row(
                        children: [
                          // Financial Year Filter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorPalette.offWhite.withOpacity(0.8),
                                width: 1,
                              ),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Year",
                                  style: TextStyle(
                                      fontSize: HeadingSize2 * 0.9,
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w500,
                                      color: ColorPalette.darkBlue),
                                ),
                                const SizedBox(width: 12),
                                DropdownMenu(
                                    textStyle: TextStyle(
                                        fontSize: paraSize,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: ColorPalette.darkBlue),
                                    trailingIcon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    onSelected: (value) {
                                      setState(() {
                                        selectedMonths.clear();
                                        selectedYear = value.toString();
                                      });
                                      setAvailableMonths(selectedYear);
                                    },
                                    inputDecorationTheme: InputDecorationTheme(
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                    controller: YearController,
                                    width: 120,
                                    dropdownMenuEntries: drop),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Month Filter
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorPalette.offWhite.withOpacity(0.8),
                                width: 1,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                showMonths(selectedYear);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Month",
                                      style: TextStyle(
                                          fontSize: HeadingSize2 * 0.9,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w500,
                                          color: ColorPalette.darkBlue),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      selectedMonths.length == 1
                                          ? selectedMonths[0]
                                          : selectedMonths.isEmpty
                                              ? "Select"
                                              : "${selectedMonths.length} Selected",
                                      style: TextStyle(
                                          fontSize: paraSize,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: selectedMonths.isEmpty
                                              ? Colors.grey.shade500
                                              : ColorPalette.darkBlue),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Table Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 14),
              child: InvoiceRecordHeader(fontSize),
            ),
            // Invoice List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: selectedMonths.isEmpty || !validMonth
                    ? nullRecord()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        itemCount: selectedMonths.length,
                        itemBuilder: (BuildContext c, int i) {
                          return InvoiceBuider(
                              searchKey: searchKey,
                              context: context,
                              fn: changeFile,
                              month: (Months.indexOf(selectedMonths[i]) + 1)
                                  .toString(),
                              year: selectedYear,
                              content: invoiceContent,
                              fontSize: fontSize);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool hasSequentialMatch(String searchString, String mainString) {
  if (searchString.isEmpty) {
    return true; // Empty search string matches anything
  }
  if (mainString.isEmpty || searchString.length > mainString.length) {
    return false; // Main string is too short
  }

  searchString = searchString.toLowerCase();
  mainString = mainString.toLowerCase();

  for (int i = 0; i <= mainString.length - searchString.length; i++) {
    if (mainString.substring(i, i + searchString.length) == searchString) {
      return true;
    }
  }

  return false;
}

Widget nullRecord() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: SvgPicture.asset("assets/images/norecord.svg"),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "No Data Found, Please Select a Valid Year and Month",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        )
      ],
    ),
  );
}

Widget nullRecord2() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: SvgPicture.asset("assets/images/noPurchase.svg"),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "No Data Found, Please Select a Valid Year and Month",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        )
      ],
    ),
  );
}

Widget nullRecord3() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: SvgPicture.asset("assets/images/noProducts.svg"),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "No Products Found",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        )
      ],
    ),
  );
}

Widget nullRecord4() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: SvgPicture.asset("assets/images/noParty.svg"),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "No Parties Found",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        )
      ],
    ),
  );
}

Widget InvoiceRecordHeader(double fontSize) {
  double containerWidth = 40;
  if (fontSize <= 15) {
    containerWidth = fontSize * 2;
  }
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            ColorPalette.blueAccent,
            ColorPalette.blueAccent.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.blueAccent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ]),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InvoiceRecordHeaderText(containerWidth * 1.3, "S.No.", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 7, "Party Name", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 7, "Party Address", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 5, "GST No.", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 4, "Date", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 6, "Description", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 4, "Grand Total", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 4, "Options", 0, fontSize),
      ],
    ),
  );
}

Widget InvoiceRecordHeader2(
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
    required String grandTotal,
    required double fontSize}) {
  int color = 1;
  double containerWidth = 40;
  if (fontSize <= 15) {
    containerWidth = fontSize * 2;
  }
  String currentDirectory = Directory.current.path;
  return Column(
    children: [
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: index % 2 == 0
              ? ColorPalette.offWhite.withOpacity(0.2)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InvoiceRecordHeaderText2(
                containerWidth * 1.3, sno, color, fontSize),
            InvoiceRecordHeaderText2(
                containerWidth * 7, partyName, color, fontSize),
            InvoiceRecordHeaderText2(
                containerWidth * 7, partyAddress, color, fontSize),
            InvoiceRecordHeaderText2(containerWidth * 5, gst, color, fontSize),
            InvoiceRecordHeaderText2(containerWidth * 4, date, color, fontSize),
            InvoiceRecordHeaderText2(containerWidth * 6, desc, color, fontSize),
            InvoiceRecordHeaderText2(
                containerWidth * 4, grandTotal, color, fontSize),
            Container(
              width: containerWidth * 4,
              height: 70,
              color: Colors.transparent,
              child: Wrap(
                runSpacing: 15,
                // mainAxisAlignment: MainAxisAlignment.start,
                direction: Axis.horizontal,
                spacing: 13,
                alignment: WrapAlignment.start,
                children: [
                  Row(
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
                      InkWell(
                        onTap: () async {
                          try {
                            // Generate and save the PDF (this will create or overwrite the file)
                            // Pass showDialog: false to suppress the success dialog
                            String pdfPath = '$currentDirectory\\Database\\PDF';
                            await savePDF2(year, month, sno, pdfPath, context, showSuccessDialog: false);

                            // Then, launch the PDF using UrlLauncherPlatform.
                            final String fullPdfPath =
                                '$currentDirectory\\Database\\PDF\\Bill No.$sno $partyName.pdf';
                            bool launched =
                                await UrlLauncherPlatform.instance.launch(
                              fullPdfPath,
                              useSafariVC: false,
                              useWebView: false,
                              enableJavaScript: true,
                              enableDomStorage: true,
                              universalLinksOnly: false,
                              headers: <String, String>{},
                            );

                            if (!launched) {
                              // Handle cases where the URL couldn't be launched (e.g., no PDF viewer installed)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Could not open the PDF at $fullPdfPath')),
                              );
                            }
                          } catch (e) {
                            // Catch any errors during the save or launch process
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error generating or opening PDF: $e')),
                            );
                          }
                        },
                        child: const Tooltip(
                          message: "Open In Browser",
                          child: Icon(
                            Icons.open_in_new,
                            color: Colors.pink,
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            showQR(
                                context,
                                convertIndianFormattedStringToNumber(
                                    grandTotal));
                          },
                          child: const Tooltip(
                              message: "Show Payment QR",
                              child: Icon(
                                Icons.qr_code_rounded,
                                color: Color.fromARGB(255, 48, 48, 48),
                              ))),
                      const SizedBox(width: 15),
                      InkWell(
                          onTap: () {
                            // saveFile2(context, year, month, sno);
                            showPostInvoiceCreationFeaturesInvoice(
                                context, saveFile2, year, month, sno);
                          },
                          child: const Tooltip(
                              message: "Save to Device",
                              child: Icon(
                                Icons.save,
                                color: Colors.blue,
                              ))),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ],
  );
}

Widget InvoiceRecordHeaderText(
  double width,
  String text,
  int? color,
  double fontSize,
) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      style: TextStyle(
          fontSize: fontSize <= 15 ? fontSize : 15,
          color: color == 0 ? Colors.white : Colors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.3),
    ),
  );
}

Widget PurchaseRecordHeaderText(
  double width,
  String text,
  int? color,
) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      style: TextStyle(
          color: color == 0 ? Colors.white : Colors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500),
    ),
  );
}

Widget InvoiceRecordHeaderText3(
  double width,
  String text,
  int? color,
) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      style: TextStyle(
          color:
              color == 0 ? Colors.white : const Color.fromARGB(255, 38, 38, 38),
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w400),
    ),
  );
}

Widget InvoiceRecordHeaderText4(
  double width,
  String text,
  String text2,
  int? color,
) {
  return SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              color: color == 0
                  ? Colors.white
                  : const Color.fromARGB(255, 43, 43, 43),
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text2,
          style: TextStyle(
              color: color == 0
                  ? Colors.white
                  : const Color.fromARGB(255, 38, 38, 38),
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}

Widget InvoiceRecordHeaderText2(
    double width, String text, int? color, double fontSize) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      style: TextStyle(
          fontSize: fontSize <= 15 ? 12.5 : 13.5,
          color:
              color == 0 ? Colors.white : const Color.fromARGB(255, 45, 45, 45),
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0.1),
    ),
  );
}

Widget InvoiceBuider(
    {required BuildContext context,
    required String searchKey,
    required String month,
    required Function fn,
    required String year,
    required dynamic content,
    required double fontSize}) {
  dynamic renderContent = {};
  List keys = [];
  if (month.length == 1) {
    month = "0$month";
  }
  List keyss = content[year].keys.toList();
  List<Widget> monthInvoiceList = [];
  bool showAll = searchKey.trim().isEmpty;

  if (keyss.contains(month)) {
    renderContent = content[year][month];
    keys = renderContent.keys.toList();
    keys = keys.reversed.toList();

    List<Widget> invoiceRecords = [];
    for (var i = 0; i < keys.length; i++) {
      String desc = "";
      List products = renderContent[keys[i]]["Products"];
      for (var j = 0; j < products.length; j++) {
        desc = "${desc + products[j]["name"]}\n";
      }
      if (showAll ||
          hasSequentialMatch(
              searchKey, renderContent[keys[i]]["BillingName"])) {
        invoiceRecords.add(InvoiceRecordHeader2(
            month: month,
            year: year,
            fn: fn,
            context: context,
            index: i,
            sno: keys[i].toString(),
            partyName: renderContent[keys[i]]["BillingName"],
            partyAddress: renderContent[keys[i]]["BillingAdd"],
            gst: renderContent[keys[i]]["BillingGST"],
            date: renderContent[keys[i]]["Date"],
            desc: desc,
            grandTotal: renderContent[keys[i]]["grandtotal"],
            fontSize: fontSize));
      }
    }

    if (invoiceRecords.isNotEmpty) {
      monthInvoiceList.add(const SizedBox(height: 24));
      monthInvoiceList.add(Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [
                    ColorPalette.blueAccent,
                    ColorPalette.blueAccent.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "${Months[int.parse(month) - 1]} Invoices",
              style: TextStyle(
                color: ColorPalette.darkBlue,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ));
      monthInvoiceList.addAll(invoiceRecords);
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: monthInvoiceList,
  );
}

void showQR(BuildContext context, double amount) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      File firmSettings = File("Database/Firm/firmDetails.json");
      dynamic firm = firmSettings.readAsStringSync();
      firm = jsonDecode(firm);
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 480,
          width: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 29,
                      ))
                ],
              ),
              Expanded(
                child: Center(
                  child: QrImageView(
                    gapless: false,
                    eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square, color: Color(0xff3049AA)),
                    dataModuleStyle: const QrDataModuleStyle(
                        color: Color(0xff3049AA),
                        dataModuleShape: QrDataModuleShape.square),
                    data:
                        "upi://pay?pa=${firm['QRUPI']}&pn=${firm['QRName']}&am=$amount",
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Name: ${firm['QRName']}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'),
              ),
              Text(
                "UPI ID: ${firm['QRUPI']}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'),
              ),
              Text(
                "Amount: $amount",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    },
  );
}

