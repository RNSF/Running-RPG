import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:running_game/saving_service/saving_service.dart';
import '../../locator.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  void loadSaveData(context) async {
    await setUpLocator(context);
    Navigator.pushReplacementNamed(context, "/navigation_master");
  }

  @override
  Widget build(BuildContext context) {
    loadSaveData(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SpinKitWave(
          color: Colors.white,
          size: 40.0,
        )
      )
    );
  }
}
