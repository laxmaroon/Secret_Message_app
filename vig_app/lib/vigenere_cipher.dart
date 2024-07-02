String encrypt(String text, String key) {
  key = key.toUpperCase();
  text = text.toUpperCase();
  String result = '';

  int keyIndex = 0;
  for (int i = 0; i < text.length; i++) {
    if (text[i].codeUnitAt(0) >= 65 && text[i].codeUnitAt(0) <= 90) {
      int letterIndex =
          (text[i].codeUnitAt(0) - 65 + key[keyIndex].codeUnitAt(0) - 65) % 26;
      result += String.fromCharCode(letterIndex + 65);
      keyIndex = (keyIndex + 1) % key.length;
    } else {
      result += text[i];
    }
  }
  return result;
}

String decrypt(String text, String key) {
  key = key.toUpperCase();
  text = text.toUpperCase();
  String result = '';

  int keyIndex = 0;
  for (int i = 0; i < text.length; i++) {
    if (text[i].codeUnitAt(0) >= 65 && text[i].codeUnitAt(0) <= 90) {
      int letterIndex = (text[i].codeUnitAt(0) -
              65 -
              (key[keyIndex].codeUnitAt(0) - 65) +
              26) %
          26;
      result += String.fromCharCode(letterIndex + 65);
      keyIndex = (keyIndex + 1) % key.length;
    } else {
      result += text[i];
    }
  }
  return result;
}
