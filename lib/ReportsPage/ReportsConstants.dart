// ignore_for_file: non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api, camel_case_types

import 'dart:convert';

import 'dart:io';

import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/ReportsPage/addItemDialog.dart';
import 'package:billing/ReportsPage/purchaseGrandTotalSection.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/grandTotalSection.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:billing/createInvoiceLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ReportConstants {
  static int startMonth = (DateTime.now().month - 3);
  static int endMonth = (DateTime.now().month - 1);
}

void showPurchaseEntryDialog({required BuildContext context}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const PurchaseEntryDialog();
      });
}

class PurchaseEntryDialog extends StatefulWidget {
  const PurchaseEntryDialog({super.key});

  @override
  State<PurchaseEntryDialog> createState() => _PurchaseEntryDialogState();
}

class _PurchaseEntryDialogState extends State<PurchaseEntryDialog> {
  late dynamic content;
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();
  TextEditingController companyGSTController = TextEditingController();
  TextEditingController companyContactController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  File tempProducts = File("Database/Invoices/tempPurchase.json");
  @override
  void initState() {
    tempProducts.writeAsStringSync("{\"items\":[]}");
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
                          CompanyTextField(companyNameController,
                              gst: companyGSTController,
                              // set: () {},
                              contact: companyContactController,
                              address: companyAddressController),
                          const SizedBox(
                            height: 40,
                          ),
                          DateField(context, dateController, 150, "Date"),
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
                                return ProductRow(
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
                    child: PurchaseBottomBar(
                        content: content,
                        nameController: companyNameController,
                        gstController: companyGSTController,
                        dateController: dateController,
                        contactController: companyContactController,
                        addressController: companyAddressController,
                        noteController: noteController)),
                Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: ColorPalette.offWhite,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 12,
                          child: Icon(
                            Icons.close,
                            color: ColorPalette.blueAccent,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget CompanyTextField(TextEditingController PartyController,
    {required TextEditingController gst,
    // required Function set,
    required TextEditingController contact,
    required TextEditingController address}) {
  String content =
      readContent(name: "purchaseParties.json", folder: "Party Records");
  List suggestions = jsonDecode(content).keys.toList();
  suggestions.sort();

  SuggestionsController suggestionsController = SuggestionsController();

  return SizedBox(
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
              "Search For Vendor...", // This will act as the floating label
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
        tileColor: Colors.white,
        title: Text(suggestion),
      ),
      onSelected: (suggestion) {
        PartyController.text = suggestion;
        dynamic map = jsonDecode(content);
        address.text = map[suggestion][suggestion]["address"];
        gst.text = map[suggestion][suggestion]["gst"];
        contact.text = map[suggestion][suggestion]["contact"];
        if (gst.text.substring(0, 2) != "06") {
          // set(true);
        } else {
          // set(false);
        }
      },
    ),
  );
}

class ProductRow extends StatefulWidget {
  final int index;
  final String sno;
  final String product;
  final String? line1;
  final String hsn;
  final String rate;
  final String qty;
  final Function remove, set;

  const ProductRow({
    Key? key,
    required this.set,
    required this.remove,
    required this.index,
    required this.sno,
    required this.product,
    this.line1,
    required this.hsn,
    required this.rate,
    required this.qty,
  }) : super(key: key);

  @override
  _StatefulProductRowState createState() => _StatefulProductRowState();
}

class _StatefulProductRowState extends State<ProductRow> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            description(
              set: widget.set,
              remove: widget.remove,
              index: widget.index,
              width: 2,
              sno: int.parse(widget.sno),
              product:
                  // ignore: prefer_if_null_operators
                  "${widget.product}\n\n${widget.line1 == null ? "" : widget.line1}\n",
              hsn: widget.hsn,
              rate: convertIndianFormattedStringToNumber(widget.rate),
              qty: int.parse(widget.qty),
            ),
            Container(
              height: 15,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

class ProductRow2 extends StatefulWidget {
  final int index;
  final String sno;
  final String product;
  final String? line1;
  final String hsn;
  final String rate;
  final String qty;
  final Function remove, set;

  const ProductRow2({
    Key? key,
    required this.set,
    required this.remove,
    required this.index,
    required this.sno,
    required this.product,
    this.line1,
    required this.hsn,
    required this.rate,
    required this.qty,
  }) : super(key: key);

  @override
  _StatefulProductRow2State createState() => _StatefulProductRow2State();
}

class _StatefulProductRow2State extends State<ProductRow2> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            description(
              set: widget.set,
              remove: widget.remove,
              index: widget.index,
              width: 2,
              sno: int.parse(widget.sno),
              product:
                  // ignore: prefer_if_null_operators
                  "${widget.product}\n\n${widget.line1 == null ? "" : widget.line1}\n",
              hsn: widget.hsn,
              rate: convertIndianFormattedStringToNumber(widget.rate),
              qty: int.parse(widget.qty),
            ),
            Container(
              height: 15,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

class description extends StatefulWidget {
  const description({
    Key? key,
    required this.set,
    required this.index,
    required this.remove,
    required this.width,
    required this.sno,
    required this.product,
    required this.hsn,
    required this.rate,
    required this.qty,
  }) : super(key: key);

  final double width;
  final int sno, qty, index;
  final String product, hsn;
  final double rate;
  final Function remove, set;

  @override
  State<description> createState() => _descriptionState();
}

class _descriptionState extends State<description> {
  List taxBrackets = ["3%", "5%", "12%", "18%", "28%"];
  List taxRates = [3, 5, 12, 18, 28];
  int selectedChip = 3;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
                color: const Color(0xffd9d9d9).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // <-- Add this line
                  children: [
                    titles2(
                      width: 50,
                      heading: widget.sno.toString(),
                    ),
                    titles2(
                      width: 200,
                      heading: widget.product,
                    ),
                    titles2(
                      width: 130,
                      heading: widget.hsn,
                    ),
                    titles2(
                      width: 100,
                      heading: widget.qty.toString(),
                    ),
                    titles2(
                      width: 120,
                      heading: formatIntegerToIndian(widget.rate),
                    ),
                    titles3(
                      width: 160,
                      heading: makeFullDouble(
                          formatIntegerToIndian((widget.qty * widget.rate))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6)),
                color: const Color(0xffd9d9d9).withOpacity(0.3)),
            width: 100,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        widget.remove(widget.index);
                      });
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                  child: InkWell(
                    onTap: () {
                      showAddItemWindow(context, taxRates[selectedChip],
                          widget.set, widget.index, true);
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
