import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppFormatters {
  static MaskTextInputFormatter get cpfFormatter => MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      );

  static MaskTextInputFormatter get phoneFormatter => MaskTextInputFormatter(
        mask: '(##) #####-####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      );

  static MaskTextInputFormatter get dateFormatter => MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      );
}
