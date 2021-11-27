import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:telephony/telephony.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Homescreen(),
  ));
}

class Homescreen extends StatefulWidget {
  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String cardstatus = "click to turn on the service";
  Color cardcolor = Colors.red;
  final Telephony telephony = Telephony.instance;

  void initState() {
    super.initState();
    askpermission();
  }

  void askpermission() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  }

  void sendrequest() async {
    var response = await http.get(Uri.parse(
        "https://velophil.berlin/react-service.php?service=sms&access_token=VMoxiRv9pyrb6MvwMMYAfNbRiU63QcCnREf4R8FVhAazP3RLDt4AGt79PFsJKhhM"));
    var jsonres = jsonDecode(response.body);
    //sendsms("+919791463833", "hello");
    sendsms(jsonres[0]['data'][0]['to'], jsonres[0]['data'][0]['body']);
  }

  void sendresult(status, address, message) async {
    var map = new Map<String, dynamic>();
    map['SECURE'] = "518bc3c11de8e*d9412c7f2fec13413c0f5a2489a332f5";
    map['form-beforant'] = "1";
    map['form-operant'] = "plus";
    map['form-alterant'] = "delevered";
    map['form-email'] = "none@none.com";
    map['form-phone'] = address.toString();
    map['form-resultant'] = "2";
    map['form-textarea'] = message.toString();
    map['form-status'] = status.toString();
    var result = await http.post(
        Uri.parse("https://velophil.berlin/termin-anfrage.php"),
        body: map);
    print(result.body);
  }

  Future<void> sendsms(address, msg) async {
    final SmsSendStatusListener listener = (SendStatus status) {
      if (status == SendStatus.DELIVERED) {
        sendresult(status, address, msg);
      }
      setState(() {
        cardstatus = "message is " + status.toString() + "\n click to restart";
      });
    };
    telephony.sendSms(to: address, message: msg, statusListener: listener);
    setState(() {
      cardstatus = "sending message to " + address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("req2msg"),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width * 7 / 10,
          child: GestureDetector(
            onTap: () {
              if (cardcolor == Colors.red) {
                setState(() {
                  cardcolor = Colors.green;
                  cardstatus = "sending request to server";
                });
                sendrequest();
              } else {
                setState(() {
                  cardcolor = Colors.red;
                  cardstatus = "click to turn on the service";
                });
              }
            },
            child: Card(
              color: cardcolor,
              elevation: 20,
              child: Center(
                child: Text(
                  cardstatus,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
