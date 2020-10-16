import 'package:flutter/material.dart';
import 'package:sqllite/screens/taskpage.dart';
import 'package:sqllite/utils/db.dart';
import 'package:sqllite/widgets/widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DB _db = DB();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        width: double.infinity,
        color: Color(0xFFF6F6F6),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 25.0, top: 32.0),
                  decoration: BoxDecoration(color: Colors.white54),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _db.getTasks(),
                    initialData: [],
                    builder: (context, snapshot) {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskPage(
                                                  task: snapshot.data[i],
                                                )))
                                    .then((value) => setState(() {}));
                              },
                              child: TaskCard(
                                title: snapshot.data[i].title,
                                desc: snapshot.data[i].description,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 24.0,
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskPage(
                                task: null,
                              ))).then((value) => setState(() {}));
                },
                child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20.0)),
                    child:
                        Image(image: AssetImage('assets/images/add_icon.png'))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
