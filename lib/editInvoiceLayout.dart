// ignore_for_file: non_constant_identifier_names, must_be_immutable, duplicate_ignore
// All the imports are made here
// Spacing is required for this file, to avoid any nuisance.
import 'dart:convert';
import 'dart:io';
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:billing/createInvoiceLayout.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// The main stateful EditInvoice class.
class EditInvoice extends StatefulWidget {
  Function onFileChange;
  String invoiceNo;
  Function set;
  EditInvoice(
      {super.key,
      required this.invoiceNo,
      required this.set,
      required this.onFileChange});

  @override
  State<EditInvoice> createState() => _EditInvoiceState();
}

// The State Class for EditInvoice class
// All the business implementation goes here.
//  Make it neat and clean.
class _EditInvoiceState extends State<EditInvoice> {
  @override
  void initState() {
    invoiceNo = widget.invoiceNo;
    setTextControllers();
    openAndCopy(invoiceNo);
    super.initState();
  }

  // Declaration of all the variables goes here.
  bool CheckboxState = true;
  bool igst = false;
  late String invoiceNo;
  TextEditingController GSTController = TextEditingController(),
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
      DateController = TextEditingController(),
      InvoiceController = TextEditingController(),
      AddressController = TextEditingController();
  File tempInvoice = File("Database/Invoices/tempInvoice.json"),
      Invoices = File("Database/Invoices/Invoices.json");
  // Declaration for all the functions used in this class goes here.
  // This function changes the value of the checkbox.
  void changeValue(bool? newValue) {
    if (newValue != null) {
      setState(() {
        CheckboxState = newValue;
      });
    }
  }

  //  This function can be used to set the boolean value of wheather
  // a firm is having IGST or not.
  void set(value) {
    setState(() {
      igst = value;
    });
  }

  // This function can be used to clear the form
  // It clears all the textfields and also resets the tempInvoice.json
  // Containing no product in it.
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
                            tempInvoice.writeAsStringSync(jsonEncode(clear));
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

  // This function can be used to call set state again and
  // This time with the new content present in the tempInvoice.json file.
  void stateFn() {
    setState(() {
      tempInvoice = File('Database/Invoices/tempInvoice.json');
    });
  }

  //This function opens the key from the Invoices.json file
  // and copies the "Products" key to the tempInvoice.json file
  // for the working of the rest of the editInvoicelayout
  void openAndCopy(String key) {
    dynamic content = Invoices.readAsStringSync();
    content = jsonDecode(content);
    List itemList = content[key]["Products"];
    Map temp = {"items": itemList};
    tempInvoice.writeAsStringSync(jsonEncode(temp));
  }

  //This function sets the values of TextEditingControllers
  // to the ones being fetched from the Invoices.json file
  void setTextControllers() {
    String key = invoiceNo;
    dynamic tempContent = Invoices.readAsStringSync();
    tempContent = jsonDecode(tempContent);
    DateController.text = tempContent[key]["Date"];
    GSTController.text = tempContent[key]["BillingGST"];
    AddressController.text = tempContent[key]["BillingAdd"];
    PartyController.text = tempContent[key]["BillingName"];
    ContactController.text = tempContent[key]["Contact"];
    POController.text = tempContent[key]["PO"] ?? "";
    TransportController.text = tempContent[key]["Transport"];
    VehicleController.text = tempContent[key]["Vehicle"];
    StationController.text = tempContent[key]["Station"];
    EWayController.text = tempContent[key]["Eway"];
    GRController.text = tempContent[key]["GR"];
    ShippingController.text = tempContent[key]["ShippingAdd"];
    InvoiceController.text = key;
  }

  // This function deletes the particular product from the 'items' list present
  // inside the tempInvoice.json file.
  void removeProduct(index) {
    dynamic fileContent = tempInvoice.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List list = fileContent['items'];
    list.removeAt(index);
    Map temp = {"items": list};
    tempInvoice.writeAsStringSync(jsonEncode(temp));
    setState(() {
      tempInvoice = File('Database/Invoices/tempInvoice.json');
    });
  }

  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  @override
  Widget build(BuildContext context) {
    dynamic fileContent = tempInvoice.readAsStringSync();
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
                                  "Edit Invoice",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25),
                                ),
                                InkWell(
                                  onTap: () {
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DateField(context, DateController, 160, "Date"),
                                NoSuffixTextField1(
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
                              height: 30,
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
                        child: GrandTotalSectionEdit(
                          taxRate: taxRates[selectedChip],
                          set: widget.set,
                          invoiceNo: invoiceNo,
                          igst: igst,
                          check: CheckboxState,
                          partyController: PartyController,
                          ContactController: ContactController,
                          file: tempInvoice,
                          clear: clearForm,
                          nameController: AddressController,
                          GSTController: GSTController,
                          ShippingController: ShippingController,
                          InvoiceController: InvoiceController,
                          DateController: DateController,
                          GRController: GRController,
                          POController: POController,
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

class EditInvoice2 extends StatefulWidget {
  Function onFileChange;
  String invoiceNo, month, year;
  Function set;
  EditInvoice2(
      {super.key,
      required this.month,
      required this.year,
      required this.invoiceNo,
      required this.set,
      required this.onFileChange});

  @override
  State<EditInvoice2> createState() => _EditInvoice2State();
}

// The State Class for EditInvoice class
// All the business implementation goes here.
//  Make it neat and clean.
class _EditInvoice2State extends State<EditInvoice2> {
  @override
  void initState() {
    invoiceNo = widget.invoiceNo;
    setTextControllers();
    openAndCopy(invoiceNo);
    super.initState();
  }

  // Declaration of all the variables goes here.
  bool CheckboxState = true;
  bool igst = false;
  late String invoiceNo;
  TextEditingController GSTController = TextEditingController(),
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
      DateController = TextEditingController(),
      InvoiceController = TextEditingController(),
      AddressController = TextEditingController();
  File tempInvoice = File("Database/Invoices/tempInvoice.json"),
      Invoices = File("Database/Invoices/Invoices.json");
  // Declaration for all the functions used in this class goes here.
  // This function changes the value of the checkbox.
  void changeValue(bool? newValue) {
    if (newValue != null) {
      setState(() {
        CheckboxState = newValue;
      });
    }
  }

  //  This function can be used to set the boolean value of wheather
  // a firm is having IGST or not.
  void set(value) {
    setState(() {
      igst = value;
    });
  }

  // This function can be used to clear the form
  // It clears all the textfields and also resets the tempInvoice.json
  // Containing no product in it.
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
                            tempInvoice.writeAsStringSync(jsonEncode(clear));
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

  // This function can be used to call set state again and
  // This time with the new content present in the tempInvoice.json file.
  void stateFn() {
    setState(() {
      tempInvoice = File('Database/Invoices/tempInvoice.json');
    });
  }

  //This function opens the key from the In.json file (for reading)
  // and copies the "Products" key to the tempInvoice.json file
  // for the working of the rest of the editInvoicelayout
  void openAndCopy(String key) {
    // Read from In.json which has the nested year/month structure
    File inFile = File("Database/Invoices/In.json");
    dynamic content = inFile.readAsStringSync();
    content = jsonDecode(content);
    if (content[widget.year] != null && 
        content[widget.year][widget.month] != null &&
        content[widget.year][widget.month][key] != null) {
      List itemList = content[widget.year][widget.month][key]["Products"];
      igst = content[widget.year][widget.month][key]['igst'];
      Map temp = {"items": itemList};
      tempInvoice.writeAsStringSync(jsonEncode(temp));
    }
  }

  //This function sets the values of TextEditingControllers
  // to the ones being fetched from the In.json file (for reading)
  // but will save to both Invoices.json and In.json
  void setTextControllers() {
    String key = invoiceNo;
    // Read from In.json which has the nested year/month structure
    File inFile = File("Database/Invoices/In.json");
    dynamic tempContent = inFile.readAsStringSync();
    tempContent = jsonDecode(tempContent);
    
    // Add null safety checks
    if (tempContent[widget.year] != null && 
        tempContent[widget.year][widget.month] != null &&
        tempContent[widget.year][widget.month][key] != null) {
      tempContent = tempContent[widget.year][widget.month][key];
      DateController.text = tempContent["Date"] ?? "";
      GSTController.text = tempContent["BillingGST"] ?? "";
      AddressController.text = tempContent["BillingAdd"] ?? "";
      PartyController.text = tempContent["BillingName"] ?? "";
      ContactController.text = tempContent["Contact"] ?? "";
      POController.text = tempContent["PO"] ?? "";
      TransportController.text = tempContent["Transport"] ?? "";
      VehicleController.text = tempContent["Vehicle"] ?? "";
      StationController.text = tempContent["Station"] ?? "";
      EWayController.text = tempContent["Eway"] ?? "";
      GRController.text = tempContent["GR"] ?? "";
      ShippingController.text = tempContent["ShippingAdd"] ?? "";
      InvoiceController.text = key;
    }
  }

  // This function deletes the particular product from the 'items' list present
  // inside the tempInvoice.json file.
  void removeProduct(index) {
    dynamic fileContent = tempInvoice.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    List list = fileContent['items'];
    list.removeAt(index);
    Map temp = {"items": list};
    tempInvoice.writeAsStringSync(jsonEncode(temp));
    setState(() {
      tempInvoice = File('Database/Invoices/tempInvoice.json');
    });
  }

  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  @override
  Widget build(BuildContext context) {
    dynamic fileContent = tempInvoice.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    int fileLength = fileContent["items"].length;
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
                            "Edit Invoice",
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
                              NoSuffixTextField1(
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
                            itemCount: fileLength,
                            itemBuilder: (c, i) {
                              return ProductRow(
                                set: stateFn,
                                remove: removeProduct,
                                index: i,
                                taxRate: taxRates[selectedChip],
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
                          child: GrandTotalSectionEdit2(
                            year: widget.year,
                            taxRate: taxRates[selectedChip],
                            month: widget.month,
                            set: widget.set,
                            invoiceNo: invoiceNo,
                            igst: igst,
                            check: CheckboxState,
                            partyController: PartyController,
                            ContactController: ContactController,
                            file: tempInvoice,
                            clear: clearForm,
                            nameController: AddressController,
                            GSTController: GSTController,
                            ShippingController: ShippingController,
                            InvoiceController: InvoiceController,
                            DateController: DateController,
                            GRController: GRController,
                            POController: POController,
                            TransportController: TransportController,
                            VehicleController: VehicleController,
                            stationController: StationController,
                            addressController: AddressController,
                            EWayController: EWayController,
                            onFileChange: widget.onFileChange,
                          ))),
                ),
                Positioned(
                    top: 20,
                    right: 20,
                    child: InkWell(
                      onTap: () {
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
        ],
      ),
    );
  }
}

//This section contains various widgets that are used in the
//EditInvoice dialog Box.
//These are also present in the CreateInvoiceLayout.dart
//But due to some errors , they are again defined here.
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

Widget NoSuffixTextField1(
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

Widget AddressTextField(
  TextEditingController controller,
  double width,
  String label,
) {
  return SizedBox(
    height: 140,
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

class GrandTotalSectionEdit extends StatefulWidget {
  File file;
  Function onFileChange;
  Function clear;
  Function set;
  bool igst;
  int taxRate;
  bool check;
  String invoiceNo;
  TextEditingController nameController,
      GSTController,
      partyController,
      ShippingController,
      InvoiceController,
      DateController,
      GRController,
      POController,
      TransportController,
      VehicleController,
      stationController,
      addressController,
      ContactController,
      EWayController;

  GrandTotalSectionEdit({
    super.key,
    required this.invoiceNo,
    required this.igst,
    required this.taxRate,
    required this.ContactController,
    required this.set,
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
    required this.POController,
    required this.TransportController,
    required this.VehicleController,
    required this.stationController,
    required this.EWayController,
  });

  @override
  State<GrandTotalSectionEdit> createState() => _GrandTotalSectionEditState();
}

class _GrandTotalSectionEditState extends State<GrandTotalSectionEdit> {
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
                          "upi://pay?pa=8178770706@fam&pn=vaibhav kumar&am=$amount",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Name: Varun Kumar",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
                const Text(
                  "UPI ID: 9643606839@fam",
                  style: TextStyle(
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
    super.initState();
  }

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // OutlinedButton(
                //     text: "Show Payment QR",
                //     onPressed: () {
                //       showQR(context,
                //           convertIndianFormattedStringToNumber(grandTotal));
                //     },
                //     dark: false),
                OutlinedButton2(
                    text: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    dark: false),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton2(
                    text: "Save Changes",
                    onPressed: () {
                      if (items.isEmpty) {
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
                                                    "Please Enter Atleast One Product",
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
                        Map save = {
                          "BillingName": widget.partyController.text,
                          "BillingGST": widget.GSTController.text,
                          "BillingAdd": widget.addressController.text,
                          "ShippingAdd": widget.check
                              ? widget.addressController.text
                              : widget.ShippingController.text,
                          "InvoiceNo": widget.invoiceNo,
                          "Date": widget.DateController.text,
                          "Place": widget.GSTController.text,
                          "GR": widget.GRController.text,
                          "PO": widget.POController.text,
                          "Transport": widget.TransportController.text,
                          "Vehicle": widget.VehicleController.text,
                          "Station": widget.stationController.text,
                          "Contact": widget.ContactController.text,
                          "Eway": widget.EWayController.text,
                          "Products": items,
                          "igst": widget.igst,
                          "cgst": makeFullDouble(cgst),
                          "sgst": makeFullDouble(sgst),
                          "igstV": makeFullDouble(igstV),
                          "grandtotal": makeFullDouble(grandTotal),
                          "grandTotalInWords": convertToIndianCurrencyWords(
                              convertIndianFormattedStringToNumber(grandTotal)),
                          "TaxRate": "18%",
                          "TaxAmount": sum,
                          "TotalTax": makeFullDouble(totalTax)
                        };
                        // Save to Invoices.json (primary storage)
                        File invoices = File("Database/Invoices/Invoices.json");
                        dynamic fileContent = invoices.readAsStringSync();
                        fileContent = jsonDecode(fileContent);
                        fileContent[widget.invoiceNo] = save;
                        invoices.writeAsStringSync(jsonEncode(fileContent));
                        
                        // Also save to In.json (for home page history) - need to extract year/month from date
                        String dateStr = widget.DateController.text;
                        if (dateStr.isNotEmpty) {
                          List dateParts = dateStr.split("/");
                          if (dateParts.length == 3) {
                            String year = dateParts[2];
                            String month = dateParts[1].length == 1 ? "0${dateParts[1]}" : dateParts[1];
                            
                            File inFile = File("Database/Invoices/In.json");
                            dynamic inContent = inFile.readAsStringSync();
                            inContent = jsonDecode(inContent);
                            inContent[year] ??= {};
                            inContent[year][month] ??= {};
                            inContent[year][month][widget.invoiceNo] = save;
                            inFile.writeAsStringSync(jsonEncode(inContent));
                          }
                        }
                        
                        widget.onFileChange();
                        widget.set();
                        Navigator.of(context).pop();
                      }
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

class GrandTotalSectionEdit2 extends StatefulWidget {
  File file;
  Function onFileChange;
  Function clear;
  Function set;
  bool igst;
  int taxRate;
  bool check;
  String invoiceNo, year, month;
  TextEditingController nameController,
      GSTController,
      partyController,
      ShippingController,
      InvoiceController,
      DateController,
      GRController,
      POController,
      TransportController,
      VehicleController,
      stationController,
      addressController,
      ContactController,
      EWayController;

  GrandTotalSectionEdit2({
    super.key,
    required this.invoiceNo,
    required this.taxRate,
    required this.igst,
    required this.ContactController,
    required this.set,
    required this.file,
    required this.year,
    required this.month,
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
    required this.POController,
    required this.TransportController,
    required this.VehicleController,
    required this.stationController,
    required this.EWayController,
  });

  @override
  State<GrandTotalSectionEdit2> createState() => _GrandTotalSectionEdit2State();
}

class _GrandTotalSectionEdit2State extends State<GrandTotalSectionEdit2> {
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
                          "upi://pay?pa=8178770706@fam&pn=vaibhav kumar&am=$amount",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Name: Varun Kumar",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
                const Text(
                  "UPI ID: 9643606839@fam",
                  style: TextStyle(
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
    super.initState();
  }

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton2(
                    text: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    dark: false),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton2(
                    text: "Save Changes",
                    onPressed: () {
                      if (items.isEmpty) {
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
                                                    "Please Enter Atleast One Product",
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
                        Map save = {
                          "BillingName": widget.partyController.text,
                          "BillingGST": widget.GSTController.text,
                          "BillingAdd": widget.addressController.text,
                          "ShippingAdd": widget.check
                              ? widget.addressController.text
                              : widget.ShippingController.text,
                          "InvoiceNo": widget.invoiceNo,
                          "Date": widget.DateController.text,
                          "Place": widget.GSTController.text,
                          "GR": widget.GRController.text,
                          "PO": widget.POController.text,
                          "Transport": widget.TransportController.text,
                          "Vehicle": widget.VehicleController.text,
                          "Station": widget.stationController.text,
                          "Contact": widget.ContactController.text,
                          "Eway": widget.EWayController.text,
                          "Products": items,
                          "igst": widget.igst,
                          "cgst": makeFullDouble(cgst),
                          "sgst": makeFullDouble(sgst),
                          "igstV": makeFullDouble(igstV),
                          "grandtotal": makeFullDouble(grandTotal),
                          "grandTotalInWords": convertToIndianCurrencyWords(
                              convertIndianFormattedStringToNumber(grandTotal)),
                          "TaxRate": "18%",
                          "TaxAmount": formatIntegerToIndian(sum),
                          "TotalTax": makeFullDouble(totalTax)
                        };
                        // Save to Invoices.json (primary storage)
                        File invoices = File("Database/Invoices/Invoices.json");
                        dynamic fileContent = invoices.readAsStringSync();
                        fileContent = jsonDecode(fileContent);
                        fileContent[widget.year] ??= {};
                        fileContent[widget.year][widget.month] ??= {};
                        fileContent[widget.year][widget.month][widget.invoiceNo] = save;
                        invoices.writeAsStringSync(jsonEncode(fileContent));
                        
                        // Also save to In.json (for home page history)
                        File inFile = File("Database/Invoices/In.json");
                        dynamic inContent = inFile.readAsStringSync();
                        inContent = jsonDecode(inContent);
                        inContent[widget.year] ??= {};
                        inContent[widget.year][widget.month] ??= {};
                        inContent[widget.year][widget.month][widget.invoiceNo] = save;
                        inFile.writeAsStringSync(jsonEncode(inContent));
                        
                        widget.onFileChange();
                        widget.set();
                        Navigator.of(context).pop();
                      }
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
Widget OutlinedButton2(
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
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
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
