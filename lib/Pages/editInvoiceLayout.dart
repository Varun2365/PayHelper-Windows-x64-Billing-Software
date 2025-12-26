// ignore_for_file: must_be_immutable, file_names, non_constant_identifier_names

import 'dart:convert';

import 'dart:io';
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:billing/createInvoiceLayout.dart';
import 'package:flutter/material.dart';

class EditInvoiceLayout extends StatefulWidget {
  String keyy;
  EditInvoiceLayout({super.key, required this.keyy});

  @override
  State<EditInvoiceLayout> createState() => EditInvoiceLayoutState();
}

class EditInvoiceLayoutState extends State<EditInvoiceLayout> {
  void changeValue(bool? newValue) {
    if (newValue != null) {
      setState(() {
        CheckboxState = newValue;
      });
    }
  }

  void set(value) {
    setState(() {
      igst = value;
    });
  }

  void clearForm() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              height: 150,
              width: 340,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Alert",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                fontSize: 21),
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
                      const Text(
                        "Are you sure to reset the form?",
                        style: TextStyle(
                            color: Color.fromARGB(255, 89, 89, 89),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 140,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color.fromARGB(255, 255, 255, 255)),
                              side: const WidgetStatePropertyAll(BorderSide(
                                  color: Color.fromARGB(95, 0, 0, 0))),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)))),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color.fromARGB(255, 85, 85, 85)),
                          ),
                        ),
                      ),
                      // SizedBox(height: 5,)
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              GSTController.clear();
                              SearchController.clear();
                              PartyController.clear();
                              ContactController.clear();
                              POController.clear();
                              TransportController.clear();
                              VehicleController.clear();
                              StationController.clear();
                              EWayController.clear();
                              GRController.clear();
                              AddressController.clear();
                              CheckboxState = true;
                            });
                            Map clear = {"items": []};
                            file.writeAsStringSync(jsonEncode(clear));
                            stateFn();
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color(0xff3049aa)),
                              side: const WidgetStatePropertyAll(
                                  BorderSide(color: Colors.transparent)),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)))),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void stateFn() {
    setState(() {
      file = File('Database/Invoices/tempInvoice.json');
    });
  }

  void removeProduct(index) {
    dynamic fileContent = file.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List list = fileContent['items'];
    list.removeAt(index);
    Map temp = {"items": list};
    file.writeAsStringSync(jsonEncode(temp));
    setState(() {
      file = File('Database/Invoices/tempPdf.json');

      file = File('Database/Invoices/tempInvoice.json');
    });
  }

  bool CheckboxState = true;
  bool igst = false;
  TextEditingController DateController = TextEditingController(
          text:
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
      InvoiceController = TextEditingController(
          text: readContent(folder: "Invoices", name: "invoiceNumber.txt")),
      GSTController = TextEditingController(),
      SearchController = TextEditingController(),
      PartyController = TextEditingController(),
      ContactController = TextEditingController(),
      POController = TextEditingController(),
      TransportController = TextEditingController(),
      VehicleController = TextEditingController(),
      StationController = TextEditingController(),
      EWayController = TextEditingController(),
      GRController = TextEditingController(),
      ShippingController = TextEditingController(),
      AddressController = TextEditingController();
  late List items;
  File file = File('Database/Invoices/tempInvoice.json');
  File invoiceFile = File("Database/Invoices/Invoices.json");
  @override
  void initState() {
    super.initState();
  }

  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  @override
  Widget build(BuildContext context) {
    dynamic content = invoiceFile.readAsStringSync();
    content = jsonDecode(content);
    dynamic fileContent = content[widget.keyy];
    items = fileContent['Products'];
    Map tempInvoice = {"items": items};
    file.writeAsStringSync(jsonEncode(tempInvoice));
    dynamic itemList = file.readAsStringSync();
    itemList = jsonDecode(itemList);
    DateController.text = fileContent['Date'];
    PartyController.text = fileContent['BillingName'];
    InvoiceController.text = widget.keyy;
    GSTController.text = fileContent['BillingGST'];
    ContactController.text = fileContent['Contact'];
    POController.text = fileContent['GR'];
    TransportController.text = fileContent['Transport'];
    VehicleController.text = fileContent['Vehicle'];
    StationController.text = fileContent['Station'];
    EWayController.text = fileContent['Eway'];
    GRController.text = fileContent['GR'];
    ShippingController.text = fileContent['ShippingAdd'];
    AddressController.text = fileContent['BillingAdd'];

    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: 1100,
            height: 800,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: 570,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Create Invoice",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Container(
                            height: 3,
                            width: 200,
                            color: ColorPalette.blueAccent,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DateField(context, DateController, 160, "Date"),
                              NoSuffixTextField(
                                  InvoiceController, 110, "Invoice No."),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  PartyController, 460, "Party Name"),
                              NoSuffixTextField(GSTController, 460, "GST No."),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  NoSuffixTextField(
                                      ContactController, 460, "Contact No."),
                                  NoSuffixTextField(
                                      POController, 460, "PO No."),
                                ],
                              ),
                              AddressTextField(
                                  AddressController, 460, "Billing Address")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  TransportController, 460, "Transport"),
                              NoSuffixTextField(
                                  VehicleController, 460, "Vehicle No.")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  StationController, 460, "Station"),
                              NoSuffixTextField(
                                  EWayController, 460, "E-Way Bill No.")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  NoSuffixTextField(
                                      GRController, 460, "GR/LR No."),
                                  Container(
                                      height: 55,
                                      width: 460,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ColorPalette.blueAccent),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Mark Shipping Address Same As Billing Address",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff6681e8),
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Checkbox(
                                              activeColor:
                                                  ColorPalette.blueAccent,
                                              side: BorderSide(
                                                  color:
                                                      ColorPalette.blueAccent),
                                              value: CheckboxState,
                                              onChanged: (newValue) {
                                                changeValue(newValue);
                                              },
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              AddressTextField(
                                  CheckboxState
                                      ? AddressController
                                      : ShippingController,
                                  460,
                                  "Shipping Address")
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 465,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tax Rate",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: taxBrackets.length,
                                      itemBuilder: (c, i) {
                                        return Row(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedChip = i;
                                                    refactor(
                                                        tax: taxRates[i],
                                                        content: fileContent);
                                                  });
                                                },
                                                child: Chip(
                                                    side: const BorderSide(
                                                        color: Color.fromARGB(
                                                            54, 158, 158, 158)),
                                                    backgroundColor:
                                                        i == selectedChip
                                                            ? ColorPalette.dark
                                                            : Colors.white,
                                                    label: Text(
                                                      taxBrackets[i],
                                                      style: TextStyle(
                                                          color: i ==
                                                                  selectedChip
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ))),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
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
                                  showAddItemWindow(
                                    context,
                                    taxRates[selectedChip],
                                    stateFn,
                                    45555,
                                    false,
                                  );
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
                            itemCount: items.length,
                            itemBuilder: (c, i) {
                              return ProductRow(
                                set: stateFn,
                                taxRate: taxRates[selectedChip],
                                remove: removeProduct,
                                index: i,
                                sno: "${i + 1}",
                                product: "${itemList["items"][i]['name']}",
                                hsn: "${itemList["items"][i]['hsn']}",
                                rate: "${itemList["items"][i]['rate']}",
                                qty: "${itemList["items"][i]['qty']}",
                                line1: "${itemList["items"][i]['desc']}",
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(75, 36, 36, 36),
                            blurRadius: 10)
                      ], color: Color.fromARGB(255, 253, 253, 253)),
                      height: 230,
                      width: 1100,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: GrandTotalSection(
                            POController: POController,
                            igst: igst,
                            taxRate: taxRates[selectedChip],
                            check: CheckboxState,
                            partyController: PartyController,
                            ContactController: ContactController,
                            file: file,
                            clear: clearForm,
                            nameController: AddressController,
                            GSTController: GSTController,
                            ShippingController: ShippingController,
                            InvoiceController: InvoiceController,
                            DateController: DateController,
                            GRController: GRController,
                            TransportController: TransportController,
                            VehicleController: VehicleController,
                            stationController: StationController,
                            addressController: AddressController,
                            EWayController: EWayController,
                            onFileChange: () {},
                          ))),
                ),
                Positioned(
                    top: 20,
                    right: 20,
                    child: InkWell(
                      onTap: () {
                        // widget.onFileChange;
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(255, 232, 232, 232)),
                        child: Icon(
                          Icons.close,
                          color: ColorPalette.blueAccent,
                        ),
                      ),
                    ))
              ],
            ),
          ),
          // Container(
          //     width: 500,
          //     height: double.infinity,
          //     color: const Color.fromARGB(255, 215, 215, 215),
          //     child: const InvoicePreview()),
        ],
      ),
    );
  }
}

class EditInvoiceLayout2 extends StatefulWidget {
  String month;
  String year;
  String keyy;
  EditInvoiceLayout2(
      {super.key, required this.keyy, required this.month, required this.year});

  @override
  State<EditInvoiceLayout2> createState() => EditInvoiceLayout2State();
}

class EditInvoiceLayout2State extends State<EditInvoiceLayout2> {
  void changeValue(bool? newValue) {
    if (newValue != null) {
      setState(() {
        CheckboxState = newValue;
      });
    }
  }

  void set(value) {
    setState(() {
      igst = value;
    });
  }

  void clearForm() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              height: 150,
              width: 340,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Alert",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                fontSize: 21),
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
                      const Text(
                        "Are you sure to reset the form?",
                        style: TextStyle(
                            color: Color.fromARGB(255, 89, 89, 89),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 140,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color.fromARGB(255, 255, 255, 255)),
                              side: const WidgetStatePropertyAll(BorderSide(
                                  color: Color.fromARGB(95, 0, 0, 0))),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)))),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color.fromARGB(255, 85, 85, 85)),
                          ),
                        ),
                      ),
                      // SizedBox(height: 5,)
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              GSTController.clear();
                              SearchController.clear();
                              PartyController.clear();
                              ContactController.clear();
                              POController.clear();
                              TransportController.clear();
                              VehicleController.clear();
                              StationController.clear();
                              EWayController.clear();
                              GRController.clear();
                              AddressController.clear();
                              CheckboxState = true;
                            });
                            Map clear = {"items": []};
                            file.writeAsStringSync(jsonEncode(clear));
                            stateFn();
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color(0xff3049aa)),
                              side: const WidgetStatePropertyAll(
                                  BorderSide(color: Colors.transparent)),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)))),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void stateFn() {
    setState(() {
      file = File('Database/Invoices/tempInvoice.json');
    });
  }

  void removeProduct(index) {
    dynamic fileContent = file.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List list = fileContent['items'];
    list.removeAt(index);
    Map temp = {"items": list};
    file.writeAsStringSync(jsonEncode(temp));
    setState(() {
      file = File('Database/Invoices/tempPdf.json');
      file = File('Database/Invoices/tempInvoice.json');
    });
  }

  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  bool CheckboxState = true;
  bool igst = false;
  TextEditingController DateController = TextEditingController(
          text:
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
      InvoiceController = TextEditingController(
          text: readContent(folder: "Invoices", name: "invoiceNumber.txt")),
      GSTController = TextEditingController(),
      SearchController = TextEditingController(),
      PartyController = TextEditingController(),
      ContactController = TextEditingController(),
      POController = TextEditingController(),
      TransportController = TextEditingController(),
      VehicleController = TextEditingController(),
      StationController = TextEditingController(),
      EWayController = TextEditingController(),
      GRController = TextEditingController(),
      ShippingController = TextEditingController(),
      AddressController = TextEditingController();
  late List items;
  File file = File('Database/Invoices/tempInvoice.json');
  File invoiceFile = File("Database/Invoices/In.json");
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic content = invoiceFile.readAsStringSync();
    content = jsonDecode(content);
    dynamic fileContent = content;
    items = fileContent[widget.year][widget.month][widget.keyy]['Products'];

    Map tempInvoice = {"items": items};
    file.writeAsStringSync(jsonEncode(tempInvoice));
    dynamic itemList = file.readAsStringSync();
    itemList = jsonDecode(itemList);
    DateController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Date'];
    PartyController.text =
        fileContent[widget.year][widget.month][widget.keyy]['BillingName'];
    InvoiceController.text = widget.keyy;
    GSTController.text =
        fileContent[widget.year][widget.month][widget.keyy]['BillingGST'];
    ContactController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Contact'];
    POController.text =
        fileContent[widget.year][widget.month][widget.keyy]['GR'];
    TransportController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Transport'];
    VehicleController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Vehicle'];
    StationController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Station'];
    EWayController.text =
        fileContent[widget.year][widget.month][widget.keyy]['Eway'];
    GRController.text =
        fileContent[widget.year][widget.month][widget.keyy]['GR'];
    ShippingController.text =
        fileContent[widget.year][widget.month][widget.keyy]['ShippingAdd'];
    AddressController.text =
        fileContent[widget.year][widget.month][widget.keyy]['BillingAdd'];

    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: 1100,
            height: 800,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: 570,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Create Invoice",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Container(
                            height: 3,
                            width: 200,
                            color: ColorPalette.blueAccent,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DateField(context, DateController, 160, "Date"),
                              NoSuffixTextField(
                                  InvoiceController, 110, "Invoice No."),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  PartyController, 460, "Party Name"),
                              NoSuffixTextField(GSTController, 460, "GST No."),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  NoSuffixTextField(
                                      ContactController, 460, "Contact No."),
                                  NoSuffixTextField(
                                      POController, 460, "PO No."),
                                ],
                              ),
                              AddressTextField(
                                  AddressController, 460, "Billing Address")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  TransportController, 460, "Transport"),
                              NoSuffixTextField(
                                  VehicleController, 460, "Vehicle No.")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NoSuffixTextField(
                                  StationController, 460, "Station"),
                              NoSuffixTextField(
                                  EWayController, 460, "E-Way Bill No.")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  NoSuffixTextField(
                                      GRController, 460, "GR/LR No."),
                                  Container(
                                      height: 55,
                                      width: 460,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ColorPalette.blueAccent),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Mark Shipping Address Same As Billing Address",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff6681e8),
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Checkbox(
                                              activeColor:
                                                  ColorPalette.blueAccent,
                                              side: BorderSide(
                                                  color:
                                                      ColorPalette.blueAccent),
                                              value: CheckboxState,
                                              onChanged: (newValue) {
                                                changeValue(newValue);
                                              },
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              AddressTextField(
                                  CheckboxState
                                      ? AddressController
                                      : ShippingController,
                                  460,
                                  "Shipping Address")
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 465,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tax Rate",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: taxBrackets.length,
                                      itemBuilder: (c, i) {
                                        return Row(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedChip = i;
                                                    refactor(
                                                        tax: taxRates[i],
                                                        content: fileContent);
                                                  });
                                                },
                                                child: Chip(
                                                    side: const BorderSide(
                                                        color: Color.fromARGB(
                                                            54, 158, 158, 158)),
                                                    backgroundColor:
                                                        i == selectedChip
                                                            ? ColorPalette.dark
                                                            : Colors.white,
                                                    label: Text(
                                                      taxBrackets[i],
                                                      style: TextStyle(
                                                          color: i ==
                                                                  selectedChip
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ))),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
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
                                  showAddItemWindow(
                                    context,
                                    taxRates[selectedChip],
                                    stateFn,
                                    45555,
                                    false,
                                  );
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
                            itemCount: items.length,
                            itemBuilder: (c, i) {
                              return ProductRow(
                                set: stateFn,
                                remove: removeProduct,
                                index: i,
                                taxRate: taxRates[selectedChip],
                                sno: "${i + 1}",
                                product: "${itemList["items"][i]['name']}",
                                hsn: "${itemList["items"][i]['hsn']}",
                                rate: "${itemList["items"][i]['rate']}",
                                qty: "${itemList["items"][i]['qty']}",
                                line1: "${itemList["items"][i]['desc']}",
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(75, 36, 36, 36),
                            blurRadius: 10)
                      ], color: Color.fromARGB(255, 253, 253, 253)),
                      height: 230,
                      width: 1100,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: GrandTotalSection(
                            POController: POController,
                            igst: igst,
                            check: CheckboxState,
                            partyController: PartyController,
                            ContactController: ContactController,
                            file: file,
                            clear: clearForm,
                            nameController: AddressController,
                            GSTController: GSTController,
                            ShippingController: ShippingController,
                            InvoiceController: InvoiceController,
                            DateController: DateController,
                            GRController: GRController,
                            TransportController: TransportController,
                            VehicleController: VehicleController,
                            stationController: StationController,
                            addressController: AddressController,
                            EWayController: EWayController,
                            onFileChange: () {},
                            taxRate: taxRates[selectedChip],
                          ))),
                ),
                Positioned(
                    top: 20,
                    right: 20,
                    child: InkWell(
                      onTap: () {
                        // widget.onFileChange;
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(255, 232, 232, 232)),
                        child: Icon(
                          Icons.close,
                          color: ColorPalette.blueAccent,
                        ),
                      ),
                    ))
              ],
            ),
          ),
          // Container(
          //     width: 500,
          //     height: double.infinity,
          //     color: const Color.fromARGB(255, 215, 215, 215),
          //     child: const InvoicePreview()),
        ],
      ),
    );
  }
}
