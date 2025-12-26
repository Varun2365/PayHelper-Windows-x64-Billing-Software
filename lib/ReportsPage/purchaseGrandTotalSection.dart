// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'dart:io';

import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:flutter/material.dart';

class PurchaseBottomBar extends StatefulWidget {
  dynamic content;
  TextEditingController nameController,
      gstController,
      dateController,
      contactController,
      addressController,
      noteController;
  PurchaseBottomBar(
      {super.key,
      required this.content,
      required this.nameController,
      required this.gstController,
      required this.dateController,
      required this.contactController,
      required this.addressController,
      required this.noteController});

  @override
  State<PurchaseBottomBar> createState() => PurchaseBottomBarState();
}

class PurchaseBottomBarState extends State<PurchaseBottomBar> {
  double totalAmount = 0, totalTax = 0, grandTotal = 0;
  String totalAmountF = "", totalTaxF = "", grandTotalF = "";
  void setParams(content) {
    totalAmount = 0;
    totalTax = 0;
    grandTotal = 0;
    totalAmountF = "";
    totalTaxF = "";
    grandTotalF = "";
    for (var i = 0; i < content['items'].length; i++) {
      totalAmount +=
          convertIndianFormattedStringToNumber(content['items'][i]['amount']);
      grandTotal += convertIndianFormattedStringToNumber(
          content['items'][i]['grandTotal']);
      totalTax += content['items'][i]['tax'] *
          convertIndianFormattedStringToNumber(content['items'][i]['amount']) *
          0.01;
    }
    totalAmountF = makeFullDouble(formatIntegerToIndian(totalAmount));
    grandTotalF = makeFullDouble(formatIntegerToIndian(grandTotal));
    totalTaxF = makeFullDouble(formatIntegerToIndian(totalTax));
  }

  @override
  Widget build(BuildContext context) {
    setParams(widget.content);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color.fromARGB(42, 56, 56, 56),
            blurRadius: 2,
            offset: Offset(0, -2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      height: 140,
      width: 1100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Total Amount:      ₹${makeFullDouble(totalAmountF)}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: ColorPalette.dark),
          ),
          Text(
            "Total Tax:      ₹${makeFullDouble(totalTaxF)}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: ColorPalette.dark),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(ColorPalette.dark),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)))),
                  onPressed: () {
                    if (widget.nameController.text == "" ||
                        widget.contactController.text == "" ||
                        widget.dateController.text == "" ||
                        widget.addressController.text == "" ||
                        widget.gstController.text == "") {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              child: Container(
                                  height: 170,
                                  width: 380,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                                  "Please Enter Required  Fields (Name, GST, Contact, Address, Date)",
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
                                                            Color(0xff3049AA))),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
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
                      File purchase = File('Database/Invoices/purchase.json');
                      File uniqueId = File("Database/Invoices/uniqueid.txt");
                      File purchaseParties =
                          File("Database/Party Records/purchaseParties.json");
                      dynamic parties = purchaseParties.readAsStringSync();
                      parties = jsonDecode(parties);
                      dynamic ui = uniqueId.readAsStringSync();
                      dynamic content = purchase.readAsStringSync();
                      content = jsonDecode(content);
                      File temp = File('Database/Invoices/tempPurchase.json');
                      dynamic tpContent = temp.readAsStringSync();
                      tpContent = jsonDecode(tpContent);
                      String date = widget.dateController.text.split('/')[0];
                      String month = widget.dateController.text.split('/')[1];
                      String year = widget.dateController.text.split('/')[2];
                      date.length == 1 ? date = "0$date" : date = date;
                      month.length == 1 ? month = "0$month" : month = month;
                      year.length == 1 ? year = "0$year" : year = year;
                      // ignore: unused_local_variable
                      dynamic tempContent = {
                        ui: {
                          'date': widget.dateController.text,
                          'name': widget.nameController.text,
                          'contact': widget.contactController.text,
                          'gst': widget.gstController.text,
                          'address': widget.addressController.text,
                          'products': tpContent['items'],
                          'totalTax': totalTaxF,
                          'totalAmount': totalAmountF,
                          'grandTotal': grandTotalF
                        }
                      };

                      dynamic partyContent = {
                        widget.nameController.text: {
                          'name': widget.nameController.text,
                          'contact': widget.contactController.text,
                          'address': widget.addressController.text,
                          'gst': widget.gstController.text,
                          'products': []
                        }
                      };
                      if (parties.keys
                          .toList()
                          .contains(widget.nameController.text)) {
                      } else {
                        parties[widget.nameController.text] = partyContent;
                        purchaseParties.writeAsStringSync(jsonEncode(parties));
                      }
                      if (content[year] == null) {
                        content[year] = {};
                      }
                      if (content[year][month] == null) {
                        content[year][month] = [];
                      }

                      content[year][month].add(tempContent);
                      purchase.writeAsString(jsonEncode(content));
                      ui = int.parse(ui);
                      ++ui;
                      uniqueId.writeAsStringSync(ui.toString());
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 17.0, vertical: 8),
                    child: Text("Save Changes",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      overlayColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 5),
                    child: Text("Cancel",
                        style: TextStyle(color: ColorPalette.dark)),
                  ),
                ),
              ]),
              Text(
                "Grand Total:    ₹${makeFullDouble(grandTotalF)}",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.dark),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class EditPurchaseBottomBar extends StatefulWidget {
  dynamic content;
  String uid;
  int index;
  TextEditingController nameController,
      gstController,
      dateController,
      contactController,
      addressController,
      noteController;
  EditPurchaseBottomBar(
      {super.key,
      required this.uid,
      required this.index,
      required this.content,
      required this.nameController,
      required this.gstController,
      required this.dateController,
      required this.contactController,
      required this.addressController,
      required this.noteController});

  @override
  State<EditPurchaseBottomBar> createState() => EditPurchaseBottomBarState();
}

class EditPurchaseBottomBarState extends State<EditPurchaseBottomBar> {
  double totalAmount = 0, totalTax = 0, grandTotal = 0;
  String totalAmountF = "", totalTaxF = "", grandTotalF = "";
  void setParams(content) {
    totalAmount = 0;
    totalTax = 0;
    grandTotal = 0;
    totalAmountF = "";
    totalTaxF = "";
    grandTotalF = "";
    for (var i = 0; i < content['items'].length; i++) {
      totalAmount +=
          convertIndianFormattedStringToNumber(content['items'][i]['amount']);
      grandTotal += convertIndianFormattedStringToNumber(
          content['items'][i]['grandTotal']);
      totalTax += content['items'][i]['tax'] *
          convertIndianFormattedStringToNumber(content['items'][i]['amount']) *
          0.01;
    }
    totalAmountF = formatIntegerToIndian(totalAmount);
    grandTotalF = formatIntegerToIndian(grandTotal);
    totalTaxF = formatIntegerToIndian(totalTax);
  }

  @override
  Widget build(BuildContext context) {
    setParams(widget.content);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color.fromARGB(42, 56, 56, 56),
            blurRadius: 2,
            offset: Offset(0, -2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      height: 140,
      width: 1100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Total Amount:      ₹${makeFullDouble(totalAmountF)}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: ColorPalette.dark),
          ),
          Text(
            "Total Tax:      ₹${makeFullDouble(totalTaxF)}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: ColorPalette.dark),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(ColorPalette.dark),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)))),
                  onPressed: () {
                    if (widget.nameController.text == "" ||
                        widget.contactController.text == "" ||
                        widget.dateController.text == "" ||
                        widget.addressController.text == "" ||
                        widget.gstController.text == "") {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              child: Container(
                                  height: 170,
                                  width: 380,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                                  "Please Enter Required  Fields (Name, GST, Contact, Address, Date)",
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
                                                            Color(0xff3049AA))),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
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
                      File purchase = File('Database/Invoices/purchase.json');
                      File uniqueId = File("Database/Invoices/uniqueid.txt");
                      File purchaseParties =
                          File("Database/Party Records/purchaseParties.json");
                      dynamic parties = purchaseParties.readAsStringSync();
                      parties = jsonDecode(parties);
                      dynamic ui = uniqueId.readAsStringSync();
                      dynamic content = purchase.readAsStringSync();
                      content = jsonDecode(content);
                      File temp = File('Database/Invoices/tempPurchase.json');
                      dynamic tpContent = temp.readAsStringSync();
                      tpContent = jsonDecode(tpContent);
                      String date = widget.dateController.text.split('/')[0];
                      String month = widget.dateController.text.split('/')[1];
                      String year = widget.dateController.text.split('/')[2];
                      date.length == 1 ? date = "0$date" : date = date;
                      month.length == 1 ? month = "0$month" : month = month;
                      year.length == 1 ? year = "0$year" : year = year;
                      // ignore: unused_local_variable
                      dynamic tempContent = {
                        widget.uid: {
                          'date': widget.dateController.text,
                          'name': widget.nameController.text,
                          'contact': widget.contactController.text,
                          'gst': widget.gstController.text,
                          'address': widget.addressController.text,
                          'products': tpContent['items'],
                          'totalTax': totalTaxF,
                          'totalAmount': totalAmountF,
                          'grandTotal': grandTotalF
                        }
                      };

                      if (content[year] == null) {
                        content[year] = {};
                      }
                      if (content[year][month] == null) {
                        content[year][month] = [];
                      }

                      content[year][month][widget.index] = tempContent;
                      purchase.writeAsString(jsonEncode(content));
                      ui = int.parse(ui);
                      ++ui;
                      uniqueId.writeAsStringSync(ui.toString());
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
                    child: Text("Save Changes",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)))),
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 5),
                    child: Text("Cancel",
                        style: TextStyle(color: ColorPalette.dark)),
                  ),
                ),
              ]),
              Text(
                "Grand Total:    ₹${makeFullDouble(grandTotalF)}",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.dark),
              ),
            ],
          )
        ],
      ),
    );
  }
}
