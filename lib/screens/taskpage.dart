import 'package:flutter/material.dart';
import 'package:sqllite/utils/db.dart';
import 'package:sqllite/utils/tasks.dart';
import 'package:sqllite/utils/todo.dart';
import 'package:sqllite/widgets/widget.dart';

class TaskPage extends StatefulWidget {
  final Task task;

  const TaskPage({@required this.task});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String _taskTitle = '';
  String _taskDesc = '';
  int _taskId = 0;

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;
  FocusNode _focusTodo;

  bool _contentVisible = false;

  @override
  void initState() {
    if (widget.task != null) {
      //sets visibility to true
      _contentVisible = true;

      _taskTitle = widget.task.title;
      _taskDesc = widget.task.description;
      _taskId = widget.task.id;
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _focusTodo = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _focusTodo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 6.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Image(
                              image: AssetImage(
                                  'assets/images/back_arrow_icon.png')),
                        ),
                      ),
                      Expanded(
                          child: TextField(
                        focusNode: _titleFocus,
                        onSubmitted: (value) async {
                          //check if new task text is empty
                          if (value != '') {
                            //check if task is null
                          if (widget.task == null) {
                                  Task _newTask = Task(title: value);
                                  _taskId = await DB().insertTask(_newTask);
                                  setState(() {
                                    _contentVisible = true;
                                    _taskTitle = value;
                                  });
                                } else {
                                  await DB().updateTaskTitle(_taskId, value);
                                  print("Task Updated");
                                }
                                _descriptionFocus.requestFocus();
                              }
                            },
                        controller: TextEditingController()..text = _taskTitle,
                        decoration: InputDecoration(
                          hintText: "Enter Task Title",
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF211551)),
                      ))
                    ],
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      focusNode: _descriptionFocus,
                      onSubmitted: (value) async {
                        if (value != '') {
                          if (_taskId != 0) {
                            await DB().updateTaskDesc(_taskId, value);
                            _taskDesc = value;
                          }
                        }
                        _focusTodo.requestFocus();
                      },
                      decoration: InputDecoration(
                          hintText: "Enter the decription for the Task...",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 24.0)),
                      controller: TextEditingController()..text = _taskDesc,
                    ),
                  ),
                ),
                Visibility(
                    visible: _contentVisible,
                    child: FutureBuilder(
                      initialData: [],
                      future: DB().getTodo(_taskId),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    //change from done to notDone
                                    if (snapshot.data[index].isDone == 0) {
                                      await DB().updateTodoDone(
                                          snapshot.data[index].id, 1);
                                    } else {
                                      await DB().updateTodoDone(
                                          snapshot.data[index].id, 0);
                                    }
                                    setState(() {});
                                  },
                                  child: TodoWidget(
                                    isDone: snapshot.data[index].isDone == 0
                                        ? false
                                        : true,
                                    text: snapshot.data[index].title,
                                  ),
                                );
                              }),
                        );
                      },
                    )),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          margin: EdgeInsets.only(
                            right: 12.0,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                  color: Color(0xFF86829D), width: 1.5)),
                          child: Image(
                            image: AssetImage('assets/images/check_icon.png'),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _focusTodo,
                            controller: TextEditingController()..text = "",
                            onSubmitted: (value) async {
                              // Check if the field is not empty
                              if (value != "") {
                                if (_taskId != 0) {
                                  Todo _newTodo = Todo(
                                    title: value,
                                    isDone: 0,
                                    taskID: _taskId,
                                  );
                                  await DB().insertTodo(_newTodo);
                                  setState(() {});
                                  _focusTodo.requestFocus();
                                } else {
                                  print("Task doesn't exist");
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Todo item...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Visibility(
              visible: _contentVisible,
              child: Positioned(
                bottom: 24.0,
                right: 24.0,
                child: GestureDetector(
                  onTap: () async {
                    if (_taskId != 0) {
                      await DB().deleteTask(_taskId);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Image(
                          image: AssetImage('assets/images/delete_icon.png'))),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
