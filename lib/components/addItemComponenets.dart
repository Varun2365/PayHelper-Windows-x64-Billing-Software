// ignore_for_file: must_be_immutable, file_names


import 'package:billing/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RateRowS extends StatefulWidget {
  RateRowS(
      {required this.tick,
      required this.taxRate,
      required this.text,
      required this.controller,
      required this.controller2,
      required this.controller3,
      required this.max,
      required this.enabled,
      super.key});
  String text;
  TextEditingController controller, controller2, controller3;
  int max,taxRate;
  bool enabled, tick;
  @override
  State<RateRowS> createState() => _RateRowSState();
}

class _RateRowSState extends State<RateRowS> {
    void updateAmount() {

    widget.controller2.text = formatIntegerToIndian(
            (convertIndianFormattedStringToNumber(widget.controller.text) *
                convertIndianFormattedStringToNumber(widget.controller3.text)))
        .toString();
  }
  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${widget.text} :",
                    style: TextStyle(
                        fontSize: 16,
                        color: widget.enabled?ColorPalette.blueAccent:const Color.fromARGB(255, 86, 86, 86),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                  constraints: const BoxConstraints(maxWidth: 330),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(32, 226, 226, 226),
                      borderRadius: BorderRadius.circular(9)),
                  child: TextField(
                    onChanged: (value) {
                    updateAmount();
                    },
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color.fromARGB(255, 86, 86, 86),
                        fontSize: 14),
                    mouseCursor: !widget.enabled
                        ? MouseCursor.defer
                        : MouseCursor.uncontrolled,
                    controller: widget.controller,
                    readOnly: !widget.enabled,
                    maxLines: widget.text == "Specs" ? 3 : widget.max,
                    minLines: widget.text == "Specs" ? 3 : 1,
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        label: const Text(""),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(144, 158, 158, 158))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: !widget.enabled
                                    ? const Color.fromARGB(144, 158, 158, 158)
                                    : const Color.fromARGB(255, 14, 44, 180))),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none)),
                                              onTapOutside: (event){
                                                     
                    FocusScope.of(context).unfocus();
                    widget.controller.text = formatIntegerToIndian( convertIndianFormattedStringToNumber((widget.controller.text).toString()) );


                  },
                  ),

                  )
                  
            ],
          ),
        ],
      );
  }
}

class QuantityStatefulWidget extends StatefulWidget {
  QuantityStatefulWidget(
      {required this.autoCalc,
      required this.taxRate,
      required this.rateController,
      required this.amountController,
      required this.totalAmountController,
      required this.text,
      required this.controller,
      required this.max,
      required this.enabled,
      required this.checkState,
      super.key});
  String text;
  TextEditingController controller, rateController, amountController,totalAmountController;
  int max,taxRate;
  bool enabled, autoCalc,checkState;
  @override
  State<QuantityStatefulWidget> createState() => _QuantityStatefulWidgetState();
}

class _QuantityStatefulWidgetState extends State<QuantityStatefulWidget> {
  void updateAmount() {
  
    widget.amountController.text = formatIntegerToIndian(
            (convertIndianFormattedStringToNumber(widget.controller.text) *
                convertIndianFormattedStringToNumber(widget.rateController.text)))
        .toString();
  }
  void updateTotalAmount(){

    dynamic rate = convertIndianFormattedStringToNumber(widget.rateController.text);
    dynamic qty = int.parse(widget.controller.text);
    rate = rate*qty;
    rate = rate.toStringAsFixed(2);
    widget.totalAmountController.text = formatIntegerToIndian(double.parse(rate));
  }
  void updateTotalAmountQty(value){
    dynamic rate = convertIndianFormattedStringToNumber(widget.rateController.text);
    dynamic qty = int.parse(value);
    rate = rate*qty;
    rate = rate.toStringAsFixed(2);
    widget.totalAmountController.text = formatIntegerToIndian(double.parse(rate));
  }

  void updateRate() {
    dynamic amount = convertIndianFormattedStringToNumber(widget.amountController.text);
    int.parse(widget.controller.text);
    dynamic rate = (100 * amount) / (100 + widget.taxRate);
    rate = rate.toStringAsFixed(2);
    widget.rateController.text = rate.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${widget.text} :",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 86, 86, 86),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 330),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(32, 226, 226, 226),
                  borderRadius: BorderRadius.circular(9)),
              child: TextField(
                onChanged: (value) {
                  if(!widget.checkState){

                  updateAmount();
                  }
                  else{

                  updateTotalAmountQty(value);
                  }
            
                },
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color.fromARGB(255, 86, 86, 86),
                    fontSize: 14),
                textAlign: TextAlign.center,
                mouseCursor: !widget.enabled
                    ? MouseCursor.defer
                    : MouseCursor.uncontrolled,
                controller: widget.controller,
                readOnly: !widget.enabled,
                maxLines: widget.text == "Specs" ? 3 : widget.max,
                minLines: widget.text == "Specs" ? 3 : 1,
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            dynamic num = widget.controller.text;
                            num = int.parse(num) + 1;
                            widget.controller.text = num.toString();
                            widget.autoCalc ? (){} : updateAmount();
                            updateTotalAmount();
                          });
                        },
                        child: const Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 86, 86, 86),
                        )),
                    prefixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          dynamic num = widget.controller.text;
                          if (int.parse(num) > 1) {
                            num = int.parse(num) - 1;
                            widget.controller.text = num.toString();
                            widget.autoCalc ? updateRate() : updateAmount();
                            updateTotalAmount();
                          }
                        });
                      },
                      child: const Icon(
                        Icons.remove,
                        color: Color.fromARGB(255, 86, 86, 86),
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    label: const Text(""),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(144, 158, 158, 158))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: !widget.enabled
                                ? const Color.fromARGB(144, 158, 158, 158)
                                : const Color.fromARGB(255, 14, 44, 180))),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none)),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class AmountStateful extends StatefulWidget {
  AmountStateful(
      {required this.text,
      required this.controller,
      required this.rateController,
      required this.taxRate,
      required this.qtyController,
      required this.max,
      required this.enabled,
      required this.totalAmountController,
      super.key});
  String text;
  TextEditingController controller, rateController, qtyController,totalAmountController;
  int max,taxRate;
  bool enabled;
  @override
  State<AmountStateful> createState() => _AmountStatefulState();
}

class _AmountStatefulState extends State<AmountStateful> {
  void updateRate() {
    dynamic amount = convertIndianFormattedStringToNumber(widget.controller.text);
    int.parse(widget.qtyController.text);
    dynamic rate = (100 * amount) / (100 + widget.taxRate);
    rate = rate.toStringAsFixed(2);
    widget.rateController.text = formatIntegerToIndian(double.parse(rate));
  }
  void updateTotalAmount(){
    dynamic rate = convertIndianFormattedStringToNumber(widget.rateController.text);
    dynamic qty = int.parse(widget.qtyController.text);
    rate = rate*qty;
    rate = rate.toStringAsFixed(2);
    widget.totalAmountController.text = formatIntegerToIndian(double.parse(rate));
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${widget.text} :",
                  style: TextStyle(
                      fontSize: 16,
                      color: widget.text == "Amount(Per Pc)"?ColorPalette.blueAccent:const Color.fromARGB(255, 86, 86, 86),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
                constraints: const BoxConstraints(maxWidth: 330),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(32, 226, 226, 226),
                    borderRadius: BorderRadius.circular(9)),
                child: TextField(
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Color.fromARGB(255, 86, 86, 86),
                      fontSize: 14),
                  mouseCursor: !widget.enabled
                      ? MouseCursor.defer
                      : MouseCursor.uncontrolled,
                  controller: widget.controller,
                  readOnly: !widget.enabled,
                  maxLines: widget.text == "Specs" ? 3 : widget.max,
                  minLines: widget.text == "Specs" ? 3 : 1,
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      label: const Text(""),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(144, 158, 158, 158))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: !widget.enabled
                                  ? const Color.fromARGB(144, 158, 158, 158)
                                  : const Color.fromARGB(255, 14, 44, 180))),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none)),
                  onChanged: (value) {
                    updateRate();
                    updateTotalAmount();
                  },
                  onTapOutside: (event){
                    FocusScope.of(context).unfocus();
                    widget.controller.text = formatIntegerToIndian( convertIndianFormattedStringToNumber((widget.controller.text).toString()) );


                  },
                ))
          ],
        ),
      ],
    );
  }
}

String formatIntegerToIndian(dynamic number) {
  NumberFormat formatter = NumberFormat.decimalPattern('en_IN');
  return formatter.format(number);
}

dynamic convertIndianFormattedStringToNumber(String formattedNumber) {
  final regex = RegExp(r'[^\d.]');
  final cleanedNumber = formattedNumber.replaceAll(regex, '');
  return double.parse(cleanedNumber);
}
