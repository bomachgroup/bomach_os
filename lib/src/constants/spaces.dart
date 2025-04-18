import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

const double kDefaultSpaceTiny = 5;
const double kDefaultSpaceSM = 10;
const double kDefaultSpace = 20;
const double kDefaultSpaceBG = 30;

double bodySpace(BuildContext context) {
  if (isLargeScreen(context)) {
    return MediaQuery.sizeOf(context).width - 462;
  }
  return MediaQuery.sizeOf(context).width;
}

const kSizedBoxTiny = SizedBox(height: kDefaultSpaceTiny);
const kSizedBoxSM = SizedBox(height: kDefaultSpaceSM);
const kSizedBox = SizedBox(height: kDefaultSpace);
const kSizedBoxBG = SizedBox(height: kDefaultSpace * 2);

const kSizedBoxWidthTiny = SizedBox(width: kDefaultSpaceTiny);
const kSizedBoxWidthSM = SizedBox(width: kDefaultSpaceSM);
const kSizedBoxWidth = SizedBox(width: kDefaultSpace);
const kSizedBoxWidthBG = SizedBox(width: kDefaultSpace * 2);
