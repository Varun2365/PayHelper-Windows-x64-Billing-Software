// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:billing/InvoicesPageSection/InvoicePageLarge.dart';
import 'package:billing/colors.dart';
import 'package:billing/components/addItemComponenets.dart';
import 'package:flutter/material.dart';

class ProductsPageLarge extends StatefulWidget {
  const ProductsPageLarge({super.key});

  @override
  State<ProductsPageLarge> createState() => _ProductsPageLargeState();
}

class _ProductsPageLargeState extends State<ProductsPageLarge> {
  List availableProducts = [];
  dynamic productsContent;
  void refresh() {
    stateFn();
  }

  void stateFn() {
    setState(() {
      File productsJSON = File("Database/Products/products.json");
      dynamic temp = productsJSON.readAsStringSync();
      productsContent = jsonDecode(temp);
      availableProducts = productsContent.keys.toList();
      availableProducts.sort();
    });
  }

  void setFn() {
    File productsJSON = File("Database/Products/products.json");
    productsContent = productsJSON.readAsStringSync();
    productsContent = jsonDecode(productsContent);
    availableProducts = productsContent.keys.toList();
    availableProducts.sort();
  }

  @override
  void initState() {
    setFn();
    super.initState();
  }

  void shuffleSuggestions(val) {
    val = val.toLowerCase();

    if (val == "") {
      setState(() {
        availableProducts = productsContent.keys.toList();
        availableProducts.sort();
      });
    } else {
      setState(() {
        val = val.toLowerCase();
        availableProducts = availableProducts
            .where((product) => product.toLowerCase().contains(val))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
    
    File textSize = File("Database/Firm/firmDetails.json");
    dynamic fileContent = textSize.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    int fontSizeSetting = int.parse(fileContent['FontSize']);
    double paraSize = 0.8 * fontSizeSetting;
    
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
            borderRadius: BorderRadius.circular(7)),
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
                  // Title and Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                text: "Products",
                                style: TextStyle(
                                    fontSize: fontSize * 1.8,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gilroy',
                                    color: ColorPalette.blueAccent,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7))),
                                  backgroundColor: WidgetStatePropertyAll(
                                      ColorPalette.blueAccent)),
                              onPressed: () {
                                showAddProductDialog(
                                    context: context, stateFn: stateFn);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Add New Product",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: paraSize),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.add,
                                        color: Colors.white, size: 18),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 12),
                          Tooltip(
                            message: "Refresh",
                            child: InkWell(
                                onTap: () {
                                  refresh();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: ColorPalette.blueAccent, width: 1.5),
                                    color: Colors.white,
                                  ),
                                  child: Icon(Icons.refresh,
                                      color: ColorPalette.blueAccent, size: 20),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: ColorPalette.offWhite.withOpacity(0.8),
                        width: 1,
                      ),
                      color: ColorPalette.offWhite.withOpacity(0.2),
                    ),
                    child: TextField(
                      onChanged: (v) {
                        shuffleSuggestions(v);
                      },
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: paraSize,
                        color: ColorPalette.darkBlue,
                      ),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          hintText: "Search by product name, description, or HSN...",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: paraSize,
                            color: Colors.grey.shade500,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: ColorPalette.blueAccent,
                                width: 1.5,
                              )),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14)),
                    ),
                  ),
                ],
              ),
            ),
            // Table Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 14),
              child: productTableHeader(),
            ),
            // Products List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
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
                child: availableProducts.isEmpty
                    ? Center(child: nullRecord3())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        itemCount: availableProducts.length,
                        itemBuilder: (BuildContext c, int i) {
                          dynamic temp =
                              productsContent[availableProducts[i]];
                          return productItemHeader(
                              stateFn: stateFn,
                              context: context,
                              sno: "${i + 1}",
                              name: availableProducts[i],
                              description: temp['desc'],
                              hsn: temp['hsn'],
                              rate: temp['rate']);
                        }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget productItemHeader(
    {required BuildContext context,
    required String sno,
    required String name,
    required String description,
    required String hsn,
    required String rate,
    required Function stateFn}) {
  return Column(
    children: [
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: (int.parse(sno) - 1) % 2 == 0
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
    // height: 40,
    // width: 1200,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        labeledSizedBoxColored(50, sno, false),
        labeledSizedBoxColored(300, name, true),
        labeledSizedBoxColored(300, description, false),
        labeledSizedBoxColored(200, hsn, false),
        labeledSizedBoxColored(200, "₹ $rate", false),
        SizedBox(
          width: 200,
          child: Row(
            children: [
              Tooltip(
                textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w100),
                message: "Edit: $name",
                child: InkWell(
                  onTap: () {
                    stateFn();
                    showEditProductDialog(
                        context: context, productKey: name, stateFn: stateFn);
                  },
                  child: Icon(
                    Icons.edit,
                    color: ColorPalette.blueAccent,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Tooltip(
                textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w100),
                message: "Delete",
                child: InkWell(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.white,
                            child: Container(
                                height: 170,
                                width: 380,
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
                                                "Deleting the product can't be undone",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
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
                                          TextButton(
                                              style: ButtonStyle(
                                                  overlayColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white),
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      3))),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.white)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.0),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 186, 25, 13)),
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          ElevatedButton(
                                              style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      3))),
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Color.fromARGB(255,
                                                              186, 25, 13))),
                                              onPressed: () async {
                                                stateFn();
                                                deleteProduct(name);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.0),
                                                child: Text(
                                                  "Delete",
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
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
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

Widget productTableHeader() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
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
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    // width: 1200,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        labledSizedBox(50, "S. No."),
        labledSizedBox(300, "Name"),
        labledSizedBox(300, "Description"),
        labledSizedBox(200, "HSN Code"),
        labledSizedBox(200, "Rate"),
        labledSizedBox(200, "Options"),
      ],
    ),
  );
}

Widget labledSizedBox(double width, String label) {
  return SizedBox(
    width: width,
    child: Text(
      label,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins'),
    ),
  );
}

Widget labeledSizedBoxColored(double width, String label, bool bold) {
  return SizedBox(
    width: width,
    child: Text(
      label,
      style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 14,
          fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
          fontFamily: 'Poppins'),
    ),
  );
}

showAddProductDialog(
    {required BuildContext context, required Function stateFn}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return AddProductDialog(
          stateFn: stateFn,
        );
      });
}

class AddProductDialog extends StatefulWidget {
  Function stateFn;
  AddProductDialog({super.key, required this.stateFn});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController hsnController = TextEditingController();
  TextEditingController rateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      insetAnimationDuration: const Duration(milliseconds: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
        ),
        height: 470,
        width: 670,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              width: 700,
              height: 70,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(57, 191, 191, 191),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7))),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Product To Database",
                    style: TextStyle(
                        fontSize: 23,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color.fromARGB(255, 207, 207, 207),
                      child: Icon(
                        Icons.close,
                        color: ColorPalette.dark,
                      ),
                    ),
                  )
                ],
              )),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      addProductTextField(
                          context: context,
                          label: "Name",
                          controller: nameController),
                      addProductTextField(
                          context: context,
                          label: "Description",
                          controller: descController,
                          max: true),
                      addProductTextField(
                          context: context,
                          label: "HSN Code",
                          controller: hsnController),
                      addProductTextField(
                          context: context,
                          label: "Rate",
                          controller: rateController,
                          rate: true),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(ColorPalette.dark),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3)))),
                              onPressed: () {
                                if (nameController.text == "" ||
                                    hsnController.text == "" ||
                                    rateController.text == "") {
                                  showAlert(context,
                                      "Please enter all required fields");
                                } else {
                                  rateController.text = formatIntegerToIndian(
                                      convertIndianFormattedStringToNumber(
                                          rateController.text));

                                  File products =
                                      File("Database/Products/products.json");
                                  dynamic pc = products.readAsStringSync();
                                  pc = jsonDecode(pc);
                                  List keys = pc.keys.toList();
                                  if (keys.contains(nameController.text)) {
                                    showAlert(context,
                                        "This Product Name Entry Already Exists");
                                  } else {
                                    dynamic content = {
                                      "name": nameController.text,
                                      "desc": descController.text,
                                      "hsn": hsnController.text,
                                      "rate": rateController.text
                                    };
                                    pc[nameController.text] = content;
                                    products.writeAsStringSync(jsonEncode(pc));
                                    Navigator.of(context).pop();
                                    widget.stateFn();
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  "Add",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

Widget addProductTextField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  bool? max,
  bool? rate,
  bool? disabled,
}) {
  return Column(
    children: [
      SizedBox(
        // color: Colors.amber,
        height: max == null ? 40 : 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 130,
              child: Column(
                mainAxisAlignment: max == null
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: max == null ? 10 : 0,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Tooltip(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 137, 14, 6)),
              message: disabled != null ? "Can't Edit Name" : "",
              child: TextField(
                onSubmitted: (v) {
                  if (rate != null) {
                    controller.text = formatIntegerToIndian(
                        convertIndianFormattedStringToNumber(controller.text));
                  }
                },
                onTap: () {
                  // ignore: unnecessary_null_comparison
                  if (rate != null && controller.text != null) {
                    // controller.text = convertIndianFormattedStringToNumber(controller.text).toString();
                  }
                },
                autofocus: label == "Name" ? true : false,
                readOnly: disabled != null ? true : false,
                onTapOutside: (e) {
                  if (rate != null) {
                    controller.text = formatIntegerToIndian(
                        convertIndianFormattedStringToNumber(controller.text));
                  }
                  FocusScope.of(context).unfocus();
                },
                controller: controller,
                maxLines: max == null ? 1 : 5,
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: ColorPalette.dark, width: 0.8)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffA0A0A0), width: 0.4))),
              ),
            )),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      )
    ],
  );
}

void showAlert(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
              height: 170,
              width: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              message,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
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
                                            BorderRadius.circular(3))),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xff3049AA))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
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
}

void showEditProductDialog(
    {required BuildContext context,
    required String productKey,
    required Function stateFn}) {
  showDialog(
      context: context,
      builder: (c) {
        return EditProductDialog(
          productKey: productKey,
          stateFn: stateFn,
        );
      });
}

class EditProductDialog extends StatefulWidget {
  String productKey;
  Function stateFn;
  EditProductDialog(
      {super.key, required this.productKey, required this.stateFn});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController hsnController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  File p = File("Database/Products/products.json");
  @override
  void initState() {
    dynamic pc = p.readAsStringSync();
    pc = jsonDecode(pc);
    dynamic content = pc[widget.productKey];
    nameController.text = content['name'];
    descController.text = content['desc'];
    hsnController.text = content['hsn'];
    rateController.text = content['rate'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
        ),
        height: 470,
        width: 670,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              width: 700,
              height: 70,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(57, 191, 191, 191),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7))),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Product To Database",
                    style: TextStyle(
                        fontSize: 23,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color.fromARGB(255, 207, 207, 207),
                      child: Icon(
                        Icons.close,
                        color: ColorPalette.dark,
                      ),
                    ),
                  )
                ],
              )),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      addProductTextField(
                          disabled: true,
                          context: context,
                          label: "Name",
                          controller: nameController),
                      addProductTextField(
                          context: context,
                          label: "Description",
                          controller: descController,
                          max: true),
                      addProductTextField(
                          context: context,
                          label: "HSN Code",
                          controller: hsnController),
                      addProductTextField(
                          context: context,
                          label: "Rate",
                          controller: rateController,
                          rate: true),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(ColorPalette.dark),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3)))),
                              onPressed: () {
                                if (nameController.text == "" ||
                                    hsnController.text == "" ||
                                    rateController.text == "") {
                                  showAlert(context,
                                      "Please enter all required fields");
                                } else {
                                  File products =
                                      File("Database/Products/products.json");
                                  dynamic pc = products.readAsStringSync();
                                  pc = jsonDecode(pc);

                                  dynamic content = {
                                    "name": nameController.text,
                                    "desc": descController.text,
                                    "hsn": hsnController.text,
                                    "rate": rateController.text
                                  };
                                  pc[nameController.text] = content;
                                  products.writeAsStringSync(jsonEncode(pc));
                                  widget.stateFn();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

void deleteProduct(String productKey) {
  File p = File("Database/Products/products.json");
  dynamic pc = p.readAsStringSync();
  pc = jsonDecode(pc);
  pc.remove(productKey);
  p.writeAsStringSync(jsonEncode(pc));
}
