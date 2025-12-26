// ignore_for_file: must_be_immutable, file_names

import 'dart:io';

import 'package:billing/InvoicesPageSection/InvoicePageLarge.dart';
import 'package:billing/NavBar/LargeNavbar.dart';
import 'package:billing/Pages/home.dart';
import 'package:billing/PartiesPage/PartiesPage.dart';
import 'package:billing/ProductsPage/productspagelarge.dart';
import 'package:billing/ReportsPage/PurchaseRecords.dart';
import 'package:billing/ReportsPage/ReportsPageLarge.dart';
import 'package:flutter/material.dart';

class LargeScreenPair extends StatefulWidget {
  double fontSize;

  // ignore: prefer_const_constructors_in_immutables
  LargeScreenPair({super.key, required this.fontSize});

  @override
  State<LargeScreenPair> createState() => _LargeScreenPairState();
}

class _LargeScreenPairState extends State<LargeScreenPair> {
  File invoices = File("Database/Invoices/Invoices.json");
  late String invoicesC;
  int pageIndex = 0;
  Color colorss = Colors.black;
  void changeIndex(index) {
    setState(() {
      pageIndex = index;
    });
  }

  void changeFile() {
    setState(() {
      invoicesC = "";
      File newtemp = File("Database/Invoices/Invoices.json");
      invoicesC = newtemp.readAsStringSync();
    });
  }

  @override
  void initState() {
    invoicesC = invoices.readAsStringSync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Column(
        children: [
          LargeNavBar(
            onIndexChange: changeIndex,
            pageIndex: pageIndex,
            fontSize: widget.fontSize,
            onFileChange: changeFile,
          ),
          Expanded(
            child: pageIndex == 0
                ? HomePageLarge(
                    setS: changeFile,
                    invoices: invoicesC,
                    color: colorss,
                  )
                : pageIndex == 1
                    ? const InvoicePageLarge()
                    : pageIndex == 2
                        ? const PartiesPageLarge()
                        : pageIndex == 3
                            ? const ReportsPageLarge()
                            : pageIndex == 4? const PurchaseRecord() : pageIndex==5? const ProductsPageLarge(): Container(),
          )
        ],
      ),
    );
  }
}
