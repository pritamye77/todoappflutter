class Todo {
  final int id;
  final String title;
  final int isDone;
  final int taskID;

  Todo({this.taskID, this.id, this.title, this.isDone});

  Map<String, dynamic> toMap() {
    return {'id': id, 'taskID': taskID, 'title': title, 'isDone': isDone};
  }
}
