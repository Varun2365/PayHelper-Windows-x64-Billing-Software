// ignore_for_file: camel_case_types, non_constant_identifier_names, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:billing/components/invoiceTableHead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void showPurchaseAddItemDialog(context, Function setFn) {
  showDialog(
      context: context,
      builder: (c) {
        return PurchaseAddItemDialog(
          setfn: setFn,
        );
      });
}

class PurchaseAddItemDialog extends StatefulWidget {
  Function setfn;
  PurchaseAddItemDialog({super.key, required this.setfn});

  @override
  State<PurchaseAddItemDialog> createState() => Purchase_AddItemDialogState();
}

class Purchase_AddItemDialogState extends State<PurchaseAddItemDialog> {
  List taxBrackets = ["0%", "3%", "5%", "12%", "18%", "28%"];
  List taxRates = [0, 3, 5, 12, 18, 28];
  int selectedChip = 3;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController hsnController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController qtyController = TextEditingController(text: "1");
  TextEditingController rateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          height: 790,
          width: 600,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Add a Product",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  PurchaseItemTextField(() {}, nameController, descController,
                      hsnController, rateController, amountController),
                  TextRow(
                      title: "Name",
                      max: 1,
                      controller: nameController,
                      context: context),
                  TextRow(
                      title: "Specs",
                      max: 1,
                      controller: descController,
                      context: context),
                  TextRow(
                      title: "HSN Code",
                      max: 1,
                      controller: hsnController,
                      context: context),
                  QuantityRow(
                      checkState: false,
                      text: "Qty.",
                      taxRate: 13,
                      controller: qtyController,
                      rateController: rateController,
                      amountController: amountController,
                      totalAmountController: TextEditingController(),
                      max: 1,
                      enabled: true,
                      autoCalc: false),
                  RateRow(
                      tick: false,
                      text: "Rate",
                      taxRate: 13,
                      controller: rateController,
                      controller2: amountController,
                      controller3: qtyController,
                      max: 1,
                      enabled: true),
                  AmountRow(
                      text: "Amount",
                      taxRate: 12,
                      controller: amountController,
                      rateController: rateController,
                      qtyController: qtyController,
                      totalAmountController: TextEditingController(),
                      max: 1,
                      enabled: false),
                  const SizedBox(
                    height: 15,
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
                                          });
                                        },
                                        child: Chip(
                                            side: const BorderSide(
                                                color: Color.fromARGB(
                                                    54, 158, 158, 158)),
                                            backgroundColor: i == selectedChip
                                                ? ColorPalette.dark
                                                : Colors.white,
                                            label: Text(
                                              taxBrackets[i],
                                              style: TextStyle(
                                                  color: i == selectedChip
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
                ],
              ),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: 80,
                  width: 500,
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            style: const ButtonStyle(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.transparent),
                                splashFactory: NoSplash.splashFactory),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: ColorPalette.blueAccent),
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color(0xff3049AA))),
                          onPressed: () {
                            File tempPurchase =
                                File("Database/Invoices/tempPurchase.json");
                            dynamic content = tempPurchase.readAsStringSync();
                            content = jsonDecode(content);
                            Map tempContent = {
                              "name": nameController.text,
                              "desc": descController.text,
                              "qty": qtyController.text,
                              "hsn": hsnController.text,
                              "rate": rateController.text,
                              "amount": amountController.text,
                              "tax": taxRates[selectedChip],
                              "grandTotal": formatIntegerToIndian(double.parse(
                                      qtyController.text) *
                                  (convertIndianFormattedStringToNumber(
                                          rateController.text) +
                                      ((taxRates[selectedChip] / 100) *
                                          convertIndianFormattedStringToNumber(
                                              rateController.text))))
                            };
                            content['items'].add(tempContent);
                            tempPurchase.writeAsStringSync(jsonEncode(content));
                            widget.setfn();
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 5),
                            child: Text(
                              "Add",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

// This section has the topmost text field
Widget PurchaseItemTextField(
  Function updateAmount,
  TextEditingController nameController,
  TextEditingController descController,
  TextEditingController hsnController,
  TextEditingController rateController,
  TextEditingController amountController,
) {
  dynamic content = readContent(name: "products.json", folder: "Products");
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
                width: 1.5,
                color: Color.fromARGB(62, 86, 86, 86),
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
              "Search For Product...", // This will act as the floating label
          labelStyle: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(180, 86, 86, 86),
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins"),
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
        Map bhaisahb = jsonDecode(content);
        nameController.text = bhaisahb[suggestion]['name'];
        descController.text = bhaisahb[suggestion]['desc'];
        hsnController.text = bhaisahb[suggestion]['hsn'];
        rateController.text = bhaisahb[suggestion]['rate'];
        amountController.text = bhaisahb[suggestion]['rate'];
        Future.delayed(const Duration(milliseconds: 10), () {
          updateAmount();
        });
      },
    ),
  );
}

//This Section contains TextField Rows.
Widget TextRow(
    {required String title,
    required int max,
    required TextEditingController controller,
    required BuildContext context}) {
  return Column(
    children: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title :",
            style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 86, 86, 86),
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 330),
            decoration: BoxDecoration(
                color: const Color.fromARGB(32, 226, 226, 226),
                borderRadius: BorderRadius.circular(9)),
            child: TextField(
              onChanged: (value) {},
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 86, 86, 86),
                  fontSize: 14),
              controller: controller,
              maxLines: title == "Specs" ? 3 : max,
              minLines: title == "Specs" ? 3 : 1,
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  label: Text(""),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(144, 158, 158, 158))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 14, 44, 180))),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
                // controller.text = formatIntegerToIndian(
                //     convertIndianFormattedStringToNumber(
                //         (controller.text).toString()));
              },
            ),
          ),
        ],
      ),
    ],
  );
}

Widget PurchaseQuantityRow(
    {required String title,
    required int max,
    required TextEditingController controller,
    required BuildContext context}) {
  return Column(
    children: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title :",
            style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 86, 86, 86),
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 330),
            decoration: BoxDecoration(
                color: const Color.fromARGB(32, 226, 226, 226),
                borderRadius: BorderRadius.circular(9)),
            child: TextField(
              onChanged: (value) {},
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 86, 86, 86),
                  fontSize: 14),
              controller: controller,
              maxLines: title == "Specs" ? 3 : max,
              minLines: title == "Specs" ? 3 : 1,
              decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  label: Text(""),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(144, 158, 158, 158))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 14, 44, 180))),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
                // controller.text = formatIntegerToIndian(
                //     convertIndianFormattedStringToNumber(
                //         (controller.text).toString()));
              },
            ),
          ),
        ],
      ),
    ],
  );
}
