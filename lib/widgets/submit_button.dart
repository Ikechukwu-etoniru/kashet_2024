import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

class SubmitButton extends StatelessWidget {
  final void Function()? action;
  final String title;
  final bool? noLowPadding;
  const SubmitButton(
      {required this.action, required this.title, this.noLowPadding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: noLowPadding == null
            ? const EdgeInsets.symmetric(vertical: 20)
            : const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: MyColors.primaryColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
