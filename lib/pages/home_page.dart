import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_app/util/todo_title.dart';
import '../data/database.dart';
import '../util/dialog_box.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();


  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();


  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow.shade100,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade100,
          toolbarHeight: 100,
          shape: const RoundedRectangleBorder(
              borderRadius:  BorderRadius.only(
                  bottomRight: Radius.circular(70),
                  bottomLeft: Radius.circular(70))
          ),
          title: Text('TO DO',
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          elevation: 14,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                      labelText: 'DATE',
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue
                          )
                      )
                  ),
                  readOnly: true,
                  onTap: (){
                    _selectDate();
                  },
                )
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                      labelText: 'Time',
                      filled: true,
                      prefixIcon: Icon(Icons.punch_clock),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue
                          )
                      )
                  ),
                  readOnly: true,
                  onTap: (){
                    _selectTime();
                  },
                )
            ),

            Expanded(
              child: ListView.builder(
                itemCount: db.toDoList.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                    taskName: db.toDoList[index][0],
                    taskCompleted: db.toDoList[index][1],
                    onChanged: (value) => checkBoxChanged(value, index),
                    deleteFunction: (context) => deleteTask(index),
                  );
                },
              ),
            ),
          ],
        )
    );
  }
  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (_picked != null) {
      setState(() {
        _dateController.text  = _picked.toString().split(" ")[0];
      });
    }
  }
  Future<void> _selectTime() async {
    TimeOfDay? _picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );

    if (_picked != null) {
      setState(() {
        _timeController.text  = _picked.format(context).toString().split(" ")[0];
      });
    }
  }
}