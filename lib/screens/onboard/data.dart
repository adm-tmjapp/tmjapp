import 'package:tmjapp/utils/strings.dart';

class OnBoardingItem {
  final String? title;
  final String? subTitle;
  final String? image;

  const OnBoardingItem({this.title, this.subTitle, this.image});
}

class OnBoardingItems {
  static List<OnBoardingItem> loadOnboardItem() {
    const fi = <OnBoardingItem>[
      OnBoardingItem(
        title: Strings.title1,
        subTitle: Strings.subTitle1,
        image: 'assets/onboard/1.png',
      ),
      OnBoardingItem(
        title: Strings.title2,
        subTitle: Strings.subTitle2,
        image: 'assets/onboard/2.png',
      ),
      // OnBoardingItem(
      //   title: Strings.title3,
      //   subTitle: Strings.subTitle3,
      //   image: 'assets/onboard/3.png',
      // ),
      OnBoardingItem(
        title: Strings.title4,
        subTitle: Strings.subTitle4,
        image: 'assets/onboard/4.png',
      ),
    ];
    return fi;
  }
}
