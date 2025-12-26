// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';

import 'dart:io';

import 'package:billing/colors.dart';
import 'package:billing/createInvoiceLayout.dart';
import 'package:flutter/material.dart';

void showAddPartyDialog(BuildContext context, Function reset) {
  showDialog(
      context: context,
      builder: (c) {
        return Dialog(
            child: AddPartyDialog(
          reset: reset,
        ));
      });
}

class AddPartyDialog extends StatefulWidget {
  Function reset;
  AddPartyDialog({super.key, required this.reset});

  @override
  State<AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends State<AddPartyDialog> {
  File parties = File('Database/Party Records/parties.json');
  dynamic partiesContent;
  late List keyss;
  TextEditingController clientNameController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  void start() {
    partiesContent = parties.readAsStringSync();
    partiesContent = jsonDecode(partiesContent);
    keyss = partiesContent.keys.toList();
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 580,
        width: 800,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                  height: 70,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(57, 191, 191, 191),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add a New Client Record",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor:
                              ColorPalette.offWhite.withOpacity(0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: ColorPalette.blueAccent,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      NoSuffixTextFieldParty(
                          clientNameController, double.infinity, "Client Name"),
                      NoSuffixTextFieldParty(
                          gstController, double.infinity, "GST No."),
                      NoSuffixTextFieldParty(
                          contactController, double.infinity, "Contact No."),
                      AddressTextField2(addressController, double.infinity,
                          "Address\n(Multi-Line)"),
                      const SizedBox(
                        height: 19,
                      ),
                      NoSuffixTextField0Party(
                          noteController, double.infinity, "Note"),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      style: ButtonStyle(
                          overlayColor:
                              const WidgetStatePropertyAll(Colors.white),
                          splashFactory: NoSplash.splashFactory,
                          backgroundColor:
                              WidgetStatePropertyAll(ColorPalette.white),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 9),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: ColorPalette.dark),
                        ),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(ColorPalette.dark),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)))),
                      onPressed: () async {
                        Map content = {
                          "name": clientNameController.text,
                          "gst": gstController.text,
                          "contact": contactController.text,
                          "address": addressController.text,
                          "note": noteController.text
                        };
                        partiesContent[clientNameController.text] = content;
                        await parties.writeAsString(jsonEncode(partiesContent));
                        widget.reset();
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25.0, vertical: 9),
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showEditPartyDialog(BuildContext context, String party, Function reset) {
  showDialog(
      context: context,
      builder: (c) {
        return Dialog(
            child: EditPartyDialog(
          party: party,
          reset: reset,
        ));
      });
}

class EditPartyDialog extends StatefulWidget {
  String party;
  Function reset;
  EditPartyDialog({super.key, required this.party, required this.reset});

  @override
  State<EditPartyDialog> createState() => _EditPartyDialogState();
}

class _EditPartyDialogState extends State<EditPartyDialog> {
  File parties = File('Database/Party Records/parties.json');
  dynamic partiesContent;
  late List keyss;
  TextEditingController clientNameController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  void setFn() {
    setState(() {
      File temp = File("Database/Party Records/parties.json");
      parties = temp;
      partiesContent = parties.readAsStringSync();
      partiesContent = jsonDecode(partiesContent);
    });
  }

  void start() {
    partiesContent = parties.readAsStringSync();
    partiesContent = jsonDecode(partiesContent);
    keyss = partiesContent.keys.toList();
    clientNameController.text = partiesContent[widget.party]['name'];
    gstController.text = partiesContent[widget.party]['gst'];
    contactController.text = partiesContent[widget.party]['contact'];
    addressController.text = partiesContent[widget.party]['address'];
    noteController.text = partiesContent[widget.party]['note'] ?? "-";
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 640,
        width: 800,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                  height: 70,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(57, 191, 191, 191),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit A Client Record",
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor:
                              ColorPalette.offWhite.withOpacity(0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: ColorPalette.blueAccent,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      NoSuffixTextField01(
                          clientNameController, double.infinity, "Client Name"),
                      NoSuffixTextField0(
                          gstController, double.infinity, "GST No."),
                      NoSuffixTextField0(
                          contactController, double.infinity, "Contact No."),
                      AddressTextField(
                          addressController, double.infinity, "Address"),
                      NoSuffixTextField(
                          noteController, double.infinity, "Note"),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 23),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      style: ButtonStyle(
                          overlayColor:
                              const WidgetStatePropertyAll(Colors.white),
                          splashFactory: NoSplash.splashFactory,
                          backgroundColor:
                              WidgetStatePropertyAll(ColorPalette.white),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 9),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: ColorPalette.dark),
                        ),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(ColorPalette.dark),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)))),
                      onPressed: () async {
                        Map content = {
                          "name": clientNameController.text,
                          "gst": gstController.text,
                          "contact": contactController.text,
                          "address": addressController.text,
                          "note": noteController.text
                        };
                        partiesContent[clientNameController.text] = content;
                        await parties.writeAsString(jsonEncode(partiesContent));
                        widget.reset();
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25.0, vertical: 9),
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void deleteParty(
    {required BuildContext context,
    required File file,
    required Function reset,
    required dynamic content,
    required String party}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
              height: 170,
              width: 390,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                        const SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              "Are you sure to delete this client record?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
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
                        TextButton(
                            style: ButtonStyle(
                                overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xffffffff))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: .0),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: ColorPalette.dark),
                              ),
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xff3049AA))),
                            onPressed: () {
                              Map temp = {};
                              List keys = content.keys.toList();
                              for (var i = 0; i < keys.length; i++) {
                                if (keys[i] != party) {
                                  temp[keys[i]] = content[keys[i]];
                                } else {
                                  continue;
                                }
                              }
                              content = temp;
                              file.writeAsStringSync(jsonEncode(content));
                              reset();
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

void showNoteDialog(BuildContext context, String party, Function reset) {
  TextEditingController nameController = TextEditingController();
  showDialog(
      context: context,
      builder: (c) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            height: 230,
            width: 500,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Add Note",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 23,
                                    fontFamily: 'Poppins'),
                              ),
                              const Text(
                                "Add a single line note for the party",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 110, 110, 110),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    fontFamily: 'Poppins'),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                      NoSuffixTextFieldN(nameController, double.infinity, "",
                          () async {
                        File file = File("Database/Party Records/parties.json");
                        dynamic content = file.readAsStringSync();
                        content = jsonDecode(content);
                        content[party]['note'] = nameController.text;
                        await file.writeAsString(jsonEncode(content));
                        reset();
                        Navigator.of(context).pop();
                      })
                    ],
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(ColorPalette.dark),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)))),
                      onPressed: () async {
                        File file = File("Database/Party Records/parties.json");
                        dynamic content = file.readAsStringSync();
                        content = jsonDecode(content);
                        content[party]['note'] = nameController.text;
                        await file.writeAsString(jsonEncode(content));
                        reset();
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17.0),
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
          ),
        );
      });
}
