// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:billing/colors.dart';
import 'package:flutter/material.dart';
import 'InvoiceDefaults.dart';

class MonthCheckBox extends StatefulWidget {
  String year;
  double HeadingSize;
  Function selectedMonths;
  List selected;
  MonthCheckBox(
      {super.key,
      required this.year,
      required this.HeadingSize,
      required this.selectedMonths,
      required this.selected});

  @override
  State<MonthCheckBox> createState() => _MonthCheckBoxState();
}

class _MonthCheckBoxState extends State<MonthCheckBox> {
  List<String> Months = [
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
  List selectedMonths = [InvoiceDefaults.defaultMonth];
  Map monthCheck = {};
  List m = [];
  File Invoices = File("Database/Invoices/In.json");
  @override
  void initState() {
    dynamic content = Invoices.readAsStringSync();
    content = jsonDecode(content);
    List keyss = content.keys.toList();
    if(keyss.contains(widget.year)){

    List months = content[widget.year].keys.toList();

    for (var i = 0; i < months.length; i++) {
      m.add(int.parse(months[i]));
    }
    m.sort();
    for (var i = 0; i < Months.length; i++) {
      if (widget.selected.contains(Months[i])) {
        monthCheck[Months[i]] = true;
      } else {
        monthCheck[Months[i]] = false;
      }
    }
    }
    else{
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      height: 650,
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Available Months",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 27,
                        fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(Colors.white),
                    splashColor: Colors.white,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: ColorPalette.offWhite,
                      radius: 18,
                      child: const Icon(Icons.close),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "This is a list of  available months for year ${widget.year} containing Sales Records. Select from them to show record for each month",
                style: const TextStyle(
                    color: Color.fromARGB(255, 93, 93, 93),
                    fontFamily: 'Poppins',
                    fontSize: 14),
              ),
              const SizedBox(
                height: 9,
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: m.length,
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        Checkbox(
                            activeColor: ColorPalette.dark,
                            value: monthCheck[Months[m[i] - 1]],
                            onChanged: (v) {
                              setState(() {
                                monthCheck[Months[m[i] - 1]] =
                                    !monthCheck[Months[m[i] - 1]];
                              });
                            }),
                        Text(
                          Months[m[i] - 1],
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    );
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(ColorPalette.dark),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)))),
            onPressed: () {
              var keys = monthCheck.keys.toList();
              selectedMonths.clear();
              for (var i = 0; i < monthCheck.length; i++) {
                if (monthCheck[keys[i]] == true) {
                  setState(() {
                    selectedMonths.add(keys[i]);
                  });
                }
              }
              widget.selectedMonths(selectedMonths);
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Text(
                "Apply",
                style: TextStyle(color: Colors.white),
              ),
            )),
            ],
          )
        ],
      ),
    );
  }
}
