import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsPage extends StatefulWidget {
  const SmsPage({super.key});

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  SmsQuery query = SmsQuery();
  List<SmsMessage>? messages;
  final TextEditingController _amount = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  getsms() async {
    setState(() {
      isLoading = true;
    });
    String dateString = '10-06-2023';
    String amount = _amount.text != "" ? _amount.text : "1000";

    DateFormat format = DateFormat('dd-MM-yyyy');
    DateTime dateTime = selectedDate ?? format.parse(dateString);

    var status = await Permission.sms.status;
    log(status.toString() + "1");
    SmsMessage? newMessage;
    if (status.isGranted) {
      messages = await query.querySms(kinds: [SmsQueryKind.inbox]);
      if (messages != null) {
        newMessage = messages?.firstWhere((element) =>
            element.date?.day == dateTime.day &&
            element.date?.month == dateTime.month &&
            element.body!.contains(amount));
        // for (var i = 0; (messages![i].date!.day < dateTime.day && messages![i].date!.month < dateTime.month && messages![i].date!.year < dateTime.year); i++) {
        //   newMessage.add(messages![i]);
        // }
        if (newMessage != null) {
          setState(() {
            messages = [newMessage!];
            isLoading = false;
          });
        } else {
          log("no data match ..................................");
        }
        log(messages!.length.toString() + "2");
        log(messages![0].body!);
        //   for (var i = 0; i < messages!.length; i++) {
        //  log(messages![i].body!);
        //  }
      }
    } else {
      await Permission.sms.request();

      if (status.isGranted) {
        messages = await query.querySms(kinds: [SmsQueryKind.inbox]);

        if (messages != null) {
          newMessage = messages?.firstWhere((element) =>
              element.date?.day == dateTime.day &&
              element.date?.month == dateTime.month &&
              element.body!.contains(amount));
          // for (var i = 0; (messages![i].date!.day < dateTime.day && messages![i].date!.month < dateTime.month && messages![i].date!.year < dateTime.year); i++) {
          //   newMessage.add(messages![i]);
          // }
          if (newMessage != null) {
            setState(() {
              messages = [newMessage!];
              isLoading = false;
            });
          } else {
            log("no data match ..................................");
          }
          log(messages!.length.toString() + "2");
          log(messages![0].body!);
          //   for (var i = 0; i < messages!.length; i++) {
          //  log(messages![i].body!);
          //  }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
           const SizedBox(
              height: 25,
            ),
            TextFormField(
              controller: _amount,
              decoration: const InputDecoration(hintText: "Enter Amount"),
            ),
           const SizedBox(
              height: 25,
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.blue,
                  child:  Text(selectedDate != null ? selectedDate!.toIso8601String().split("T")[0] :'Select Date',style: TextStyle(color: Colors.white),)),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                getsms();
              },
              child: Container(
                color: Colors.amber,
                padding: EdgeInsets.all(20),
                child: const Text(
                  "Search",
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("After clicking on search wait for data"),
            Container(
                child: messages != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: messages!.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "Date of Transection = ${messages![i].date!.toIso8601String().split("T")[0]}"),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  messages![i].body!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          );
                        })
                    : isLoading ? const Center(child: CircularProgressIndicator(),) : const Center(child: Text("no Data"))),
          ],
        ),
      ),
    );
  }
}
