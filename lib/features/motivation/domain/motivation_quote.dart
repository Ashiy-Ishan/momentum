import 'package:equatable/equatable.dart';

class MotivationQuote extends Equatable {
  final String text;
  final String? author;
  final String category;

  const MotivationQuote({
    required this.text,
    this.author,
    required this.category,
  });

  @override
  List<Object?> get props => [text, author, category];

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'category': category,
    };
  }

  factory MotivationQuote.fromMap(Map<String, dynamic> map) {
    return MotivationQuote(
      text: (map['text'] ?? '').toString(),
      author: map['author']?.toString(),
      category: (map['category'] ?? 'general').toString(),
    );
  }

  @override
  String toString() {
    if (author != null && author!.isNotEmpty) {
      return '"$text" — $author';
    }
    return '"$text"';
  }
}
