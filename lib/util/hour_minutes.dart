import 'dart:math';

import 'package:time_track_transfer/util/pair.dart';


Pair<int, int>? parseHourMinutes(String text) {
  String parsedString = text.replaceAll(RegExp(r"\D"), "");

  int parsedInt = int.parse(parsedString);

  int length = text.length;

  if (length == 0) {
    return null;
  }

  if (length == 1) {
    return Pair(parsedInt, 0);
  }

  if (length == 2) {
    if (parsedInt > 23) {
      return Pair(parsedInt ~/ 10, (parsedInt % 10) * 10);
    }
    return Pair(parsedInt, 0);
  }

  if (length == 3) {
    int firstTwo = parsedInt ~/ 10;

    if (firstTwo < 24) {
      return Pair(firstTwo, (parsedInt % 10) * 10);
    }

    return Pair(parsedInt ~/ 100, parsedInt % 100);
  }

  int magic = pow(10, length - 2).toInt();

  if (parsedInt ~/ magic > 23) {
    magic = pow(10, length - 1).toInt();
  }

  int last = (parsedInt % magic) * 10;

  while (last > 60) {
    last = last ~/ 10;
  }

  return Pair(parsedInt ~/ magic, last);
}

extension PairToString on Pair<int, int>? {
  String pairToString() {
    if (this == null) {
      return "";
    }
    String secondString = this!.second.toString();

    if (this!.second < 10) {
      secondString = "0$secondString";
    }

    return "${this!.first}:$secondString";
  }
}
