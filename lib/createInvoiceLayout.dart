// ignore_for_file: non_constant_identifier_names, file_names, must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/StateCodes.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CreateInvoiceLayout extends StatefulWidget {
  Function onFileChange;
  CreateInvoiceLayout({super.key, required this.onFileChange});

  @override
  State<CreateInvoiceLayout> createState() => CreateInvoiceLayoutState();
}

class CreateInvoiceLayoutState extends State<CreateInvoiceLayout> {
  bool CheckboxState = true;
  bool igst = false;
  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  File settings = File("Database/Firm/firmDetails.json");
  TextEditingController DateController = TextEditingController(
          text:
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
      InvoiceController = TextEditingController(),
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
  File file = File('Database/Invoices/tempInvoice.json');

  @override
  void initState() {
    dynamic settingsContent = settings.readAsStringSync();
    settingsContent = jsonDecode(settingsContent);
    InvoiceController.text =
        "${settingsContent['InvoicePrefix']}${readContent(folder: "Invoices", name: "invoiceNumber.txt")}";
    File tempInvoice = File("Database/Invoices/tempInvoice.json");
    Map content = {'items': []};
    tempInvoice.writeAsStringSync(jsonEncode(content));

    super.initState();
  }

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
      file = File('Database/Invoices/tempInvoice.json');
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic fileContent = file.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    int fileLength = fileContent["items"].length;
    return Expanded(
      child: Row(
        children: [
          SizedBox(
            width: 1100,
            height: 800,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    // height: 570,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Create Invoice",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25),
                                ),
                                InkWell(
                                  onTap: () {
                                    widget.onFileChange;
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232)),
                                    child: Icon(
                                      Icons.close,
                                      color: ColorPalette.blueAccent,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              height: 3,
                              width: 200,
                              color: ColorPalette.blueAccent,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            PartyTextField(PartyController,
                                set: set,
                                gst: GSTController,
                                contact: ContactController,
                                address: AddressController),
                            const SizedBox(
                              height: 40,
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
                                GSTTextField(GSTController, StationController,
                                    460, "GST No.", set),
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
                                    StationController, 460, "Place Of Supply"),
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
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Checkbox(
                                                activeColor:
                                                    ColorPalette.blueAccent,
                                                side: BorderSide(
                                                    color: ColorPalette
                                                        .blueAccent),
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
                              height: 50,
                            ),
                            SizedBox(
                              width: 465,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                              54,
                                                              158,
                                                              158,
                                                              158)),
                                                      backgroundColor: i ==
                                                              selectedChip
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 40),
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
                              itemCount: fileLength,
                              itemBuilder: (c, i) {
                                return ProductRow(
                                  set: stateFn,
                                  taxRate: taxRates[selectedChip],
                                  remove: removeProduct,
                                  index: i,
                                  sno: "${i + 1}",
                                  product: "${fileContent["items"][i]['name']}",
                                  hsn: "${fileContent["items"][i]['hsn']}",
                                  rate: "${fileContent["items"][i]['rate']}",
                                  qty: "${fileContent["items"][i]['qty']}",
                                  line1: "${fileContent["items"][i]['desc']}",
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(75, 36, 36, 36), blurRadius: 10)
                    ], color: Color.fromARGB(255, 253, 253, 253)),
                    height: 230,
                    width: 1100,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        child: GrandTotalSection(
                          igst: igst,
                          taxRate: taxRates[selectedChip],
                          check: CheckboxState,
                          partyController: PartyController,
                          POController: POController,
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
                          onFileChange: widget.onFileChange,
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> date(context) async {
  dynamic date = await showDatePicker(
      currentDate: DateTime.now(),
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2089),
      initialDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day));
  String returnDate = "${date.day}/${date.month}/${date.year}";
  return returnDate;
}

Widget NewTextField(
  TextEditingController controller,
  double width,
  String label,
) {
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
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
          suffixIcon: const Icon(Icons.arrow_drop_down)),
    ),
  );
}

Widget DateField(
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

Widget NoSuffixTextField(
  TextEditingController controller,
  double width,
  String label,
) {
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue)),
        labelText: label, // This will act as the floating label
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xff6681e8),
            fontWeight: FontWeight.w600),
        // This will act as the hint text
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    ),
  );
}

Widget GSTTextField(
  TextEditingController controller,
  TextEditingController stationcontroller,
  double width,
  String label,
  Function set,
) {
  var map = StateCodes.stateCodeMap;
  var keys = map.keys.toList();
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
      onChanged: (value) {
        controller.text = value.toUpperCase();
        if (value.length >= 2) {
          if (value.substring(0, 2) != "06") {
            set(true);
          } else {
            set(false);
          }
          if (value.length >= 2) {
            if (keys.contains(value.substring(0, 2))) {
              stationcontroller.text =
                  "${value.substring(0, 2)}-${map[value.substring(0, 2)]}";
            } else {
              stationcontroller.clear();
            }
          }
        }
      },
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue)),
        labelText: label, // This will act as the floating label
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xff6681e8),
            fontWeight: FontWeight.w600),
        // This will act as the hint text
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    ),
  );
}

Widget NoSuffixTextFieldN(
  TextEditingController controller,
  double width,
  String label,
  Function on,
) {
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
      autofocus: true,
      onSubmitted: (value) {
        on();
      },
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(0)),
        focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(0)),
        border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: Colors.blue)),
        labelText: label, // This will act as the floating label
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xff6681e8),
            fontWeight: FontWeight.w600),
        // This will act as the hint text
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    ),
  );
}

Widget NoSuffixTextFieldE(
  TextEditingController controller,
  double width,
  String label,
  Function on,
) {
  return SizedBox(
    height: 90,
    width: width,
    // color: Colors.blue,
    child: TextField(
      onSubmitted: (value) {
        on();
      },
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue)),
        labelText: label, // This will act as the floating label
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xff6681e8),
            fontWeight: FontWeight.w600),
        // This will act as the hint text
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    ),
  );
}

Widget NoSuffixTextFieldParty(
  TextEditingController controller,
  double width,
  String label,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
          )),
      const SizedBox(
        height: 70,
        width: 20,
      ),
      Expanded(
        child: SizedBox(
          height: 70,
          width: width,
          // color: Colors.blue,
          child: TextField(
            autofocus: label == "Client Name" ? true : false,
            controller: controller,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: Color.fromARGB(255, 71, 71, 71)),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorPalette.dark, width: 0.8)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffA0A0A0), width: 0.4))),
          ),
        ),
      ),
    ],
  );
}

Widget NoSuffixTextField0(
  TextEditingController controller,
  double width,
  String label,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          )),
      const SizedBox(
        height: 70,
        width: 20,
      ),
      Expanded(
        child: SizedBox(
          height: 70,
          width: width,
          // color: Colors.blue,
          child: TextField(
            controller: controller,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: Color.fromARGB(255, 71, 71, 71)),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 153, 153, 153),
                  ),
                  borderRadius: BorderRadius.circular(5)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 2,
                    color: Color(0xff6681e8),
                  ),
                  borderRadius: BorderRadius.circular(5)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.blue)),
              labelText: "", // This will act as the floating label
              labelStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff6681e8),
                  fontWeight: FontWeight.w600),
              // This will act as the hint text
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget NoSuffixTextField0Party(
  TextEditingController controller,
  double width,
  String label,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
          )),
      const SizedBox(
        height: 70,
        width: 20,
      ),
      Expanded(
        child: SizedBox(
          height: 70,
          width: width,
          // color: Colors.blue,
          child: TextField(
            controller: controller,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: Color.fromARGB(255, 71, 71, 71)),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorPalette.dark, width: 0.8)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffA0A0A0), width: 0.4))),
          ),
        ),
      ),
    ],
  );
}

Widget NoSuffixTextField01(
  TextEditingController controller,
  double width,
  String label,
) {
  return Tooltip(
    textStyle: const TextStyle(
        fontSize: 11,
        fontFamily: 'Poppins',
        color: Colors.white,
        fontWeight: FontWeight.w400),
    waitDuration: const Duration(milliseconds: 200),
    message: "Unable to change name while editing",
    child: SizedBox(
      height: 70,
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
                color: Color(0xff6681e8),
              ),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Color(0xff6681e8),
              ),
              borderRadius: BorderRadius.circular(5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.blue)),
          labelText: label, // This will act as the floating label
          labelStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xff6681e8),
              fontWeight: FontWeight.w600),
          // This will act as the hint text
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    ),
  );
}

Widget AddressTextField(
  TextEditingController controller,
  double width,
  String label,
) {
  return SizedBox(
    height: 140,
    width: width,
    child: TextField(
      onSubmitted: (text) {},
      controller: controller,
      style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
          color: Color.fromARGB(255, 71, 71, 71)),
      maxLines: null,
      minLines: 1,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xff6681e8),
            ),
            borderRadius: BorderRadius.circular(5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue)),
        labelText: label, // This will act as the floating label
        labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xff6681e8),
            fontWeight: FontWeight.w600),
        // This will act as the hint text
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    ),
  );
}

Widget AddressTextField2(
  TextEditingController controller,
  double width,
  String label,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
          )),
      const SizedBox(
        height: 70,
        width: 20,
      ),
      Expanded(
        child: SizedBox(
          height: 80,
          width: width,
          // color: Colors.blue,
          child: TextField(
            onSubmitted: (text) {},
            controller: controller,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: Color.fromARGB(255, 71, 71, 71)),
            maxLines: null,
            minLines: 1,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorPalette.dark, width: 0.8)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffA0A0A0), width: 0.4))),
          ),
        ),
      ),
    ],
  );
}

Widget PartyTextField(TextEditingController PartyController,
    {required TextEditingController gst,
    required Function set,
    required TextEditingController contact,
    required TextEditingController address}) {
  String content = readContent(name: "parties.json", folder: "Party Records");
  List suggestions = jsonDecode(content).keys.toList();
  suggestions.sort();

  SuggestionsController suggestionsController = SuggestionsController();

  return Container(
    color: Colors.white,
    width: double.infinity,
    child: TypeAheadField(
      suggestionsController: suggestionsController,
      animationDuration: const Duration(milliseconds: 100),
      scrollController: ScrollController(initialScrollOffset: 0),
      builder: (context, partyController, focusNode) => TextField(
        controller: partyController, // Use partyController here
        focusNode: focusNode,
        autofocus: false,
        style:
            const TextStyle(fontWeight: FontWeight.w400, fontFamily: "Poppins"),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 1,
                color: Color(0xff6681e8),
              ),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Color(0xff6681e8),
              ),
              borderRadius: BorderRadius.circular(5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.blue)),
          labelText:
              "Search For Party...", // This will act as the floating label
          labelStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xff6681e8),
              fontWeight: FontWeight.w600),
          // This will act as the hint text
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      suggestionsCallback: (query) async {
        if (query.isEmpty) {
          return suggestions;
        } else {
          return suggestions
              .where((suggestion) =>
                  suggestion.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      },
      itemBuilder: (context, suggestion) => ListTile(
        textColor: Colors.black,
        tileColor: Colors.white,
        title: Text(suggestion),
      ),
      onSelected: (suggestion) {
        PartyController.text = suggestion;
        dynamic map = jsonDecode(content);
        address.text = map[suggestion]["address"];
        gst.text = map[suggestion]["gst"];
        contact.text = map[suggestion]["contact"];
        if (gst.text.substring(0, 2) != "06") {
          set(true);
        } else {
          set(false);
        }
      },
    ),
  );
}

void refactor({required int tax, required dynamic content}) {
  dynamic temp = content;
  int l = content['items'].length;
  for (var i = 0; i < l; i++) {
    if (content['items'][i]["auto"] == true) {
      var amountpp =
          convertIndianFormattedStringToNumber(content['items'][i]['amountpp']);
      temp['items'][i]['rate'] =
          formatIntegerToIndian((amountpp * 100) / (100 + tax));
      temp['items'][i]['tax'] = tax;
      temp['items'][i]['amount'] = formatIntegerToIndian(
          int.parse(content['items'][i]['qty']) *
              convertIndianFormattedStringToNumber(temp['items'][i]['rate']));
    }
  }
  File file = File("Database/Invoices/tempInvoice.json");
  file.writeAsStringSync(jsonEncode(temp));
}
