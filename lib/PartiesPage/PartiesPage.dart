// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:billing/InvoicesPageSection/InvoicePageLarge.dart';
import 'package:billing/PartiesPage/PartiesPageComponents/PartiesPageComponents.dart';
import 'package:billing/colors.dart';
import 'package:flutter/material.dart';

class PartiesPageLarge extends StatefulWidget {
  const PartiesPageLarge({super.key});

  @override
  State<PartiesPageLarge> createState() => _PartiesPageLargeState();
}

class _PartiesPageLargeState extends State<PartiesPageLarge> {
  File partiesJSON = File("Database/Party Records/parties.json");
  TextEditingController searchController = TextEditingController();
  List keyss = [];
  dynamic partyContent;
  String searchKey = "";
  late int clientRecords;
  void setFn() {
    setState(() {
      partyContent = partiesJSON.readAsStringSync();
      partyContent = jsonDecode(partyContent);
      clientRecords = partyContent.keys.length;
      keyss = partyContent.keys.toList();
      keyss.sort();
    });
  }

  @override
  void initState() {
    partyContent = partiesJSON.readAsStringSync();
    partyContent = jsonDecode(partyContent);
    clientRecords = partyContent.keys.length;
    keyss = partyContent.keys.toList();
    keyss.sort();
    super.initState();
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
    // double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: ColorPalette.offWhite.withOpacity(0.5),
      padding: const EdgeInsets.only(top: 38, right: 30, left: 30),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13), topRight: Radius.circular(13))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: double.infinity,
              width: screenWidth * .61,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(95, 207, 207, 207),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "All ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize * 1.7)),
                          TextSpan(
                              text: "Parties",
                              style: TextStyle(
                                  color: ColorPalette.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize * 1.7)),
                        ])),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey)),
                                height: 50,
                                width: 400,
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (v) {
                                    setState(() {
                                      searchKey = v;
                                    });
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                  ),
                                  decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            searchController.clear();
                                            searchController.text = "";
                                            searchKey = "";
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                          size: 17,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      label: Text(
                                        "Search Party",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Poppins",
                                            color: Color.fromARGB(
                                                255, 87, 87, 87)),
                                      ),
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
                            Container(
                              height: 50,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      splashFactory: NoSplash.splashFactory,
                                      side: WidgetStatePropertyAll(BorderSide(
                                          color: ColorPalette.blueAccent)),
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                              Colors.white),
                                      shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)))),
                                  onPressed: () {
                                    showAddPartyDialog(context, setFn);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 9.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Add New Party",
                                          style: TextStyle(
                                              color: ColorPalette.blueAccent),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.add,
                                          color: ColorPalette.blueAccent,
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        )
                      ],

                    ),

                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PartyTableHeader(fontSize),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: keyss.isEmpty
                        ? nullRecord4()
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: clientRecords,
                            itemBuilder: (c, i) {
                              return PartyTableRow(
                                  searchKey: searchKey,
                                  fontSize: fontSize,
                                  reset: setFn,
                                  file: partiesJSON,
                                  content: partyContent,
                                  context: context,
                                  index: i,
                                  sno: "${i + 1}",
                                  contact: partyContent[keyss[i]]['contact'],
                                  client: partyContent[keyss[i]]["name"],
                                  gst: partyContent[keyss[i]]["gst"],
                                  address: partyContent[keyss[i]]["address"],
                                  note: partyContent[keyss[i]]["note"] != ""
                                      ? partyContent[keyss[i]]["note"]
                                      : "-");
                            }),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 250,
                      width: screenWidth * .33,
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(95, 207, 207, 207),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 2))
                          ],
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/wave-bg.png')),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(13))),
                      child: Padding(
                        padding: const EdgeInsets.all(29),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Total Client Records",
                              style: TextStyle(
                                  fontSize: 29, fontWeight: FontWeight.bold),
                            ),
                            Text("$clientRecords+",
                                style: TextStyle(
                                    color: ColorPalette.blueAccent,
                                    fontSize: 80))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // Container(
                    //   height: 450,
                    //   width: screenWidth * .33,
                    //   decoration: const BoxDecoration(
                    //       boxShadow: [
                    //         BoxShadow(
                    //             color: Color.fromARGB(95, 207, 207, 207),
                    //             spreadRadius: 2,
                    //             blurRadius: 8,
                    //             offset: Offset(0, 2))
                    //       ],
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.all(Radius.circular(13))),
                    //   child: const Padding(
                    //     padding: EdgeInsets.all(23.0),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           "Billed Clients This Month",
                    //           style: TextStyle(
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //               fontFamily: 'Poppins'),
                    //         ),
                    //         LineChartSample2(),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget PartyTableHeader(double fontSize) {
  double containerWidth = 40;
  if (fontSize <= 15) {
    containerWidth = fontSize * 2;
  }
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), color: ColorPalette.blueAccent),
    padding: const EdgeInsets.only(left: 10, right: 10),
    height: 40,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InvoiceRecordHeaderText(containerWidth, "S.No.", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 7.5, "Client Name & GST", 0, fontSize),
        InvoiceRecordHeaderText(
            containerWidth * 7.5, "Client Address", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 5.7, "Note", 0, fontSize),
        InvoiceRecordHeaderText(containerWidth * 4.5, "Options", 0, fontSize),
      ],
    ),
  );
}

Widget PartyTableRow(
    {required String sno,
    required File file,
    required dynamic content,
    required BuildContext context,
    required int index,
    required String contact,
    required Function reset,
    required String client,
    required String gst,
    required String address,
    required String note,
    required double fontSize,
    required String searchKey}) {
  double containerWidth = 40;
  if (fontSize <= 15) {
    containerWidth = fontSize * 2;
  }
  return hasSequentialMatch(searchKey, client) || searchKey == ""
      ? Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index % 2 == 0
                    ? const Color.fromARGB(70, 215, 215, 215)
                    : Colors.white),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InvoiceRecordHeaderText3(containerWidth, sno, 1),
                  InvoiceRecordHeaderText4(
                      containerWidth * 7.5, client, "$gst\nPh:$contact", 1),
                  InvoiceRecordHeaderText3(containerWidth * 7.5, address, 1),
                  InvoiceRecordHeaderText3(containerWidth * 5.7, note, 1),
                  SizedBox(
                    width: containerWidth * 4.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: "Edit Note",
                          child: InkWell(
                              onTap: () {
                                showNoteDialog(context, client, reset);
                              },
                              child: const Icon(Icons.note_add,
                                  color: Colors.green)),
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Tooltip(
                          message: "Edit Record",
                          child: InkWell(
                              onTap: () {
                                showEditPartyDialog(context, client, reset);
                              },
                              child: Icon(Icons.edit,
                                  color: ColorPalette.blueAccent)),
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Tooltip(
                          message: "Delete",
                          child: InkWell(
                              onTap: () {
                                deleteParty(
                                    context: context,
                                    file: file,
                                    content: content,
                                    party: client,
                                    reset: reset);
                              },
                              child:
                                  const Icon(Icons.delete, color: Colors.red)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      : SizedBox();
}


