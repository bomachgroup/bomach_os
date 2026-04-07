import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = kReleaseMode
      ? 'https://bomachauth.bgbot.app'
      : 'https://bomachauthtest.bgbot.app';
}
