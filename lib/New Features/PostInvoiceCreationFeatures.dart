import 'dart:convert';
import 'dart:io';

import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/colors.dart';
import 'package:flutter/material.dart';

// This function is responsible for showing a dialog box
// that asks for Number of Copies of the Invoice, and
// wheather the invoice should be digitally signed or not
void showPostInvoiceCreationFeatures(context, Function savePDF) {
  showDialog(
      context: context,
      builder: (context) {
        return PostInvoiceCreationDialog(savePDF: savePDF);
      });
}

void showPostInvoiceCreationFeaturesHome(
    context, Function savePDF, dynamic content) {
  showDialog(
      context: context,
      builder: (context) {
        return PostInvoiceCreationDialogHome(
          savePDF: savePDF,
          content: content,
        );
      });
}

void showPostInvoiceCreationFeaturesInvoice(
    context, Function savePDF, String year, String month, String sno) {
  showDialog(
      context: context,
      builder: (context) {
        return PostInvoiceCreationDialogInvoice(
          savePDF: savePDF,
          year: year,
          month: month,
          sno: sno,
        );
      });
}

class PostInvoiceCreationDialogInvoice extends StatefulWidget {
  Function savePDF;

  String year, month, sno;
  PostInvoiceCreationDialogInvoice(
      {super.key,
      required this.savePDF,
      required this.year,
      required this.month,
      required this.sno});

  @override
  State<PostInvoiceCreationDialogInvoice> createState() =>
      PostInvoiceCreationDialogInvoiceState();
}

class PostInvoiceCreationDialogInvoiceState
    extends State<PostInvoiceCreationDialogInvoice> {
  int numberOfCopies = 1;
  bool digitalSign = false;
  bool addPaymentQR = false;
  String message = "";
  TextEditingController numberOfCopiesController = TextEditingController();

  @override
  void initState() {
    numberOfCopiesController.text = numberOfCopies.toString();
    super.initState();
  }

  bool checkSignFileCondition() {
    File signFile = File("Database/signFile.jpg");
    if (signFile.existsSync()) {
      var temp = signFile.readAsStringSync();
      if (temp.length != 0) {
        return true;
      }
    }
    return false;
  }

  void addCopies() {
    setState(() {
      if (numberOfCopies < 10) {
        numberOfCopies++;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  void subCopies() {
    setState(() {
      if (numberOfCopies > 1) {
        numberOfCopies--;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        height: 290,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saving Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "No. of Copies : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 200,
                      child: TextField(
                        enabled: true,
                        controller: numberOfCopiesController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(144, 158, 158, 158))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 14, 44, 180))),
                          prefixIcon: InkWell(
                            onTap: subCopies,
                            child: const Icon(
                              Icons.remove,
                              color: Color.fromARGB(255, 49, 49, 49),
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: addCopies,
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 41, 41, 41),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Digitally Sign : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: digitalSign,
                        onChanged: (v) {
                          if (checkSignFileExists() ==
                              "Upload A Signature File First") {
                            setState(() {
                              message = checkSignFileExists();
                            });
                            saveSignatureFile();
                          } else {
                            setState(() {
                              message = "";
                              digitalSign = !digitalSign;
                            });
                          }
                        })
                  ],
                ),
                Text(
                  message,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.red, fontSize: 12),
                ),
                SizedBox(
                  height: message != "" ? 10 : 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Payment QR : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: addPaymentQR,
                        onChanged: (v) {
                          setState(() {
                            addPaymentQR = !addPaymentQR;
                          });
                        })
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xff3049AA)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    onPressed: () {
                      File settings = File("Database/PDF/saveSettings.json");
                      Map settingsMap = {
                        "copies": numberOfCopies,
                        "sign": digitalSign,
                        "qr": addPaymentQR
                      };
                      settings.writeAsStringSync(jsonEncode(settingsMap));
                      widget.savePDF(
                          context, widget.year, widget.month, widget.sno);

                      Navigator.of(context).pop();
                      // Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PostInvoiceCreationDialogHome extends StatefulWidget {
  Function savePDF;
  dynamic content;
  PostInvoiceCreationDialogHome(
      {super.key, required this.savePDF, required this.content});

  @override
  State<PostInvoiceCreationDialogHome> createState() =>
      PostInvoiceCreationDialogHomeState();
}

class PostInvoiceCreationDialogHomeState
    extends State<PostInvoiceCreationDialogHome> {
  int numberOfCopies = 1;
  bool digitalSign = false;
  bool addPaymentQR = false;
  String message = "";
  TextEditingController numberOfCopiesController = TextEditingController();

  @override
  void initState() {
    numberOfCopiesController.text = numberOfCopies.toString();
    super.initState();
  }

  bool checkSignFileCondition() {
    File signFile = File("Database/signFile.jpg");
    if (signFile.existsSync()) {
      var temp = signFile.readAsStringSync();
      if (temp.length != 0) {
        return true;
      }
    }
    return false;
  }

  void addCopies() {
    setState(() {
      if (numberOfCopies < 10) {
        numberOfCopies++;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  void subCopies() {
    setState(() {
      if (numberOfCopies > 1) {
        numberOfCopies--;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        height: 290,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saving Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "No. of Copies : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 200,
                      child: TextField(
                        enabled: true,
                        controller: numberOfCopiesController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(144, 158, 158, 158))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 14, 44, 180))),
                          prefixIcon: InkWell(
                            onTap: subCopies,
                            child: const Icon(
                              Icons.remove,
                              color: Color.fromARGB(255, 49, 49, 49),
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: addCopies,
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 41, 41, 41),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Digitally Sign : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: digitalSign,
                        onChanged: (v) {
                          if (checkSignFileExists() ==
                              "Upload A Signature File First") {
                            setState(() {
                              message = checkSignFileExists();
                            });
                            saveSignatureFile();
                          } else {
                            setState(() {
                              message = "";
                              digitalSign = !digitalSign;
                            });
                          }
                        })
                  ],
                ),
                Text(
                  message,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.red, fontSize: 12),
                ),
                SizedBox(
                  height: message != "" ? 10 : 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Payment QR : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: addPaymentQR,
                        onChanged: (v) {
                          setState(() {
                            addPaymentQR = !addPaymentQR;
                          });
                        })
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xff3049AA)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    onPressed: () {
                      File settings = File("Database/PDF/saveSettings.json");
                      Map settingsMap = {
                        "copies": numberOfCopies,
                        "sign": digitalSign,
                        "qr": addPaymentQR
                      };
                      settings.writeAsStringSync(jsonEncode(settingsMap));
                      widget.savePDF(context, widget.content);

                      Navigator.of(context).pop();
                      // Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PostInvoiceCreationDialog extends StatefulWidget {
  Function savePDF;
  PostInvoiceCreationDialog({super.key, required this.savePDF});

  @override
  State<PostInvoiceCreationDialog> createState() =>
      PostInvoiceCreationDialogState();
}

class PostInvoiceCreationDialogState extends State<PostInvoiceCreationDialog> {
  int numberOfCopies = 1;
  bool digitalSign = false;
  bool addPaymentQR = false;
  String message = "";
  TextEditingController numberOfCopiesController = TextEditingController();

  @override
  void initState() {
    numberOfCopiesController.text = numberOfCopies.toString();
    super.initState();
  }

  bool checkSignFileCondition() {
    File signFile = File("Database/signFile.jpg");
    if (signFile.existsSync()) {
      var temp = signFile.readAsStringSync();
      if (temp.length != 0) {
        return true;
      }
    }
    return false;
  }

  void addCopies() {
    setState(() {
      if (numberOfCopies < 10) {
        numberOfCopies++;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  void subCopies() {
    setState(() {
      if (numberOfCopies > 1) {
        numberOfCopies--;
        numberOfCopiesController.text = numberOfCopies.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        height: 290,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saving Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "No. of Copies : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 200,
                      child: TextField(
                        enabled: true,
                        controller: numberOfCopiesController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(144, 158, 158, 158))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 14, 44, 180))),
                          prefixIcon: InkWell(
                            onTap: subCopies,
                            child: const Icon(
                              Icons.remove,
                              color: Color.fromARGB(255, 49, 49, 49),
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: addCopies,
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 41, 41, 41),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Digitally Sign : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: digitalSign,
                        onChanged: (v) {
                          if (checkSignFileExists() ==
                              "Upload A Signature File First") {
                            setState(() {
                              message = checkSignFileExists();
                            });
                            saveSignatureFile();
                          } else {
                            setState(() {
                              message = "";
                              digitalSign = !digitalSign;
                            });
                          }
                        })
                  ],
                ),
                Text(
                  message,
                  style: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.red, fontSize: 12),
                ),
                SizedBox(
                  height: message != "" ? 10 : 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Payment QR : ",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ColorPalette.darkBlue,
                          fontWeight: FontWeight.w500),
                    ),
                    Checkbox(
                        activeColor: const Color(0xff3049AA),
                        value: addPaymentQR,
                        onChanged: (v) {
                          setState(() {
                            addPaymentQR = !addPaymentQR;
                          });
                        })
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xff3049AA)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    onPressed: () {
                      File settings = File("Database/PDF/saveSettings.json");
                      Map settingsMap = {
                        "copies": numberOfCopies,
                        "sign": digitalSign,
                        "qr": addPaymentQR
                      };
                      settings.writeAsStringSync(jsonEncode(settingsMap));
                      widget.savePDF();

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

String checkSignFileExists() {
  File file = File("Database/signFile.jpg");
  dynamic content = file.readAsBytesSync();
  if (content.length == 0) {
    return "Please upload a signature file";
  } else {
    return "";
  }
}
