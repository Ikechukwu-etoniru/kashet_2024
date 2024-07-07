import 'dart:async';
import 'dart:io';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/provider/initialize_provider.dart';
import 'package:kasheto_flutter/provider/location_provider.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/screens/auth_screen.dart';
import 'package:kasheto_flutter/screens/add_bank_screen.dart';
import 'package:kasheto_flutter/screens/check_auth_screen.dart';
import 'package:kasheto_flutter/screens/edit_email_screen.dart';
import 'package:kasheto_flutter/screens/edit_personal_details_screen.dart';
import 'package:kasheto_flutter/screens/forgot_password_screen.dart';
import 'package:kasheto_flutter/screens/future_update_screen.dart';
import 'package:kasheto_flutter/screens/generate_statement_screen.dart';
import 'package:kasheto_flutter/screens/id_declined_screen.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/paypal_tx_screen.dart';
import 'package:kasheto_flutter/screens/support_screen.dart';
import 'package:kasheto_flutter/screens/update_image_screen.dart';
import 'package:kasheto_flutter/screens/user_bank_list.dart';
import 'package:kasheto_flutter/screens/verify_bvn_screen.dart';
import 'package:kasheto_flutter/screens/verify_email_screen.dart';
import 'package:kasheto_flutter/screens/verify_id_card_screen.dart';
import 'package:kasheto_flutter/screens/verify_number_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/notifications.dart';
import 'package:provider/provider.dart';
// import 'package:upgrader/upgrader.dart';
import '/screens/betting_screen.dart';
import '/screens/book_flight_screen.dart';
import '/screens/buy_sell_crypto_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/airtime_data_purchase_screen.dart';
import '/screens/bill_payment_scren.dart';
import '/screens/dstv_subscribtion_screen.dart';
import '/screens/electric_bill_subscription_screen.dart';
import '/screens/gotv_subscription_screen.dart';
import '/screens/startime_subscription_screen.dart';
import '/screens/add_card_screen.dart';
import '/screens/add_money_screen.dart';
import '/screens/send_request_money.dart';
import '/screens/withdraw_money_screen.dart';
import '/screens/main_screen.dart';
import '/screens/notification_screen.dart';
import '/screens/signup_screen.dart';
import '/screens/login_screen.dart';
import '/screens/notification_settings_screen.dart';
import '/screens/language_location_screen.dart';
import '/screens/all_transactions_screen.dart';
import '/screens/bank_transfer_screen.dart';
import '/screens/personal_details_screen.dart';
import '/screens/security_settings_screen.dart';
import '/screens/update_password_screen.dart';
import '/provider/transaction_provider.dart';
import '/provider/user_card_provider.dart';
import 'provider/auth_provider.dart';
import 'provider/wallet_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  // AwesomeNotifications().initialize('resource://drawable/res_kasheto_icon', [
  //   NotificationChannel(
  //       channelKey: Notifications.basicChannelKey,
  //       channelName: Notifications.basicChannelName,
  //       channelDescription: Notifications.basicChannelDescription,
  //       defaultColor: MyColors.primaryColor,
  //       importance: NotificationImportance.Low,
  //       channelShowBadge: true,
  //       playSound: true,
  //       enableVibration: true)
  // ]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  bool forceLogout = false;
  // Used to navigate without context
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _logOutUser());
  }

  void _logOutUser() {
    _timer!.cancel();
    setState(() {
      forceLogout = true;
    });
  }

// Debounce this function
// Checks every touch and restart timer
  void _handleUserInteraction([_]) {
    _timer!.cancel();
    _initializeTimer();
  }

  void navToHomePage(BuildContext context) {
    // navigatorKey.currentState!.pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => const LoginScreen()),
    //     (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (forceLogout) {
      navToHomePage(context);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleUserInteraction,
      onPanDown: _handleUserInteraction,
      onScaleStart: _handleUserInteraction,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => UserCardProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => LocationProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => PlatformChargesProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => WalletProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => TransactionProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => BillingProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => BankProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => MoneyRequestProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => InitializeProvider(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Kasheto',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Colors.green,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              color: Colors.transparent,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              labelStyle: const TextStyle(
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.white,
                ),
              ),
              fillColor: MyColors.textFieldColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.white,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  width: 1,
                  color: MyColors.primaryColor,
                ),
              ),
            ),
          ),
          home: const CheckAuthScreen(),

          // UpgradeAlert(
          //   child: const CheckAuthScreen(),
          //   upgrader: Upgrader(
          //     dialogStyle: Platform.isIOS
          //         ? UpgradeDialogStyle.cupertino
          //         : UpgradeDialogStyle.material,
          //   ),
          // ),
          routes: {
            SignupScreen.routeName: (ctx) => const SignupScreen(),
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            MainScreen.routeName: (ctx) => const MainScreen(),
            NotificationScreen.routeName: (ctx) => const NotificationScreen(),
            AddCardScreen.routeName: (ctx) => const AddCardScreen(),
            AddMoneyScreen.routeName: (ctx) => const AddMoneyScreen(),
            WithdrawMoneyScreen.routeName: (ctx) => const WithdrawMoneyScreen(),
            SendRequestMoneyScreen.routeName: (ctx) =>
                const SendRequestMoneyScreen(),
            BillPaymentScreen.routeName: (ctx) => BillPaymentScreen(),
            DstvSubscriptionScreen.routeName: (ctx) =>
                const DstvSubscriptionScreen(),
            GotvSubscriptionScreen.routeName: (ctx) =>
                const GotvSubscriptionScreen(),
            StartimeSubscriptionScreen.routeName: (ctx) =>
                const StartimeSubscriptionScreen(),
            ElectricBillSubscriptionScreen.routeName: (ctx) =>
                const ElectricBillSubscriptionScreen(),
            AirtimeDataPurchaseScreen.routeName: (ctx) =>
                const AirtimeDataPurchaseScreen(),
            BuySellCryptoScreen.routeName: (ctx) => const BuySellCryptoScreen(),
            BookFlightScreen.routeName: (ctx) => const BookFlightScreen(),
            BettingScreen.routeName: (ctx) => const BettingScreen(),
            ProfileScreen.routeName: (ctx) => const ProfileScreen(),
            NotificationSettings.routeName: (ctx) =>
                const NotificationSettings(),
            LanguageLocationScreen.routeName: (ctx) =>
                const LanguageLocationScreen(),
            BankTransfer.routeName: (ctx) => const BankTransfer(),
            AllTransactionScreen.routeName: (ctx) =>
                const AllTransactionScreen(),
            PersonalDetailScreen.routeName: (ctx) =>
                const PersonalDetailScreen(),
            SecuritySettingsScreen.routeName: (ctx) =>
                const SecuritySettingsScreen(),
            UpdatePasswordScreen.routeName: (ctx) =>
                const UpdatePasswordScreen(),
            VerifyNumberScreen.routeName: (ctx) => const VerifyNumberScreen(),
            VerifyEmailScreen.routeName: (ctx) => const VerifyEmailScreen(),
            UpdateImageScreen.routeName: (ctx) => const UpdateImageScreen(),
            InitializationScreen.routeName: (ctx) =>
                const InitializationScreen(),
            VerifyBvnScreen.routeName: (ctx) => const VerifyBvnScreen(),
            EditPersonalDetailsScreen.routeName: (ctx) =>
                const EditPersonalDetailsScreen(),
            AddBankScreen.routeName: (ctx) => const AddBankScreen(),
            ForgotPasswordScreen.routeName: (ctx) =>
                const ForgotPasswordScreen(),
            FutureUpdate.routeName: (ctx) => const FutureUpdate(),
            GenerateStatementScreen.routeName: (ctx) =>
                const GenerateStatementScreen(),
            Auth2FaScreen.routeName: (ctx) => const Auth2FaScreen(),
            EditEmailScreen.routeName: (ctx) => const EditEmailScreen(),
            UserBankList.routeName: (ctx) => const UserBankList(),
            SupportScreen.routeName: (ctx) => const SupportScreen(),
            PaypalTxScreen.routeName: (ctx) => const PaypalTxScreen(),
            VerifyIdCardScreen.routeName: (ctx) => const VerifyIdCardScreen(),
            IdDeclinedScreen.routeName: (ctx) => const IdDeclinedScreen(),
          },
        ),
      ),
    );
  }
}
