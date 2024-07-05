import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitPianoWave(
            color: MyColors.primaryColor,
            duration: Duration(milliseconds: 400),
            itemCount: 5,
            size: 20,
            type: SpinKitPianoWaveType.center,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Loading ....',
            style: TextStyle(color: Colors.green),
          )
        ],
      ),
    );
  }
}

class LoadingSpinnerWithMargin extends StatelessWidget {
  const LoadingSpinnerWithMargin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: const SpinKitPianoWave(
        color: MyColors.primaryColor,
        duration: Duration(milliseconds: 400),
        itemCount: 5,
        size: 20,
        type: SpinKitPianoWaveType.center,
      ),
    );
  }
}

class LoadingSpinnerWithScaffold extends StatelessWidget {
  final Widget? title;
  const LoadingSpinnerWithScaffold({this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: const Center(
          child: LoadingSpinner(),
        ),
      ),
    );
  }
}
