// ignore_for_file: file_names, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, camel_case_types, avoid_unnecessary_containers, use_super_parameters, must_be_immutable, library_private_types_in_public_api, unrelated_type_equality_checks, use_build_context_synchronously

import "dart:convert";
import "dart:io";
import "package:billing/Handlers/JSONHandler.dart";
import "package:billing/colors.dart";
import "package:billing/components/addItemComponenets.dart";
import "package:billing/components/grandTotalSection.dart";
import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";

Widget RowHeader() {
  ColorPalette2 _colorPalette = ColorPalette2();
  return Material(
    child: Container(
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xffD9D9d9).withOpacity(.5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            titles(
              colorPalette: _colorPalette,
              width: 50,
              heading: "S.No.",
            ),
            titles(
              colorPalette: _colorPalette,
              width: 200,
              heading: "Products",
            ),
            titles(
              colorPalette: _colorPalette,
              width: 130,
              heading: "HSN Code",
            ),
            titles(
              colorPalette: _colorPalette,
              width: 100,
              heading: "Qty.",
            ),
            titles(
              colorPalette: _colorPalette,
              width: 120,
              heading: "Rate",
            ),
            titles1(
              colorPalette: _colorPalette,
              width: 160,
              heading: "Amount",
            ),
          ],
        ),
      ),
    ),
  );
}

class titles extends StatelessWidget {
  const titles({
    super.key,
    required ColorPalette2 colorPalette,
    required this.width,
    required this.heading,
  });

  final double width;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: width,
      child: Text(
        heading,
        style: const TextStyle(
            color: Color(0xff3049AA),
            fontSize: 14,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

class titles1 extends StatelessWidget {
  const titles1({
    super.key,
    required ColorPalette2 colorPalette,
    required this.width,
    required this.heading,
  });

  final double width;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: width,
      child: Text(
        heading,
        textAlign: TextAlign.end,
        style: const TextStyle(
            color: Color(0xff3049AA),
            fontSize: 14,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ProductRow extends StatefulWidget {
  final int index;
  final int taxRate;
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
    required this.taxRate,
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
              taxRate: widget.taxRate,
              set: widget.set,
              remove: widget.remove,
              index: widget.index,
              width: 2,
              sno: int.parse(widget.sno),
              product: "${widget.product}\n\n${widget.line1}\n",
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
    required this.taxRate,
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
  final int sno, qty, index, taxRate;
  final String product, hsn;
  final double rate;
  final Function remove, set;

  @override
  State<description> createState() => _descriptionState();
}

class _descriptionState extends State<description> {
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
                      showAddItemWindow(context, widget.taxRate, widget.set,
                          widget.index, true);
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

class titles2 extends StatelessWidget {
  const titles2({
    super.key,
    required this.width,
    required this.heading,
  });

  final double width;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 20,
      width: width,
      child: Text(
        heading,
        style: const TextStyle(
            color: Color.fromARGB(221, 48, 72, 170),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins'),
      ),
    );
  }
}

class titles3 extends StatelessWidget {
  const titles3({
    super.key,
    required this.width,
    required this.heading,
  });

  final double width;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 20,
      width: width,
      child: Text(
        heading,
        textAlign: TextAlign.end,
        style: const TextStyle(
            color: Color.fromARGB(221, 48, 72, 170),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins'),
      ),
    );
  }
}

void showAddItemWindow(
  BuildContext context,
  int taxRate,
  Function set,
  int index,
  bool update,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AddDialog(
        update: update,
        context,
        index,
        taxRate: taxRate,
        stateFn: set,
      );
    },
  );
}

class AddDialog extends StatefulWidget {
  AddDialog(BuildContext context, this.index,
      {super.key,
      required this.stateFn,
      required this.update,
      required this.taxRate});
  Function stateFn;
  int index;
  int taxRate;
  bool update;

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController descController = TextEditingController(text: "");
  TextEditingController hsnController = TextEditingController(text: "");
  TextEditingController qtyController = TextEditingController(text: "1");
  TextEditingController rateController = TextEditingController(text: "");
  TextEditingController amountController = TextEditingController(text: "");
  TextEditingController totalAmountController = TextEditingController(text: "");
  bool checkState = false, tick = true;
  File file = File('Database/Invoices/tempInvoice.json');
  File products = File('Database/Products/products.json');
  @override
  void initState() {
    changeContent(file);
    super.initState();
  }

  void changeState(val) {
    setState(() {
      checkState = !checkState;
    });
  }

  void changeContent(File file) {
    if (widget.index != 45555) {
      dynamic content = file.readAsStringSync();
      content = jsonDecode(content);
      nameController.text = content['items'][widget.index]['name'];
      descController.text = content['items'][widget.index]['desc'];
      hsnController.text = content['items'][widget.index]['hsn'];
      qtyController.text = content['items'][widget.index]['qty'];
      rateController.text = content['items'][widget.index]['rate'];
      amountController.text = content['items'][widget.index]['amount'];
    }
  }

  void change() {
    widget.stateFn();
  }

  String rateValue = "", amountValue = "", rateValue2 = "", amountValue2 = "";
  void updateAmount() {
    amountController.text = formatIntegerToIndian(
            (convertIndianFormattedStringToNumber(rateController.text) *
                convertIndianFormattedStringToNumber(qtyController.text)))
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    File tempList = file;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      shadowColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: Container(
          // color: Colors.white,
          width: 600,
          height: 790,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.update ? "Update Product Entry" : "Add a Product",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 21),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ItemTextField(updateAmount, nameController, descController,
                      hsnController, rateController),
                  const SizedBox(
                    height: 20,
                  ),
                  AddItemRow(
                      text: "Product",
                      controller: nameController,
                      max: 1,
                      enabled: true),
                  AddItemRow(
                      text: "Specs",
                      controller: descController,
                      max: 3,
                      enabled: true),
                  AddItemRow(
                      text: "HSN Code",
                      controller: hsnController,
                      max: 1,
                      enabled: true),
                  QuantityRow(
                      taxRate: widget.taxRate,
                      checkState: checkState,
                      totalAmountController: totalAmountController,
                      autoCalc: checkState,
                      text: "Quantity",
                      controller: qtyController,
                      rateController: rateController,
                      amountController: amountController,
                      max: 1,
                      enabled: true),
                  RateRow(
                      taxRate: widget.taxRate,
                      tick: tick,
                      text: "Rate",
                      controller: rateController,
                      controller2: amountController,
                      controller3: qtyController,
                      max: 1,
                      enabled: !checkState),
                  AmountRow(
                      taxRate: widget.taxRate,
                      totalAmountController: totalAmountController,
                      text: !checkState ? "Total Amount" : "Amount(Per Pc)",
                      controller: amountController,
                      max: 1,
                      enabled: checkState,
                      rateController: rateController,
                      qtyController: qtyController),
                  TotalAmount(
                      taxRate: widget.taxRate,
                      checkState: checkState,
                      controller: totalAmountController,
                      amountController: amountController,
                      rateController: rateController,
                      qtyController: qtyController),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Auto-Calculate Rate: ",
                        style: TextStyle(
                            color: Color.fromARGB(255, 86, 86, 86),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                      ),
                      Checkbox(
                          activeColor: ColorPalette.blueAccent,
                          value: checkState,
                          onChanged: (value) {
                            if (!checkState) {
                              rateValue = rateController.text;
                              amountController.text = amountValue;
                              rateController.clear();
                            } else {
                              amountValue = amountController.text;
                              rateController.text = rateValue;
                              amountController.clear();
                            }
                            changeState(value);
                          }),
                    ],
                  )
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
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xff3049AA))),
                            onPressed: () {
                              if (nameController.text == "" ||
                                  hsnController == "" ||
                                  rateController.text == "" ||
                                  amountController.text == "") {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Container(
                                            height: 170,
                                            width: 350,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 13.0,
                                                      horizontal: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 21),
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.grey,
                                                              ))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Text(
                                                            "Please Enter All Parameters",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        89,
                                                                        89,
                                                                        89),
                                                                fontFamily:
                                                                    'Poppins'),
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
                                                                          BorderRadius.circular(
                                                                              5))),
                                                              backgroundColor:
                                                                  const WidgetStatePropertyAll(
                                                                      Color(
                                                                          0xff3049AA))),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        14.0),
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
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
                                writeToProductList(
                                    product: products,
                                    index: widget.index,
                                    update: widget.update,
                                    check: checkState,
                                    file: tempList,
                                    tax: widget.taxRate,
                                    auto: checkState,
                                    nameController: nameController,
                                    descController: descController,
                                    hsnController: hsnController,
                                    qtyController: qtyController,
                                    rateController: rateController,
                                    amountController: amountController,
                                    totalAmountController:
                                        totalAmountController);

                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  change();
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 30),
                              child: Text(
                                widget.update ? "Update" : "Add",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ))
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

Widget TotalAmount(
    {required bool checkState,
    required int taxRate,
    required TextEditingController controller,
    required TextEditingController rateController,
    required TextEditingController qtyController,
    required TextEditingController amountController}) {
  if (checkState) {
    return AmountStateful(
        taxRate: taxRate,
        totalAmountController: controller,
        text: "Total Amount",
        controller: controller,
        rateController: rateController,
        qtyController: qtyController,
        max: 1,
        enabled: false);
  } else {
    return const SizedBox();
  }
}

Widget ItemTextField(
    Function updateAmount,
    TextEditingController nameController,
    TextEditingController descController,
    TextEditingController hsnController,
    TextEditingController rateController) {
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
        Future.delayed(const Duration(milliseconds: 10), () {
          updateAmount();
        });
      },
    ),
  );
}

Widget RateRow({
  required bool tick,
  required String text,
  required int taxRate,
  required TextEditingController controller,
  required TextEditingController controller2,
  required TextEditingController controller3,
  required int max,
  required bool enabled,
}) {
  return RateRowS(
    text: text,
    controller: controller,
    max: max,
    taxRate: taxRate,
    enabled: enabled,
    controller2: controller2,
    controller3: controller3,
    tick: tick,
  );
}

Widget AddItemRow({
  required String text,
  required TextEditingController controller,
  required int max,
  required bool enabled,
}) {
  return Column(
    children: [
      const SizedBox(
        height: 10,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "$text :",
                style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 86, 86, 86),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'),
              ),
            ],
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
              constraints: const BoxConstraints(maxWidth: 330),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(32, 226, 226, 226),
                  borderRadius: BorderRadius.circular(9)),
              child: TextField(
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color.fromARGB(255, 86, 86, 86),
                    fontSize: 14),
                mouseCursor:
                    !enabled ? MouseCursor.defer : MouseCursor.uncontrolled,
                controller: controller,
                readOnly: !enabled,
                maxLines: text == "Specs" ? 3 : max,
                minLines: text == "Specs" ? 3 : 1,
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    label: const Text(""),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(144, 158, 158, 158))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: !enabled
                                ? const Color.fromARGB(144, 158, 158, 158)
                                : const Color.fromARGB(255, 14, 44, 180))),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none)),
              ))
        ],
      ),
    ],
  );
}

Widget AmountRow({
  required String text,
  required int taxRate,
  required TextEditingController controller,
  required TextEditingController rateController,
  required TextEditingController qtyController,
  required TextEditingController totalAmountController,
  required int max,
  required bool enabled,
}) {
  return AmountStateful(
      totalAmountController: totalAmountController,
      text: text,
      taxRate: taxRate,
      controller: controller,
      rateController: rateController,
      qtyController: qtyController,
      max: max,
      enabled: enabled);
}

Widget QuantityRow({
  required bool checkState,
  required String text,
  required int taxRate,
  required TextEditingController controller,
  required TextEditingController rateController,
  required TextEditingController amountController,
  required TextEditingController totalAmountController,
  required int max,
  required bool enabled,
  required bool autoCalc,
}) {
  return QuantityStatefulWidget(
    taxRate: taxRate,
    checkState: checkState,
    totalAmountController: totalAmountController,
    autoCalc: autoCalc,
    rateController: rateController,
    amountController: amountController,
    text: text,
    controller: controller,
    max: max,
    enabled: enabled,
  );
}

void writeToProductList({
  required int index,
  required bool check,
  required File file,
  required File product,
  required bool update,
  required TextEditingController nameController,
  required bool auto,
  required int tax,
  required TextEditingController descController,
  required TextEditingController hsnController,
  required TextEditingController qtyController,
  required TextEditingController rateController,
  required TextEditingController amountController,
  required TextEditingController totalAmountController,
}) {
  File tempList = file;
  File products = product;
  dynamic productContent = products.readAsStringSync();
  productContent = jsonDecode(productContent);
  if (!productContent.keys.toList().contains(nameController.text)) {
    dynamic entry = {
      nameController.text: {
        'name': nameController.text,
        'desc': descController.text,
        'hsn': hsnController.text,
        'rate': rateController.text
      }
    };
    appendKey(
        name: 'products.json', folder: 'Products', content: jsonEncode(entry));
  }
  dynamic fileContent = tempList.readAsStringSync();
  fileContent = jsonDecode(fileContent);
  List decoded = fileContent['items'];
  Map productRow = {
    "name": nameController.text,
    "desc": descController.text,
    "hsn": hsnController.text,
    "qty": qtyController.text,
    'rate': rateController.text,
    "amount": check ? totalAmountController.text : amountController.text,
    "auto": auto,
    "tax": tax,
    "amountpp": amountController.text
  };

  if (update) {
    decoded[index] = productRow;
  } else {
    decoded.add(productRow);
  }
  Map newmap = {"items": decoded};
  file.writeAsStringSync(jsonEncode(newmap));
}
