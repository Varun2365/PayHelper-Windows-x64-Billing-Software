// ignore_for_file: must_be_immutable, file_names, unused_local_variable
import "dart:convert";
import "dart:io";

import "package:billing/Settings%20Page/settingsPageLarge.dart";
import "package:billing/colors.dart";
import "package:billing/createInvoiceLayout.dart";
import "package:billing/editInvoiceLayout.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class LargeNavBar extends StatefulWidget {
  Function(int) onIndexChange;
  Function onFileChange;
  int pageIndex;
  double fontSize;
  LargeNavBar(
      {super.key,
      required this.onFileChange,
      required this.onIndexChange,
      required this.pageIndex,
      required this.fontSize});

  @override
  State<LargeNavBar> createState() => _LargeNavBarState();
}

class _LargeNavBarState extends State<LargeNavBar> {
  List<String> menuItems = [
    'Home',
    'Invoices',
    'Parties',
    "Reports",
    "Purchase",
    'Products'
  ];
  @override
  Widget build(BuildContext context) {
    File fd = File("Database/Firm/firmDetails.json");
    dynamic firmDetails = fd.readAsStringSync();
    firmDetails = jsonDecode(firmDetails);

    double renderFontSize = 0;
    renderFontSize = widget.fontSize;
    return Container(
      height: 180,
      width: double.infinity,
      color: ColorPalette.darkBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/billing.svg',
                      width: 55,
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    const Text(
                      "PayHelper",
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    // Container(
                    //   height: 49,
                    //   width: 370,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(5),
                    //       color: ColorPalette.offWhite.withOpacity(0.1)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 15),
                    //     child: Row(
                    //       children: [
                    //         SvgPicture.asset(
                    //           'assets/images/logo.svg',
                    //           height: 20,
                    //           fit: BoxFit.contain,
                    //         ),
                    //         const SizedBox(
                    //           width: 2,
                    //         ),
                    //         Expanded(
                    //             child: TextField(
                    //           cursorWidth: 1,
                    //           cursorColor: ColorPalette.blueAccent,
                    //           decoration: InputDecoration(
                    //               hintText: "Search...",
                    //               hintStyle: TextStyle(
                    //                   fontSize: 15,
                    //                   color: Colors.white.withOpacity(0.6),
                    //                   fontFamily: 'Poppins',
                    //                   fontWeight: FontWeight.w300),
                    //               border: const OutlineInputBorder(
                    //                   borderSide: BorderSide.none)),
                    //           style: TextStyle(
                    //               color: Colors.white.withOpacity(0.8),
                    //               fontWeight: FontWeight.w300,
                    //               fontFamily: 'Poppins',
                    //               fontSize: 15),
                    //         ))
                    //       ],
                    //     ),
                    //   ),
                    // )
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  barrierDismissible: true,
                                  builder: (context) {
                                    return const SettingsPageLarge();
                                  }));
                        },
                        child: SvgPicture.asset(
                          'assets/images/settings.svg',
                          height: 29,
                        )),
                    const SizedBox(
                      width: 17,
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 23,
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/images/avatar.jpg"),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      firmDetails['DisplayName'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 1000,
                      height: double.infinity,
                      child: ListView.builder(
                          itemCount: menuItems.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            // ignore: avoid_unnecessary_containers
                            return Container(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      widget.onIndexChange(index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        menuItems[index],
                                        style: TextStyle(
                                            color: index == widget.pageIndex
                                                ? Colors.white
                                                : Colors.grey,
                                            fontSize: 17,
                                            fontWeight:
                                                index == widget.pageIndex
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                            fontFamily: "Gilroy"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(1))),
                        height: 40,
                        width: 160,
                        child: TextButton(
                            style: ButtonStyle(
                                splashFactory: InkSplash.splashFactory,
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        4), // Adjust the radius as needed
                                  ),
                                ),
                                side: WidgetStatePropertyAll(BorderSide(
                                  color: ColorPalette.blueAccent,
                                )),
                                backgroundColor: WidgetStatePropertyAll(
                                    ColorPalette.blueAccent.withOpacity(0.1))),
                            onPressed: () {
                              _showCreateInvoiceWindow(
                                  context, widget.onFileChange);
                            },
                            child: const Text(
                              "Create Invoice",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 225, 225, 225),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            )))
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

void _showCreateInvoiceWindow(BuildContext context, Function changeFile) {
  showDialog(
    barrierColor: const Color.fromARGB(193, 0, 0, 0),
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetAnimationDuration: const Duration(milliseconds: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: Container(
          // color: Colors.white,
          width: 1100,
          height: 800,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CreateInvoiceLayout(
                onFileChange: changeFile,
              ), // Pass the context here
            ],
          ),
        ),
      );
    },
  );
}

void showEditInvoiceWindow(
    BuildContext context, String index, Function set, Function changeFile) {
  showDialog(
    barrierColor: const Color.fromARGB(193, 0, 0, 0),
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetAnimationDuration: const Duration(milliseconds: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: Container(
          // color: Colors.white,
          width: 1100,
          height: 800,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              EditInvoice(
                invoiceNo: index,
                set: set,
                onFileChange: changeFile,
              ), // Pass the context here
            ],
          ),
        ),
      );
    },
  );
}

void showEditInvoiceWindow2(BuildContext context, String index, String year,
    String month, Function set, Function changeFile) {
  showDialog(
    barrierColor: const Color.fromARGB(193, 0, 0, 0),
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetAnimationDuration: const Duration(milliseconds: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: Container(
          // color: Colors.white,
          width: 1100,
          height: 800,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              EditInvoice2(
                month: month,
                year: year,
                invoiceNo: index,
                set: set,
                onFileChange: changeFile,
              ), // Pass the context here
            ],
          ),
        ),
      );
    },
  );
}
