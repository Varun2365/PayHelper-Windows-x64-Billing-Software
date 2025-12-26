import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";
import "package:billing/Handlers/JSONHandler.dart";
import "package:billing/Pairs/largeScreenPair.dart";
import "package:billing/colors.dart";
import "package:flutter/material.dart";
import "package:billing/SplashScreen/splashScreen.dart";

void main() async {
  runApp(const AppEntry());
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  double _splashProgress = 0;
  Widget _currentScreen = const LoadingScreen(value: 0);
  bool _loadingComplete = false;

  Future<void> _initializeApp() async {
    final random = Random();
    List<double> targetValues = [0.2, 0.6, 0.8, 1.0];
    Map firmDetails = {
      "InvoicePrefix": " ",
      "DisplayName": "User 1",
      "FirmName": "Firm Name",
      "GSTNo": "Firm GST",
      "Address1": "-",
      "Address2": "-",
      "Address3": "-",
      "Contact": "",
      "Bank1": "-",
      "Bank2": "-",
      "Bank3": "-",
      "TNC1": "-",
      "TNC2": "-",
      "TNC3": "-",
      "TNC4": "-",
      "QRName": "XYZ",
      "QRUPI": "...",
      "FontSize": "17"
    };
    try {
      File signFile = File("Database/signFile.jpg");
      await createDirectory("Database");
      await createDirectory("Database/Party Records");
      await createDirectory("Database/PDF");
      await createDirectory("Database/Invoices");
      await createDirectory("Database/Firm");
      await createDirectory("Database/Products");
      if (!signFile.existsSync()) {
        await signFile.create();
      }
      createFile(name: "tempInvoice.json", folder: "Invoices");
      createFile(name: "Invoices.json", folder: "Invoices", content: "{}");
      createFile(
          name: "firmDetails.json",
          folder: "Firm",
          content: jsonEncode(firmDetails));
      createFile(name: "purchase.json", folder: "Invoices", content: "{}");
      createFile(name: "invoiceNumber.txt", folder: "Invoices", content: "1");
      createFile(name: "products.json", folder: "Products", content: "{}");
      createFile(
          name: "tempPurchase.json",
          folder: "Invoices",
          content: '{"items": []}');
      createFile(name: "In.json", folder: "Invoices", content: "{}");
      createFile(name: "Invoices.json", folder: "Invoices", content: "{}");
      createFile(name: "tempPdf.json", folder: "Invoices");
      createFile(name: "parties.json", folder: "Party Records", content: "{}");
      createFile(
          name: "purchaseParties.json", folder: "Party Records", content: "{}");
      createFile(
          name: "purchaseP arties.json",
          folder: "Party Records",
          content: "{}");
      createFile(name: "purchase.json", folder: "Party Records", content: "{}");
      createFile(name: "saveSettings.json", folder: "PDF", content: "{}");
      createFile(name: "uniqueid.txt", folder: "Invoices", content: "1");
      createFile(name: "products.json", folder: "Products");

      await Future.delayed(
          const Duration(milliseconds: 10)); // Initial small delay

      for (double target in targetValues) {
        int randomDelay = 150 + random.nextInt(700);
        await Future.delayed(Duration(milliseconds: randomDelay));
        setState(() {
          _splashProgress = target;
          _currentScreen = LoadingScreen(value: _splashProgress);
        });
      }

      await Future.delayed(const Duration(milliseconds: 100)); // Small pause

      setState(() {
        _loadingComplete = true;
      });
    } catch (e) {
      setState(() {
        _loadingComplete = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    Widget home = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1400) {
          return LargeScreenPair(
            fontSize: 19,
          );
        } else if (constraints.maxWidth <= 1279) {
          return Container(color: ColorPalette.offWhite);
        } else {
          return LargeScreenPair(fontSize: 19);
        }
      },
    );

    return MaterialApp(
        theme: ThemeData(
            scrollbarTheme: const ScrollbarThemeData(
                trackBorderColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 233, 233, 233)),
                thickness: WidgetStatePropertyAll(6),
                thumbColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 195, 195, 195)),
                trackVisibility: WidgetStatePropertyAll(true),
                radius: Radius.circular(4),
                thumbVisibility: WidgetStatePropertyAll(true)),
            textSelectionTheme: TextSelectionThemeData(
                selectionColor: ColorPalette.blueAccent.withOpacity(0.2)),
            datePickerTheme: const DatePickerThemeData(
                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
            fontFamily: "Gilroy"),
        debugShowCheckedModeBanner: false,
        home: Stack(
          children: [
            IgnorePointer(
              ignoring: _loadingComplete,
              child: AnimatedOpacity(
                opacity: _loadingComplete ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: _currentScreen, // The LoadingScreen
              ),
            ),
            IgnorePointer(
              ignoring: !_loadingComplete,
              child: AnimatedOpacity(
                opacity: _loadingComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: home, // The home screen
              ),
            ),
          ],
        ));
  }
}
