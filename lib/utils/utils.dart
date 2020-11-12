bool equalsIgnoreCase(String string1, String string2) {
  return string1?.toLowerCase() == string2?.toLowerCase();
}

bool isEmpty(String str) {
  if (str == null || str.isEmpty) {
    return true;
  }
  return false;
}
