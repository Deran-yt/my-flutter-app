String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final email = value.trim();
  final regex = RegExp(r"^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}");
  if (!regex.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateConfirmPassword(String? password, String? confirm) {
  if (confirm == null || confirm.isEmpty) return 'Confirm your password';
  if (password != confirm) return 'Passwords do not match';
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) return 'Username is required';
  if (value.trim().length < 3) return 'Username must be at least 3 characters';
  return null;
}
