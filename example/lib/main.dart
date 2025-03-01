import 'package:flutter/material.dart';
import 'package:linphonesdk/CallLog.dart';
import 'package:linphonesdk/call_state.dart';
import 'dart:async';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:linphonesdk/login_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _linphoneSdkPlugin = LinphoneSDK();
  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    _linphoneSdkPlugin.removeLoginListener();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      _linphoneSdkPlugin.requestPermissions();
    } catch (e) {
      print("Error on request permission. ${e.toString()}");
    }
  }

  Future<void> login({required String username,required String pass,required String domin}) async {
    await _linphoneSdkPlugin.login(
        userName: username, domain: domin, password: pass);
  }

  Future<void> call() async {
    if (_textEditingController.value.text.isNotEmpty) {
      String number = _textEditingController.value.text;
      await _linphoneSdkPlugin.call(number: number);
    }
  }

  Future<void> forward()async{
  await  _linphoneSdkPlugin.callTransfer(destination: "1000");
  }

  Future<void> hangUp() async {
    await _linphoneSdkPlugin.hangUp();
  }

  Future<void> toggleSpeaker()async{
    await _linphoneSdkPlugin.toggleSpeaker();
  }

  Future<bool> toggleMute()async{
   return await _linphoneSdkPlugin.toggleMute();
  }

  Future<void> callLogs()async{
    CallLogs callLogs = await _linphoneSdkPlugin.callLogs();
    print("---------call logs length: ${callLogs.callHistory.length}");
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _userController = TextEditingController();
    final TextEditingController _passController = TextEditingController();
    final TextEditingController _dominController = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Linphone SDK example app'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _userController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: "Input username",
                  labelText: "Username"),
            ),
            TextFormField(
              controller: _passController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: "Input password",
                  labelText: "Password"),
            ),
            TextFormField(
              controller: _dominController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.domain),
                  hintText: "Input domain",
                  labelText: "Domain"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  login(username: _userController.text, pass: _passController.text, domin: _dominController.text);
                },
                child: const Text("Login")),
            const SizedBox(height: 20),
            StreamBuilder<LoginState>(
              stream: _linphoneSdkPlugin.addLoginListener(),
              builder: (context, snapshot) {
                LoginState status = snapshot.data ?? LoginState.none;
                return Text("Login status: ${status.name}");
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: "Input number",
                  labelText: "Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: call, child: const Text("Call")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  hangUp();
                },
                child: const Text("HangUp")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  toggleSpeaker();
                },
                child: const Text("Speaker")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  toggleMute();
                },
                child: const Text("Mute")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  forward();
                },
                child: const Text("Forward")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  callLogs();
                },
                child: const Text("Call Log")),
            const SizedBox(height: 20),
            StreamBuilder<CallState>(
              stream: _linphoneSdkPlugin.addCallStateListener(),
              builder: (context, snapshot) {
                CallState status = snapshot.data ?? CallState.idle;
                return Text("Call status: ${status.name.toUpperCase()}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
