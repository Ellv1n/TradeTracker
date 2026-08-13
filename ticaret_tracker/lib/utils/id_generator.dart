int _counter = 0;

String generateId() {
  _counter++;
  return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
}
