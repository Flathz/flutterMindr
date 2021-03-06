class Note {
  Note(this.id, this.title, this.content);
  final int id;
  final String title;
  final String content;

  get isOdd => this.id % 2 == 1;

  getId() {
    return this.id;
  }
}
