import 'package:flutter/material.dart';

class ImageWithPlaceholder extends StatelessWidget {
  final String networkImage;
  final String? assetImage;
  const ImageWithPlaceholder({
    Key? key,
    this.assetImage,
    required this.networkImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: AssetImage(assetImage ?? 'images/placeholder.png'),
      image: NetworkImage(networkImage),
      fit: BoxFit.fill,
    );
  }
}
