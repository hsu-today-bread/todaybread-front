import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todaybread/utils/display_helper.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = DisplayHelper.resolveImageUrl(imageUrl);
    if (resolvedImageUrl == null) {
      return placeholder;
    }

    if (_isSvg(resolvedImageUrl)) {
      return SvgPicture.network(
        resolvedImageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => placeholder,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return Image.network(
      resolvedImageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  bool _isSvg(String value) {
    final path = Uri.tryParse(value)?.path.toLowerCase() ?? value.toLowerCase();
    return path.endsWith('.svg');
  }
}
