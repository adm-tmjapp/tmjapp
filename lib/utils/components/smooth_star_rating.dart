library smooth_star_rating;

import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class SmoothStarRating extends StatelessWidget {
  final int? starCount;
  final double? rating;
  final RatingChangeCallback? onRatingChanged;
  final Color ?color;
  final Color ?borderColor;
  final double ?size;
    final RatingChangeCallback? onRated; // Add this line

  final bool ?allowHalfRating;
  final IconData ?filledIconData;
  final IconData ?halfFilledIconData;
  final bool? isReadOnly;
  final IconData
      ?defaultIconData; //this is needed only when having fullRatedIconData && halfRatedIconData
  final double spacing;
  SmoothStarRating({
    this.starCount = 5,
    this.spacing=0.0,
    this.rating = 0.0,
    this.defaultIconData,
    this.onRatingChanged,
        this.onRated, // Add this line
this.isReadOnly = false,
    this.color,
    this.borderColor,
    this.size = 25,
    this.filledIconData,
    this.halfFilledIconData,
    this.allowHalfRating = true,
  }) {
    assert(this.rating != null);
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (rating!=null && index >= rating!) {
      icon = new Icon(
        defaultIconData != null ? defaultIconData : Icons.star_border,
        color: borderColor ?? Theme.of(context).primaryColor,
        size: size,
      );
    } else if (index > rating! - (allowHalfRating??false ? 0.5 : 1.0) &&
        index < rating!) {
      icon = new Icon(
        halfFilledIconData != null ? halfFilledIconData : Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    } else {
      icon = new Icon(
        filledIconData != null ? filledIconData : Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    }
return GestureDetector(
  onTap: () {
    if (this.onRatingChanged != null) onRatingChanged!(index + 1.0);
  },
  onHorizontalDragUpdate: (dragDetails) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      var _pos = box.globalToLocal(dragDetails.globalPosition);
      var i = _pos.dx / size!;
      var newRating = (allowHalfRating ?? false) ? i : i.round().toDouble();
      if (starCount != null && newRating > starCount!) {
        newRating = starCount?.toDouble()??0;
      }
      if (newRating < 0) {
        newRating = 0.0;
      }
      if (this.onRatingChanged != null) onRatingChanged!(newRating);
    }
  },
  child: icon,
);


  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.transparent,
      child: new Wrap(
          alignment: WrapAlignment.start,
          spacing: spacing,
          children: new List.generate(
              starCount??0, (index) => buildStar(context, index))),
    );
  }
}