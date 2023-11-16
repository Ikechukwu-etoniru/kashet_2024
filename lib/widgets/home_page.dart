import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/initialize_provider.dart';
import 'package:kasheto_flutter/widgets/home_widgets/home_bottom_widgets.dart';
import 'package:kasheto_flutter/widgets/home_widgets/home_top_container.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:kasheto_flutter/widgets/home_widgets/black_box.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return LiquidPullToRefresh(
      onRefresh: () async {
        await Provider.of<InitializeProvider>(context, listen: false)
            .refreshInitialize(context);
      },
      showChildOpacityTransition: false,
      child: ListView(
        children: [
          const HomeTopWidget(),
          BlackBox(height: _deviceHeight * 0.2),
          HomeServiceMenu(height: _deviceHeight * 0.14),
          const VerifyIdWidget(),
          const HomeMiddleWidget(),
          const HomeFundRequestContainer(),
          const HomePageBottomBar(),
        ],
      ),
    );
  }
}
