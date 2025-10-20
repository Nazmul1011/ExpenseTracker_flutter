import 'package:flutter/services.dart';

import '../widgets/text_form_field/app_text_form_field.dart';

List<TextInputFormatter>? getInputFormatters(FormFieldType type) {
  switch (type) {
    case FormFieldType.name:
      // Only allow letters (a-z, A-Z) and spaces
      return [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))];
    case FormFieldType.phone:
      // Allow only digits 0-9
      return [FilteringTextInputFormatter.digitsOnly];
    case FormFieldType.email:
      // Allow all visible characters except whitespace (optional: no formatter here)
      // Usually emails need flexible input, so no formatter or allow wide set
      // But to disallow spaces you can do:
      return [FilteringTextInputFormatter.deny(RegExp(r"\s"))];
    case FormFieldType.number:
      // Allow digits and decimal point (if needed)
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    case FormFieldType.password:
    case FormFieldType.confirmPassword:
      // Usually no formatter, allow all characters
      return null;
    case FormFieldType.dob:
      // Date input — allow digits and slash or dash if used for date input
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9/-]'))];
    case FormFieldType.general:
      return null;
    case FormFieldType.readOnlyDisplay:
      throw UnimplementedError();
  }
}
