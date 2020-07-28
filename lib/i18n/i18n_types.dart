import 'package:flutter/material.dart';

abstract class IFormField {
  String get label;
  String get hint;
  String get nullError;
  Widget get icon;

  const IFormField();

  InputDecoration get decorator => InputDecoration(
    hintText: hint,
    labelText: label,
    icon: icon
  );
}

class SimpleFormField extends IFormField {
  final String label;
  final String hint;
  final String nullError;
  final Widget icon;

  const SimpleFormField(this.label, [this.hint, this.nullError, this.icon]);
}