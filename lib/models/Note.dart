class Note {
  Note(this.id, this.title, this.content, this.date);
  int id;
  String title;
  String content;
  String date;

  get isOdd => this.id % 2 == 1;

  getId() {
    return this.id;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    content = map['content'];
    date = map['date'];
  }
}
