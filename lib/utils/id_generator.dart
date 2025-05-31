// A simple ID generator for mock data

String generateId() {
  // Generate a random ID based on the current timestamp and a random component
  return DateTime.now().millisecondsSinceEpoch.toString() + 
         (1000 + DateTime.now().microsecond % 9000).toString();
}