class Note {
  Note(this.id, this.title, this.description);

  int id;
  String title;
  String description;

    Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
    };
    return map;
  }

    Note.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }
}
