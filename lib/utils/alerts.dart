import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/screens/add_bank_screen.dart';
import 'package:kasheto_flutter/screens/bank_transfer_screen.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/screens/personal_details_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/dialog_row.dart';

class Alert {
  static SnackBar snackBar(
      {required String message, required BuildContext context}) {
    return SnackBar(
      elevation: 100,
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  static Future<bool?> showAddUsdDialog({
    required BuildContext context,
    required String amount,
    required String ktcValue,
    required String? paymentMeethod,
    required String charges,
    required String totalDepositAmount,
  }) async {
    return await (showDialog<bool>(
            context: context,
            builder: (context) {
              return Dialog(
                elevation: 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Confirm Amount !!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(thickness: 1),
                      DialogRow(title: 'Amount', content: amount),
                      const Divider(thickness: 1),
                      DialogRow(title: 'Charges', content: '\$ $charges'),
                      const Divider(thickness: 1),
                      DialogRow(
                          title: 'Total Deposit',
                          content: '\$ $totalDepositAmount'),
                      const Divider(thickness: 1),
                      DialogRow(title: 'KTC Value', content: 'KTC $ktcValue'),
                      const Divider(thickness: 1),
                      DialogRow(
                          title: 'Payment Method', content: paymentMeethod!),
                      const Divider(thickness: 1),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          DialogChip(
                              onTap: () {
                                Navigator.of(context).pop(false);
                              },
                              text: 'Cancel',
                              color: Colors.red),
                          const SizedBox(
                            width: 15,
                          ),
                          DialogChip(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              text: 'Continue',
                              color: Colors.green),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            })) ??
        false;
  }

  static Future showSuccessDialog({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    int? id,
    // Using id to send user to initialization screen or just to pop screen
  }) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      'images/happy_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DialogChip(
                      onTap: onPressed, text: 'Close', color: Colors.red),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future cantDialog({required BuildContext context}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'images/unavailable_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'You need to complete your Profile to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DialogChip(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(PersonalDetailScreen.routeName);
                      },
                      text: 'Go to profile',
                      color: Colors.green),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future mustAddBankDialog({required BuildContext context}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'images/unavailable_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'You need to add a bank on your profile to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DialogChip(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(AddBankScreen.routeName);
                      },
                      text: 'Add Bank',
                      color: Colors.green),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future<bool?> showExchangeUsdtoNairaDialog({
    required BuildContext context,
    required String totalAmount,
    required String nairaValue,
    required String charges,
    required String ktcValue,
  }) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirm Amount !!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(thickness: 1),
                  DialogRow(
                      title: 'Total Deposit Amount', content: totalAmount),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Value In KTC', content: ktcValue),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Value In Naira', content: nairaValue),
                  const Divider(thickness: 1),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          text: 'Cancel',
                          color: Colors.red),
                      const SizedBox(
                        width: 15,
                      ),
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          text: 'Continue',
                          color: Colors.green),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future showSuccessDialog2(
    BuildContext context,
  ) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      'images/happy_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Withdrawal Successfully !!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Center(
                    child: DialogChip(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, MainScreen.routeName, (route) => false);
                      },
                      text: 'Go Home',
                      color: MyColors.primaryColor,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Future<bool?> confirmationDialog(
      {required BuildContext context,
      required String charges,
      required String amount,
      required String acctName,
      required String acctNumber,
      required String bankName}) {
    var totalAmount = double.parse(amount) + double.parse(charges);
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Confirm Withdrawal !!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Amount Requested', content: 'KTC $amount'),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Charges', content: 'KTC $charges'),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Total Amount', content: 'KTC $totalAmount'),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Account name', content: acctName),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Account number', content: acctNumber),
                  const Divider(thickness: 1),
                  DialogRow(title: 'Bank name', content: bankName),
                  const Divider(thickness: 1),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          text: 'Cancel',
                          color: Colors.red),
                      const SizedBox(
                        width: 15,
                      ),
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          text: 'Continue',
                          color: Colors.green),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future<void> successDialogAddBank(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      'images/confirmed_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Done !!!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Your bank details have been added successfully',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                      }),
                      child: Chip(
                        backgroundColor: Colors.green[500],
                        label: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static showInfoDialog({
    required BuildContext context,
    required String info,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    " A PDF of your transaction history has ben generated. You can find it at this location - $info",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DialogChip(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: info,
                            ),
                          ).then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              Alert.snackBar(
                                message: 'Path copied successfully',
                                context: context,
                              ),
                            );
                          }).onError((error, stackTrace) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              Alert.snackBar(
                                message: 'Couldn\'t copy path to clipboard',
                                context: context,
                              ),
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        text: 'Copy path',
                        color: Colors.green,
                      ),
                      DialogChip(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        text: 'Close',
                        color: Colors.red,
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  static Future<bool?> showTransferDialog({
    required BuildContext context,
    required String name,
    required Bank bank,
    required String amount,
    required String charges,
    required String totalAmount,
  }) {
    return showDialog<bool>(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const Text(
                    'Confirm Transfer',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text('to'),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConfirmColumn('Beneficiary Bank', bank.name),
                          const Divider(),
                          ConfirmColumn('Amount', amount),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          text: 'Cancel',
                          color: Colors.red),
                      DialogChip(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        text: 'Continue',
                        color: Colors.green,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  static Future showDataPurchaseSuccessDialog(
    BuildContext context,
  ) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      'images/happy_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Your data purchase was succesful !!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DialogChip(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            MainScreen.routeName, (route) => false);
                      },
                      text: 'Close',
                      color: Colors.red),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Future<bool?> confirmCryptoPurchaseDialog(
      {required BuildContext context,
      required String btcAmount,
      required String btcCharge,
      required String ktcValue,
      required String receiverAddress}) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirm Purchase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          text: 'Cancel',
                          color: Colors.red),
                      DialogChip(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          text: 'Continue',
                          color: Colors.green)
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
