import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/id_model.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/verify_id_card_screen.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';

class IdDeclinedScreen extends StatefulWidget {
  static const routeName = '/id_declined_screen.dart';
  const IdDeclinedScreen({Key? key}) : super(key: key);

  @override
  State<IdDeclinedScreen> createState() => _IdDeclinedScreenState();
}

class _IdDeclinedScreenState extends State<IdDeclinedScreen> {
  IdModel? get userId {
    return Provider.of<AuthProvider>(context, listen: false).userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 180,
                width: 150,
                child: Image.asset(
                  'images/unavailable_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Reason For Failed Verification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (userId == null || userId!.remark == null)
                    const Text('Submitted identity card was not clear'),
                  if (userId != null || userId!.remark != null)
                    Text(
                      userId == null || userId!.remark == null
                          ? ''
                          : userId!.remark!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            SubmitButton(
              action: () {
                Navigator.of(context).pushNamed(
                  VerifyIdCardScreen.routeName,
                );
              },
              title: 'Submit Another ID',
            )
          ],
        ),
      ),
    );
  }
}
