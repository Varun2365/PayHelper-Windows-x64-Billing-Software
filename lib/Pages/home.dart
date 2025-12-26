// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_build_context_synchronously, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:io';
import 'package:billing/Handlers/JSONHandler.dart';
import 'package:billing/NavBar/LargeNavbar.dart';
import 'package:billing/New%20Features/PostInvoiceCreationFeatures.dart';
import 'package:billing/PartiesPage/PartiesPageComponents/PartiesPageComponents.dart';
import 'package:billing/Settings%20Page/settingsPageLarge.dart';
import 'package:billing/components/savePDF.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:billing/colors.dart';
import 'package:billing/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfrx/pdfrx.dart';

class HomePageLarge extends StatefulWidget {
  Function setS;
  String invoices;
  Color color;
  HomePageLarge(
      {super.key,
      required this.invoices,
      required this.color,
      required this.setS});

  @override
  State<HomePageLarge> createState() => _HomePageLargeState();
}

class _HomePageLargeState extends State<HomePageLarge> {
  bool show = false;
  late dynamic keyss;
  late dynamic invoicesContent;
  File fd = File("Database/Firm/firmDetails.json");
  dynamic firmDetails;
  @override
  void initState() {
    firmDetails = fd.readAsStringSync();
    firmDetails = jsonDecode(firmDetails);
    super.initState();
  }

  void set() {
    setState(() {
      File file = File("Database/Invoices/tempPdf.json");

      file = File("Database/Invoices/Invoices.json");
      invoicesContent = file.readAsStringSync();
    });
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

    invoicesContent = widget.invoices;
    invoicesContent = jsonDecode(invoicesContent);
    keyss = invoicesContent.keys.toList();
    keyss = keyss.reversed;
    keyss = keyss.toList();
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: ColorPalette.offWhite.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: fontSize * 11.7,
                    width: width * .59,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(95, 207, 207, 207),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 2))
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 27),
                      child: keyss.length == 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "No Invoices Found",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          "assets/images/alert.png",
                                          height: 23,
                                        )
                                      ],
                                    ),
                                    const SelectableText(
                                      "Create an invoice to access settings",
                                      style: TextStyle(fontFamily: "Poppins"),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // SvgPicture.asset(
                                //   "assets/images/noInvoiceLast.svg",
                                //   height: 90,
                                // ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  keyss.length == 0
                                      ? "Create An Invoice to see Options"
                                      : "Last Invoice",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: fontSize * 1.3),
                                ),
                                SizedBox(
                                  height: keyss.length == 0 ? 0 : fontSize,
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                    text:
                                        keyss.length == 0 ? "" : "#${keyss[0]}",
                                    style: TextStyle(
                                        color: ColorPalette.blueAccent,
                                        fontSize: keyss.length == 0
                                            ? 0
                                            : fontSize * 1.8,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(
                                    // text: "On ",
                                    text: keyss.length == 0
                                        ? ""
                                        : " ${invoicesContent[keyss[0]]["BillingName"]} - On ${DateFormat.MMMEd().format(formatDate(invoicesContent[keyss[0]]["Date"]))}",
                                    style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 45, 45, 45),
                                      fontSize: keyss.length == 0
                                          ? 0
                                          : fontSize * 1.8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ])),
                                SizedBox(
                                  height: keyss.length == 0 ? 0 : 15,
                                ),
                                keyss.length != 0
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStatePropertyAll(
                                                              ColorPalette
                                                                  .darkBlue),
                                                      padding: WidgetStatePropertyAll(
                                                          EdgeInsets.symmetric(
                                                              horizontal: fontSize *
                                                                  2.7,
                                                              vertical: fontSize *
                                                                  1.2)),
                                                      side: const WidgetStatePropertyAll(BorderSide(
                                                          color: Colors.black)),
                                                      shape: const WidgetStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(Radius.circular(4))))),
                                                  onPressed: () {
                                                    showEditInvoiceWindow(
                                                        context,
                                                        keyss[0],
                                                        set,
                                                        widget.setS);
                                                  },
                                                  child: Text(
                                                    "Edit Invoice",
                                                    style: TextStyle(
                                                        fontSize: fontSize <= 14
                                                            ? fontSize
                                                            : 14,
                                                        color: Colors.white),
                                                  )),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              TextButton(
                                                  style: ButtonStyle(
                                                      splashFactory: NoSplash
                                                          .splashFactory,
                                                      backgroundColor: WidgetStatePropertyAll(
                                                          ColorPalette.white),
                                                      padding: WidgetStatePropertyAll(
                                                          EdgeInsets.symmetric(
                                                              horizontal: fontSize *
                                                                  2.7,
                                                              vertical: fontSize *
                                                                  1.2)),
                                                      side: const WidgetStatePropertyAll(BorderSide(
                                                          color: Colors.black)),
                                                      shape: const WidgetStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(Radius.circular(4))))),
                                                  onPressed: () {
                                                    // saveFile(context, keyss[0]);
                                                    showPostInvoiceCreationFeaturesHome(
                                                        context,
                                                        saveFile,
                                                        keyss[0]);
                                                  },
                                                  child: Text(
                                                    "Save as PDF",
                                                    style: TextStyle(
                                                        fontSize: fontSize <= 14
                                                            ? fontSize
                                                            : 14,
                                                        color: ColorPalette
                                                            .darkBlue),
                                                  )),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              TextButton(
                                                  style: ButtonStyle(
                                                      splashFactory: NoSplash
                                                          .splashFactory,
                                                      backgroundColor: WidgetStatePropertyAll(
                                                          ColorPalette.white),
                                                      padding: WidgetStatePropertyAll(
                                                          EdgeInsets.symmetric(
                                                              horizontal: fontSize *
                                                                  2.7,
                                                              vertical: fontSize *
                                                                  1.2)),
                                                      side: const WidgetStatePropertyAll(BorderSide(
                                                          color: Colors.black)),
                                                      shape: const WidgetStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(Radius.circular(4))))),
                                                  onPressed: () {
                                                    deleteLastInvoice(context);

                                                    showNoteDialog(
                                                        context,
                                                        invoicesContent[
                                                                keyss[0]]
                                                            ["BillingName"],
                                                        () {});
                                                  },
                                                  child: Text(
                                                    "Add Note",
                                                    style: TextStyle(
                                                        fontSize: fontSize <= 14
                                                            ? fontSize
                                                            : 14,
                                                        color: ColorPalette
                                                            .darkBlue),
                                                  )),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Tooltip(
                                            message: "Delete Last Invoice",
                                            child: InkWell(
                                                onTap: () {
                                                  deleteLastInvoiceDialog(
                                                      context, widget.setS);
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 26,
                                                )),
                                          )
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 500,
                    width: width * .59,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(95, 207, 207, 207),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 2))
                        ],
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            keyss.length == 0 ? "" : "History",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          keyss.length == 0
                              ? Container()
                              : HistoryTableHeading(fontSize),
                          const SizedBox(
                            height: 13,
                          ),
                          Expanded(
                              child: invoicesContent.keys.toList().length == 0
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: 250,
                                              width: 600,
                                              child: SvgPicture.asset(
                                                  "assets/images/noInvoice.svg")),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          const Text(
                                            "No History Record Found",
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 16),
                                          )
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: keyss.length <= 15
                                          ? keyss.length
                                          : 15,
                                      scrollDirection: Axis.vertical,
                                      // ignore: body_might_complete_normally_nullable
                                      itemBuilder: (context, index) {
                                        if (keyss.length != 0) {
                                          var tempRecord =
                                              invoicesContent[keyss[index]]
                                                      ['Date']
                                                  .toString();
                                          var dateList = tempRecord.split('/');

                                          return Column(
                                            children: [
                                              HistoryTableHeading2(
                                                  context,
                                                  dateList[2],
                                                  dateList[1].padLeft(2, '0'),
                                                  keyss[index],
                                                  invoicesContent[keyss[index]]
                                                      ['BillingName'],
                                                  invoicesContent[keyss[index]]
                                                      ['Products'][0]['name'],
                                                  invoicesContent[keyss[index]]
                                                      ['BillingGST'],
                                                  invoicesContent[keyss[index]]
                                                      ['grandtotal'],
                                                  invoicesContent[keyss[index]]
                                                      ['Contact'],
                                                  invoicesContent[keyss[index]]
                                                      ['Date'],
                                                  index,
                                                  fontSize),
                                              const SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          );
                                        } else if (keyss.length == 0) {
                                          return const Center(
                                            child: Text(
                                              "No Items Yet",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          );
                                        }
                                      }))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        // height: 450,
                        width: width * .36,
                        decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(95, 207, 207, 207),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 2))
                            ],
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 27),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ownership Details",
                                    style: TextStyle(
                                        fontSize: fontSize * 1.5,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          OwnershipCard(
                                              'profile.svg',
                                              firmDetails['FirmName'],
                                              "Firm Name",
                                              fontSize),
                                          OwnershipCard(
                                              'mail.svg',
                                              firmDetails['Contact'],
                                              "Email ID",
                                              fontSize),
                                          OwnershipCard(
                                              'phone.svg',
                                              firmDetails['Contact'],
                                              "Phone Number",
                                              fontSize),
                                          OwnershipCard(
                                              'gst.svg',
                                              firmDetails['GSTNo'],
                                              "GST No.",
                                              fontSize),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Expanded(
                                          // height: 200,

                                          // width: 300,
                                          child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    ColorPalette.blueAccent,
                                                radius: 19,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  radius: 11,
                                                  child: SvgPicture.asset(
                                                      'assets/images/address.svg'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                // constraints: BoxConstraints(maxWidth: 247),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Address',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              110,
                                                              110,
                                                              110),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                        "${firmDetails['Address1']}\n${firmDetails['Address2']}\n",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 62, 62, 62),
                                                            fontSize:
                                                                fontSize <= 15
                                                                    ? fontSize
                                                                    : 15.5,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'Poppins')),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 60,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          CupertinoPageRoute(
                                              builder: (context) {
                                        return const SettingsPageLarge();
                                      }));
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            ColorPalette.blueAccent),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        'Edit Ownership details',
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins'),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: fontSize <= 15 ? 210 : 250,
                      width: width * .36,
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(95, 207, 207, 207),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 2))
                          ],
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TimeWidget(fontSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget HistoryTableHeading(double fontSize) {
  double containerWidth = 40;
  if (fontSize <= 14) {
    containerWidth = 30;
  }
  return Container(
    height: 50,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      color: ColorPalette.offWhite.withOpacity(0.4),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: containerWidth * 1.25,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text("S. No. ",
                style: TextStyle(
                    color: Color.fromARGB(255, 36, 36, 36),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy')),
          ),
          Container(
            width: containerWidth * 4.5,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text(
              "Billed To",
              style: TextStyle(
                  color: Color.fromARGB(255, 36, 36, 36),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy'),
            ),
          ),
          Container(
            width: containerWidth * 5,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text(
              "Products",
              style: TextStyle(
                  color: Color.fromARGB(255, 36, 36, 36),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy'),
            ),
          ),
          Container(
            width: containerWidth * 4.5,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text(
              "GST No. ",
              style: TextStyle(
                  color: Color.fromARGB(255, 36, 36, 36),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy'),
            ),
          ),
          Container(
            width: containerWidth * 2.5,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text(
              "Amount",
              style: TextStyle(
                  color: Color.fromARGB(255, 36, 36, 36),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy'),
            ),
          ),
          Container(
            width: containerWidth * 2.5,
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0), width: 1))),
            child: const Text(
              "Phone No.",
              style: TextStyle(
                  color: Color.fromARGB(255, 36, 36, 36),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy'),
            ),
          ),
          SizedBox(
              width: containerWidth * 2.5,
              child: const Text(
                "Date Issued",
                style: TextStyle(
                    color: Color.fromARGB(255, 36, 36, 36),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy'),
              )),
        ],
      ),
    ),
  );
}

Widget HistoryTableHeading2(
  BuildContext context,
  String year,
  String month,
  String sno,
  String billed,
  String product,
  String gst,
  String amount,
  String phone,
  String date,
  int index,
  double fontSize,
) {
  double containerWidth = 40;
  if (fontSize <= 14) {
    containerWidth = 30;
  }

  return Tooltip(
    verticalOffset: -1,
    decoration: BoxDecoration(
      color: ColorPalette.darkBlue,
      borderRadius: BorderRadius.circular(4),
    ),
    message: "Click to view",
    textStyle: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w200),
    child: InkWell(
      onTap: () async {
        await PreviewSave(year, month, sno);
        showDialog(
            barrierColor: const Color.fromARGB(186, 0, 0, 0),
            context: context,
            builder: (context) {
              return Dialog(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 21 / 29.7,
                      child:
                          PdfViewer.file("Database/Invoices/tempInvoice.pdf"),
                    ),
                    Positioned(
                      top: 15,
                      right: 10,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: const Color.fromARGB(146, 0, 0, 0),
                          child: Icon(
                            Icons.close,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      },
      child: Container(
        height: containerWidth,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: index % 2 == 0
              ? Colors.white
              : ColorPalette.offWhite.withOpacity(0.14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: containerWidth * 1.25,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Text(sno,
                    style: TextStyle(
                        color: const Color.fromARGB(170, 0, 0, 0),
                        fontSize: fontSize * 0.8,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gilroy')),
              ),
              Container(
                width: containerWidth * 4.5,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Tooltip(
                  message: billed,
                  child: Text(
                    billed,
                    style: const TextStyle(
                        color: Color.fromARGB(170, 0, 0, 0),
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gilroy'),
                  ),
                ),
              ),
              Container(
                width: containerWidth * 5,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Text(
                  product,
                  style: const TextStyle(
                      color: Color.fromARGB(170, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy'),
                ),
              ),
              Container(
                width: containerWidth * 4.5,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Text(
                  gst,
                  style: const TextStyle(
                      color: Color.fromARGB(170, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy'),
                ),
              ),
              Container(
                width: containerWidth * 2.5,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Text(
                  amount,
                  style: const TextStyle(
                      color: Color.fromARGB(170, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy'),
                ),
              ),
              Container(
                width: containerWidth * 2.5,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color.fromARGB(10, 0, 0, 0), width: 1))),
                child: Text(
                  phone,
                  style: const TextStyle(
                      color: Color.fromARGB(170, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy'),
                ),
              ),
              SizedBox(
                  width: containerWidth * 2.5,
                  child: Text(
                    date,
                    style: const TextStyle(
                        color: Color.fromARGB(170, 0, 0, 0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gilroy'),
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget OwnershipCard(
    String path, String subheading, String heading, double fontSize) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(
        height: 25,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: ColorPalette.blueAccent,
            radius: 19,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 9,
              child: SvgPicture.asset('assets/images/$path'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 247),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 110, 110, 110),
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 0,
                ),
                Text(
                  subheading,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontSize: fontSize <= 15 ? fontSize : 15.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
          )
        ],
      ),
    ],
  );
}

Widget TimeWidget(double fontSize) {
  final now = DateTime.now();
  final dayFormatter = DateFormat('EEEE'); // EEEE represents full weekday name
  String currentDay = dayFormatter.format(now);
  List months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  var currentDate = DateTime.now().day.toString();
  var currentMonth = months[DateTime.now().month - 1];
  var currentYear = DateTime.now().year.toString();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 27),
    child: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "$currentDate ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize * 1.8,
                      fontWeight: FontWeight.w500,
                    )),
                TextSpan(
                    text: currentMonth + " ",
                    style: TextStyle(
                      color: ColorPalette.blueAccent,
                      fontSize: fontSize * 1.8,
                      fontWeight: FontWeight.w700,
                    )),
                TextSpan(
                    text: "$currentYear ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize * 1.8,
                      fontWeight: FontWeight.w500,
                    )),
              ])),
              LiveTimeWidget(),
              const SizedBox(
                height: 50,
              ),
              Text(
                '$currentDay ~',
                style: TextStyle(
                    fontFamily: 'Dancing',
                    fontSize: fontSize * 1.8,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          AnalogClock(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1.0, color: const Color.fromARGB(143, 0, 0, 0)),
                color: Colors.transparent,
                shape: BoxShape.circle),
            width: fontSize <= 15 ? fontSize * 11.5 : 190.0,
            isLive: true,
            hourHandColor: Colors.black,
            minuteHandColor: Colors.black,
            showSecondHand: true,
            numberColor: ColorPalette.blueAccent,
            showNumbers: true,
            showAllNumbers: true,
            textScaleFactor: 1.4,
            showTicks: true,
            showDigitalClock: false,
            datetime: DateTime.now(),
            useMilitaryTime: true,
          ),
        ],
      ),
    ),
  );
}
