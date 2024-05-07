import 'package:html_unescape/html_unescape.dart';

String capitalizeEachWord(String input) {
  input = input.trim();

  var unescape = HtmlUnescape();
  input = (unescape.convert(input));

  // if (input.contains('&quot;') || input.contains('&amp;')) {
  //   input = input.replaceAll('&quot;', '"');
  //   input = input.replaceAll('&amp;', '&');
  // }

  return input
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word.capitalize())
      .join(' ');
}

extension StringExtension on String {
  String capitalize() {
    // Find the index of the first letter
    int index = 0;
    while (index < length && !RegExp(r'[a-zA-Z]').hasMatch(this[index])) {
      index++;
    }

    // If index is at the end, return the original string
    if (index == length) {
      return this;
    }

    // Capitalize the first letter and return the modified string
    return "${substring(0, index)}${this[index].toUpperCase()}${substring(index + 1).toLowerCase()}";
  }
}
