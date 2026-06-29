import 'package:flutter/material.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:tmjapp/utils/components/smooth_star_rating.dart';

class MyRating extends StatefulWidget {
  final String? rating;

  const MyRating({Key? key, this.rating}) : super(key: key);

  @override
  _MyRatingState createState() => _MyRatingState();
}

class _MyRatingState extends State<MyRating> {
  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
        allowHalfRating: true,
        onRated: (v) {},
        starCount: 5,
        rating: double.parse(widget.rating ?? "0"),
        size: 20.0,
        isReadOnly: true,
        filledIconData: Icons.star,
        halfFilledIconData: Icons.star,
        color: CustomColor.accentColor,
        borderColor: CustomColor.secondaryColor,
        spacing: 0.0);
  }
}
