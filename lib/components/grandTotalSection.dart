// ignore_for_file: file_names, must_be_immutable, non_constant_identifier_names, duplicate_ignore, use_build_context_synchronously

// ignore: unused_import
import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/New%20Features/PostInvoiceCreationFeatures.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/pdfGenerator.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GrandTotalSection extends StatefulWidget {
  File file;
  Function onFileChange;
  Function clear;
  bool igst;
  bool check;
  int taxRate;
  TextEditingController nameController,
      GSTController,
      partyController,
      ShippingController,
      InvoiceController,
      DateController,
      GRController,
      TransportController,
      VehicleController,
      stationController,
      addressController,
      ContactController,
      POController,
      EWayController;

  GrandTotalSection({
    super.key,
    required this.igst,
    required this.taxRate,
    required this.ContactController,
    required this.file,
    required this.clear,
    required this.check,
    required this.onFileChange,
    required this.GSTController,
    required this.nameController,
    required this.addressController,
    required this.partyController,
    required this.ShippingController,
    required this.InvoiceController,
    required this.DateController,
    required this.GRController,
    required this.TransportController,
    required this.VehicleController,
    required this.stationController,
    required this.POController,
    required this.EWayController,
  });

  @override
  State<GrandTotalSection> createState() => _GrandTotalSectionState();
}

class _GrandTotalSectionState extends State<GrandTotalSection> {
  File fd = File("Database/Firm/firmDetails.json");
  late dynamic firmDetails;
  //Functions
  void showQR(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                          eyeShape: QrEyeShape.square,
                          color: Color(0xff3049AA)),
                      dataModuleStyle: const QrDataModuleStyle(
                          color: Color(0xff3049AA),
                          dataModuleShape: QrDataModuleShape.square),
                      data:
                          "upi://pay?pa=${firmDetails['QRUPI']}&pn=${firmDetails['QRName']}&am=$amount",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Name: ${firmDetails['QRName']}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
                Text(
                  "UPI ID: ${firmDetails['QRUPI']}",
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

  TextStyle lightStyle = const TextStyle(
      color: Color(0xff3049AA),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins');
  TextStyle lightStyle2 = const TextStyle(
      color: Color(0xff3049AA),
      fontSize: 17,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins');
  TextStyle boldStyle = const TextStyle(
      color: Color(0xff3049AA), fontSize: 16, fontWeight: FontWeight.w700);
  TextStyle boldStyle2 = const TextStyle(
      color: Color(0xff3049AA), fontSize: 20, fontWeight: FontWeight.w700);
  late String totalAmount;

  late dynamic sgst;
  late dynamic cgst;
  late dynamic igstV;
  late dynamic grandTotal;
  dynamic totalTax;

  @override
  void initState() {
    firmDetails = fd.readAsStringSync();
    firmDetails = jsonDecode(firmDetails);
    super.initState();
  }

  void savePDF() {}
  @override
  Widget build(BuildContext context) {
    File tempInvoice = widget.file;
    dynamic fileContent = tempInvoice.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List items = fileContent['items'];
    dynamic sum = 0;
    for (var i = 0; i < items.length; i++) {
      sum += convertIndianFormattedStringToNumber(items[i]['amount']);
    }
    sum = sum.toStringAsFixed(2);
    sum = double.parse(sum);
    igstV = sum * (widget.taxRate / 100);
    igstV = igstV.toStringAsFixed(2);
    igstV = formatIntegerToIndian(double.parse(igstV));
    sgst = sum * (widget.taxRate / 200);
    cgst = sgst;

    cgst = double.parse(cgst.toStringAsFixed(2));
    sgst = double.parse(sgst.toStringAsFixed(2));
    dynamic grandTotal = sgst + cgst + sum;
    grandTotal = formatIntegerToIndian(grandTotal);
    String totalTax = formatIntegerToIndian(cgst + sgst);
    totalTax = makeFullDouble(totalTax);
    cgst = formatIntegerToIndian(cgst);
    sgst = cgst;
    totalAmount = formatIntegerToIndian(sum);
    void savePDF() async {
      if (widget.partyController.text == "" ||
          widget.addressController.text == "" ||
          items.isEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                    height: 170,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13.0, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Alert",
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
                                    "Please Enter Party Name , Address and Products",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 14,
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
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                              Color(0xff3049AA))),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 14.0),
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
      } else {
        await WritePDFContent(
            igstV: makeFullDouble(igstV),
            poController: widget.POController,
            partyController: widget.partyController,
            DateController: widget.DateController,
            nameController: widget.nameController,
            GSTController: widget.GSTController,
            InvoiceController: widget.InvoiceController,
            GRController: widget.GRController,
            contactController: widget.ContactController,
            TransportController: widget.TransportController,
            stationController: widget.stationController,
            VehicleController: widget.VehicleController,
            EWayController: widget.EWayController,
            ShippingController: widget.check
                ? widget.addressController
                : widget.ShippingController,
            place: widget.ShippingController,
            cgst: widget.igst ? makeFullDouble(igstV) : makeFullDouble(cgst),
            sgst: widget.igst ? "" : makeFullDouble(sgst),
            grandTotal: makeFullDouble(grandTotal),
            TaxAmount: makeFullDouble(formatIntegerToIndian(sum)),
            TotalTax: totalTax,
            grandTotalInWords: convertToIndianCurrencyWords(
                convertIndianFormattedStringToNumber(grandTotal)),
            igst: widget.igst,
            TaxRate: "${widget.taxRate}%",
            productList: items);
        File parties = File("Database/Party Records/parties.json");
        dynamic partyContent = jsonDecode(parties.readAsStringSync());

        Map content = {
          "name": widget.partyController.text,
          "gst": widget.GSTController.text,
          "contact": widget.ContactController.text,
          "address": widget.addressController.text,
          "note": ""
        };
        partyContent[widget.partyController.text] = content;
        parties.writeAsStringSync(jsonEncode(partyContent));
        await generatePDF();
        AddInvoice(
            onFileChange: widget.onFileChange,
            igstV: makeFullDouble(igstV),
            poController: widget.POController,
            partyController: widget.partyController,
            DateController: widget.DateController,
            nameController: widget.nameController,
            GSTController: widget.GSTController,
            InvoiceController: widget.InvoiceController,
            GRController: widget.GRController,
            contactController: widget.ContactController,
            TransportController: widget.TransportController,
            stationController: widget.stationController,
            VehicleController: widget.VehicleController,
            EWayController: widget.EWayController,
            ShippingController: widget.check
                ? widget.addressController
                : widget.ShippingController,
            place: widget.ShippingController,
            cgst: widget.igst ? makeFullDouble(igstV) : makeFullDouble(cgst),
            sgst: widget.igst ? "" : makeFullDouble(sgst),
            grandTotal: makeFullDouble(grandTotal),
            TaxAmount: makeFullDouble(formatIntegerToIndian(sum)),
            TotalTax: totalTax,
            grandTotalInWords: convertToIndianCurrencyWords(
                convertIndianFormattedStringToNumber(grandTotal)),
            igst: widget.igst,
            TaxRate: "${widget.taxRate}%",
            productList: items);
        AddInvoiceRecord(
            onFileChange: widget.onFileChange,
            igstV: makeFullDouble(igstV),
            partyController: widget.partyController,
            poController: widget.POController,
            DateController: widget.DateController,
            nameController: widget.nameController,
            GSTController: widget.GSTController,
            InvoiceController: widget.InvoiceController,
            GRController: widget.GRController,
            contactController: widget.ContactController,
            TransportController: widget.TransportController,
            stationController: widget.stationController,
            VehicleController: widget.VehicleController,
            EWayController: widget.EWayController,
            ShippingController: widget.check
                ? widget.addressController
                : widget.ShippingController,
            place: widget.ShippingController,
            cgst: widget.igst ? makeFullDouble(igstV) : makeFullDouble(cgst),
            sgst: widget.igst ? "" : makeFullDouble(sgst),
            grandTotal: makeFullDouble(grandTotal),
            TaxAmount: makeFullDouble(formatIntegerToIndian(sum)),
            TotalTax: totalTax,
            grandTotalInWords: convertToIndianCurrencyWords(
                convertIndianFormattedStringToNumber(grandTotal)),
            igst: widget.igst,
            TaxRate: "${widget.taxRate}%",
            productList: items);
        Future.delayed(const Duration(seconds: 1), () {
          widget.onFileChange();
        });
        // Navigator.of(context).pop();
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grand Total In Words",
                      style: boldStyle,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      "${convertToIndianCurrencyWords(convertIndianFormattedStringToNumber(grandTotal))} Only",
                      style: lightStyle2,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Total Amount:     ₹ ${makeFullDouble(totalAmount)}",
                  style: lightStyle,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  widget.igst
                      ? "IGST(${widget.taxRate}%):     ₹${makeFullDouble(igstV)}"
                      : "CGST(${widget.taxRate / 2}%):     ₹ ${makeFullDouble(cgst)}",
                  style: lightStyle,
                ),
                const SizedBox(
                  height: 3,
                ),
                Container(
                  child: widget.igst
                      ? const SizedBox()
                      : Text(
                          "SGST(${widget.taxRate / 2}%):     ₹ ${makeFullDouble(sgst)}",
                          style: lightStyle,
                        ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "Grand Total:     ₹ ${makeFullDouble(grandTotal)}",
                  style: boldStyle2,
                ),
              ],
            )
          ],
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                        text: "Show Payment QR",
                        onPressed: () {
                          showQR(context,
                              convertIndianFormattedStringToNumber(grandTotal));
                          // saveSignatureFile();
                        },
                        dark: false),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                        text: "Reset Form",
                        onPressed: widget.clear,
                        dark: false),
                  ],
                ),
                // OutlinedButton(
                //     text: "Delete Invoice",
                //     onPressed: () {

                //     },
                //     dark: false),
                OutlinedButton(
                    text: "Save As PDF",
                    onPressed: () async {
                      showPostInvoiceCreationFeatures(context, savePDF);
                      // savePDF();
                    },
                    dark: true),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ],
    );
  }
}

// ignore: non_constant_identifier_names
Widget OutlinedButton(
    {required String text, required Function onPressed, required bool dark}) {
  return Container(
    constraints: const BoxConstraints(minWidth: 190),
    child: TextButton(
      style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          backgroundColor: WidgetStatePropertyAll(
              dark ? const Color(0xff3049AA) : Colors.white),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xff3049AA)))),
      onPressed: () {
        onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 63.0, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
              color: dark ? Colors.white : const Color(0xff3049AA),
              fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}

String makeFullDouble(value) {
  if (!value.contains(".")) {
    value += ".00";
  }

  return value;
}
