import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';
import 'package:flutter/material.dart';

const bool _enableLog = false;

void activateLog() {
  if (!_enableLog) {
    return;
  }
  AppFlowyLogConfiguration()
    ..handler = debugPrint
    ..level = AppFlowyEditorLogLevel.all;
}

void deactivateLog() {
  if (!_enableLog) {
    return;
  }
  AppFlowyLogConfiguration()
    ..handler = null
    ..level = AppFlowyEditorLogLevel.off;
}
