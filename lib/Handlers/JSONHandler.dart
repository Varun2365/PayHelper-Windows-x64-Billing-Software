// ignore_for_file: file_names, empty_catches, non_constant_identifier_names, unused_import, sized_box_for_whitespace
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:billing/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:billing/components/pdfGenerator.dart';
import 'package:flutterbackgroundremover/backgroundremover.dart';
import 'package:indian_currency_to_word/indian_currency_to_word.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:qr_flutter/qr_flutter.dart';

//This section holds the code for creating a file system
//Requires Directories, and if not present, the directories will be created by their own
//The function below is used to create a new file and override an existing file
//It is currently designed to store files at Destination "Database/"
void createFile({
  required String name,
  required folder,
  String? content,
}) async {
  if (!Directory("Database/$folder").existsSync()) {
    createDirectory("Database/$folder");
  }
  if (!File("Database/$folder/$name").existsSync()) {
    File("Database/$folder/$name").create();
    if (content != null) {
      File("Database/$folder/$name").writeAsStringSync(content);
    }
  }
}

//The function below is functional for creating a New Directory in the current working directory
//Multi-purpose, not for a single directory,
//Takes root directory as the path where the .exe file is present
Future<bool> createDirectory(String directoryName) async {
  String directory = Directory.current.path;
  if (!Directory("$directory/$directoryName").existsSync()) {
    await Directory("$directory/$directoryName").create();
  }
  return true;
}

//THIS SECTION HOLDS THE FUNCTION USEFUL FOR WRITING CONTENT INTO THE FILE
void writeContent(
    {required String name,
    required String content,
    required String folder}) async {
  File file = File("Database/$folder/$name");
  await file.writeAsString(content);
}

void appendContent(
    {required String name,
    required String content,
    required String folder}) async {
  File file = File("Database/$folder/$name");
  String temp = await file.readAsString();
  temp += content;
  file.writeAsString(temp);
}

// THIS SECTION HOLDS THE FUNCTIONS WHICH ARE USEFUL FOR READING THE CONTENT FROM A FILE
String readContent({required String name, required String folder}) {
  return File("Database/$folder/$name").readAsStringSync();
}

dynamic readKey(
    {required String name, required String folder, required String key}) {
  if (!File("Database/$folder/$name").existsSync()) {
  } else {
    File file = File("Database/$folder/$name");
    dynamic fileContent = file.readAsStringSync();
    fileContent = jsonDecode(fileContent);
    return fileContent[key].toString();
  }
}

void appendKey(
    {required String name,
    required String folder,
    required String content}) async {
  if (!File("Database/$folder/$name").existsSync()) {
    await File("Database/$folder/$name").create();
  }
  File file = File("Database/$folder/$name");
  String fileContent = await file.readAsString();
  if (fileContent != "") {
    fileContent = fileContent.substring(
        fileContent.indexOf("{") + 1, fileContent.lastIndexOf("}"));
  }
  if (content[0] == "{" && content[content.length - 1] == "}") {
    content = content.substring(1, content.length - 1);
  }
  if (fileContent == "") {
    file.writeAsStringSync("{$content}");
  } else if (fileContent != "") {
    String newContent = "{$fileContent,$content}";
    file.writeAsString(newContent);
  }
}

void saveKey(
    {required String name, required String folder, required String value}) {
  appendContent(name: name, content: value, folder: folder);
}

String convertToIndianCurrencyWords(double amount) {
  final converter = AmountToWords();
// The number argument must be of type double.
  var number = amount;
  var word = converter.convertAmountToWords(number, ignoreDecimal: true);
  String temp = "";
  int space = 0;

  for (var i = 0; i < word.length; i++) {
    if (word[i] != " ") {
      temp += word[i];
      space = 0;
    } else {
      if (space == 1) {
        continue;
      } else {
        temp += word[i];
        space++;
      }
    }
  }
  word = temp;

  return word;
}

String formatPath(String temp) {
  List<String> pathSegments = temp.split("\\");

  for (int i = 0; i < pathSegments.length; i++) {
    if (pathSegments[i].contains(" ")) {
      pathSegments[i] = '"${pathSegments[i]}"';
    }
  }

  String formattedPath = pathSegments.join("\\");

  return formattedPath;
}

Future<int> WritePDFContent({
  required TextEditingController nameController,
  required TextEditingController poController,
  required TextEditingController partyController,
  required TextEditingController GSTController,
  required TextEditingController ShippingController,
  required TextEditingController InvoiceController,
  required TextEditingController DateController,
  required TextEditingController place,
  required TextEditingController GRController,
  required TextEditingController contactController,
  required TextEditingController TransportController,
  required TextEditingController VehicleController,
  required TextEditingController stationController,
  required TextEditingController EWayController,
  required List productList,
  required bool igst,
  required String cgst,
  required String sgst,
  required String grandTotal,
  required String grandTotalInWords,
  required String TaxRate,
  required String TaxAmount,
  required String igstV,
  required String TotalTax,
}) async {
  Map content = {
    "BillingName": partyController.text,
    "BillingAdd": "${nameController.text}\nPh: ${contactController.text}",
    "BillingGST": GSTController.text,
    "ShippingAdd": "${ShippingController.text}\nPh: ${contactController.text}",
    "InvoiceNo": InvoiceController.text,
    "Date": DateController.text,
    "Place": stationController.text,
    "GR": GRController.text,
    "PO": poController.text,
    "Contact": contactController.text,
    "Transport": TransportController.text,
    "Vehicle": VehicleController.text,
    "Station": stationController.text,
    "Eway": EWayController.text,
    "Products": productList,
    "igst": igst,
    "cgst": cgst,
    "sgst": sgst,
    "igstV": igstV,
    "grandtotal": grandTotal,
    "grandTotalInWords": grandTotalInWords,
    "TaxRate": TaxRate,
    "TaxAmount": TaxAmount,
    "TotalTax": TotalTax
  };
  File tempPdf = File("Database/Invoices/tempPdf.json");
  await tempPdf.writeAsString(jsonEncode(content));
  return 1;
}

AddInvoiceRecord({
  required Function onFileChange,
  required TextEditingController nameController,
  required TextEditingController partyController,
  required TextEditingController GSTController,
  required TextEditingController ShippingController,
  required TextEditingController InvoiceController,
  required TextEditingController DateController,
  required TextEditingController place,
  required TextEditingController GRController,
  required TextEditingController contactController,
  required TextEditingController TransportController,
  required TextEditingController VehicleController,
  required TextEditingController stationController,
  required TextEditingController EWayController,
  required TextEditingController poController,
  required List productList,
  required bool igst,
  required String cgst,
  required String sgst,
  required String grandTotal,
  required String grandTotalInWords,
  required String TaxRate,
  required String TaxAmount,
  required String igstV,
  required String TotalTax,
}) async {
  Map content = {
    InvoiceController.text: {
      "BillingName": partyController.text,
      "BillingAdd": nameController.text,
      "BillingGST": GSTController.text,
      "ShippingAdd": ShippingController.text,
      "InvoiceNo": InvoiceController.text,
      "Date": DateController.text,
      "Place": stationController.text,
      "GR": GRController.text,
      "PO": poController.text,
      "Transport": TransportController.text,
      "Vehicle": VehicleController.text,
      "Station": stationController.text,
      "Contact": contactController.text,
      "Eway": EWayController.text,
      "Products": productList,
      "igst": igst,
      "cgst": cgst,
      "sgst": sgst,
      "igstV": igstV,
      "grandtotal": grandTotal,
      "grandTotalInWords": grandTotalInWords,
      "TaxRate": TaxRate,
      "TaxAmount": TaxAmount,
      "TotalTax": TotalTax
    }
  };

  File invoices = File("Database/Invoices/Invoices.json");
  dynamic contentt = invoices.readAsStringSync();
  contentt = jsonDecode(contentt);
  int length = 20;
  dynamic temp = {};
  if (contentt.length < length) {
    appendKey(
        name: 'Invoices.json',
        content:
            jsonEncode(content).substring(1, jsonEncode(content).length - 1),
        folder: "Invoices");
  } else {
    var keys = contentt.keys.toList();
    keys = keys.reversed;
    keys = keys.toList();

    for (var i = length - 1; i >= 0; i--) {
      temp[keys[i].toString()] = contentt[keys[i].toString()];
    }
    invoices.writeAsStringSync(jsonEncode(temp));
    appendKey(
        name: 'Invoices.json',
        content:
            jsonEncode(content).substring(1, jsonEncode(content).length - 1),
        folder: "Invoices");
  }
  onFileChange();
}

AddInvoice({
  required Function onFileChange,
  required TextEditingController nameController,
  required TextEditingController poController,
  required TextEditingController partyController,
  required TextEditingController GSTController,
  required TextEditingController ShippingController,
  required TextEditingController InvoiceController,
  required TextEditingController DateController,
  required TextEditingController place,
  required TextEditingController GRController,
  required TextEditingController contactController,
  required TextEditingController TransportController,
  required TextEditingController VehicleController,
  required TextEditingController stationController,
  required TextEditingController EWayController,
  required List productList,
  required bool igst,
  required String cgst,
  required String sgst,
  required String grandTotal,
  required String grandTotalInWords,
  required String TaxRate,
  required String TaxAmount,
  required String igstV,
  required String TotalTax,
}) async {
  Map content = {
    "BillingName": partyController.text,
    "BillingAdd": nameController.text,
    "BillingGST": GSTController.text,
    "ShippingAdd": ShippingController.text,
    "InvoiceNo": InvoiceController.text,
    "Date": DateController.text,
    "Place": stationController.text,
    "GR": GRController.text,
    "PO": poController.text,
    "Transport": TransportController.text,
    "Vehicle": VehicleController.text,
    "Station": stationController.text,
    "Contact": contactController.text,
    "Eway": EWayController.text,
    "Products": productList,
    "igst": igst,
    "cgst": cgst,
    "sgst": sgst,
    "igstV": igstV,
    "grandtotal": grandTotal,
    "grandTotalInWords": grandTotalInWords,
    "TaxRate": TaxRate,
    "TaxAmount": TaxAmount,
    "TotalTax": TotalTax
  };
  File invoices = File("Database/Invoices/In.json");
  dynamic contentt = invoices.readAsStringSync();
  contentt = jsonDecode(contentt);
  contentt[getYear(DateController.text)] ??= {};
  contentt[getYear(DateController.text)][getMonth(DateController.text)] ??= {};
  contentt[getYear(DateController.text)][getMonth(DateController.text)]
      [InvoiceController.text] ??= {};
  contentt[getYear(DateController.text)][getMonth(DateController.text)]
      [InvoiceController.text] = content;
  invoices.writeAsStringSync(jsonEncode(contentt));
  onFileChange();
}

String getYear(dynamic date) {
  date = date.split("/");
  return date[2];
}

String getMonth(dynamic date) {
  date = date.split("/");
  return date[1].length == 1 ? "0${date[1]}" : date[1];
}

DateTime formatDate(String date) {
  List dateL = date.split("/");
  return DateTime(
      int.parse(dateL[2]), int.parse(dateL[1]), int.parse(dateL[0]));
}

double getRootFontSize() {
  double fontSize;
  File file = File("Database/Firm/firmDetails.json");
  dynamic content = file.readAsStringSync();
  content = jsonDecode(content);
  fontSize = double.parse(content['FontSize']);
  return fontSize;
}

void resetInvoiceOnNewFinancialYear() {
  DateTime currentDate = DateTime.now();
  if (currentDate.day == 1 && currentDate.month == 11) {
    File invoiceNumber = File("Database/Invoices/InvoiceNumber.txt");
    dynamic content = invoiceNumber.readAsStringSync();
    content = int.parse(content);
    ++content;
    invoiceNumber.writeAsStringSync(content.toString());
  }
}

void deleteLastInvoice(BuildContext context) {
  File invoices = File("Database/Invoices/Invoices.json");
  File inj = File("Database/Invoices/In.json");

  dynamic invoiceContent = invoices.readAsStringSync();
  dynamic invoiceContent2 = inj.readAsStringSync();
  invoiceContent = jsonDecode(invoiceContent);
  invoiceContent2 = jsonDecode(invoiceContent2);

  List lastInvoices = invoiceContent.keys.toList();
  String date = invoiceContent[lastInvoices[lastInvoices.length - 1]]["Date"];
  List dateParticles = date.split("/").toList();
  log(dateParticles.toString());
  if (dateParticles[1].length == 1) {
    dateParticles[1] = "0${dateParticles[1]}";
  }

  invoiceContent2[dateParticles[2]][dateParticles[1]]
      .remove(lastInvoices[lastInvoices.length - 1]);
  invoiceContent.remove(lastInvoices[lastInvoices.length - 1]);
  invoices.writeAsStringSync(jsonEncode(invoiceContent));
  inj.writeAsStringSync(jsonEncode(invoiceContent2));

  //Reseting the invoice number to a previous state.
  File invoiceNumber = File("Database/Invoices/invoiceNumber.txt");
  dynamic ivn = invoiceNumber.readAsStringSync();
  ivn = int.parse(ivn);
  --ivn;
  invoiceNumber.writeAsStringSync(ivn.toString());
}

void deleteLastInvoiceDialog(context, Function set) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Container(
              height: 160,
              width: 400,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alert",
                          style: TextStyle(
                              fontSize: 27,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Are you sure to delete last invoice?",
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: const ButtonStyle(
                              splashFactory: NoSplash.splashFactory,
                              overlayColor:
                                  WidgetStatePropertyAll(Colors.white)),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            deleteLastInvoice(context);
                            set();
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(ColorPalette.dark),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)))),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
      });
}

Future<void> generateAndSaveQRCodeSimple(String data) async {
  try {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // ignore: prefer_const_constructors
    qrPainter.paint(canvas, Size(1080, 1080)); // Adjust size as needed.
    final picture = recorder.endRecording();

    final image = await picture.toImage(1080, 1080);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final cwd = Directory.current;
    final filePath = '${cwd.path}/tempqr.png';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);
  } catch (e) {}
}

Future<void> saveSignatureFile() async {
  FilePickerResult? path =
      await FilePicker.platform.pickFiles(type: FileType.image);
  log(path.runtimeType.toString());
  File signFile = File("Database/signFile.jpg");
  signFile.createSync();
  File selectedFile = File(path!.paths[0].toString());
  Uint8List data = selectedFile.readAsBytesSync();
  signFile.writeAsBytesSync(data);
}
