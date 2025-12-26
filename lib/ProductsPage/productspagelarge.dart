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
    return Container(
      color: ColorPalette.offWhite.withOpacity(0.5),
      padding: const EdgeInsets.only(top: 38, right: 30, left: 30),
      child: Container(
          padding: const EdgeInsets.only(top: 38, right: 30, left: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13), topRight: Radius.circular(13)),
          ),
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                          text: "All ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30)),
                      TextSpan(
                          text: "Products ",
                          style: TextStyle(
                              color: ColorPalette.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 30)),
                    ])),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey)),
                            height: 50,
                            width: 400,
                            child: TextField(
                              onChanged: (v) {
                                shuffleSuggestions(v);
                              },
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                              ),
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  label: Text("Type To Search Any Product"),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none)),
                            )),
                        const SizedBox(
                          width: 14,
                        ),
                        SizedBox(
                          height: 49,
                          child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      ColorPalette.blueAccent),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)))),
                              onPressed: () {
                                showAddProductDialog(
                                    context: context, stateFn: stateFn);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.0),
                                child: Text(
                                  "Add New Product",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Tooltip(
                          message: "Refresh",
                          child: InkWell(
                            onTap: () {
                              refresh();
                            },
                            child: const Icon(Icons.refresh),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                productTableHeader(),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: availableProducts.isEmpty
                      ? nullRecord3()
                      : ListView.builder(
                          itemCount: availableProducts.length,
                          shrinkWrap: true,
                          itemBuilder: (c, i) {
                            dynamic temp =
                                productsContent[availableProducts[i]];
                            return Column(
                              children: [
                                productItemHeader(
                                    stateFn: stateFn,
                                    context: context,
                                    sno: "${i + 1}",
                                    name: availableProducts[i],
                                    description: temp['desc'],
                                    hsn: temp['hsn'],
                                    rate: temp['rate']),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            );
                          }),
                )
              ],
            ),
          )),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: (int.parse(sno) - 1) % 2 == 0
          ? const Color.fromARGB(70, 215, 215, 215)
          : Colors.white,
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
  );
}

Widget productTableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: ColorPalette.blueAccent,
    ),
    height: 40,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
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
