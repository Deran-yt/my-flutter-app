class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime timestamp;
  bool favorite;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    this.favorite = false,
  });
}
