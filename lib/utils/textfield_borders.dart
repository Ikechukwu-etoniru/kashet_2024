import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

class MyInputBorder {
  static var borderInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      5,
    ),
    borderSide: const BorderSide(
      color: MyColors.textFieldColor,
      width: 0.5,
    ),
  );

  static var focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(
      color: Colors.green,
      width: 1,
    ),
  );

  static var enabledInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(
      color: MyColors.textFieldColor,
      width: 1,
    ),
  );
  static var errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(
      color: Colors.red,
      width: 4,
    ),
  );
  static var focusedErrorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(
      color: Colors.red,
      width: 2,
    ),
  );
}
