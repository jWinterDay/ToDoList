import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:todo_list/bloc/todo_list_bloc.dart';
import 'package:todo_list/models/todo_list_model.dart';

typedef addFuncType = void Function();

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin<HomeScreen>{
  TodoListBloc bloc = new TodoListBloc();
  TodoListModel _initData;

  Animation<Offset> _position;
  AnimationController _positionController;

  //constructor
  _HomeState() {
    _setInitData();
  }

  //===init state===
  _setInitData() async {
    _initData = await bloc.fetchTodoList();

    //position animation
    _positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _position = Tween(begin: Offset(2, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeIn,
      ),
    );

    //_positionController.addStatusListener((status) {
      //print('status = $status');

      //if (status == AnimationStatus.dismissed) {
      //  _positionController.forward();
      //}
    //});

    _positionController.forward();
  }

  void _addTodoList() => bloc.addTodoList();

  void _setIsFinished(TodoModel todoModel) {
    bloc.setFinished(todoModel.todoListId);
    //bloc.todoListStream.listen((d) {
    //  _positionController.reverse();
    //});
  }

  @override
  void dispose() {
    bloc.dispose();
    _positionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo list',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: <Widget>[
          //search
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              //height: 30,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  suffixIcon:Icon(Icons.search),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onChanged: (val) => bloc.searchSink.add(val),
              ),
            ),
          ),

          //rx add next task
          StreamBuilder(
            stream: bloc.nextTaskStream,
            initialData: false,//in start can't add next task
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return buildNextTaskInput(snapshot);
              } else if (snapshot.hasError) {
                return Text(snapshot.error);
              }

              return Center(child: CircularProgressIndicator());
            }
          ),

          //rx list
          StreamBuilder(
            initialData: _initData,
            stream: bloc.todoListStream,
            builder: (BuildContext context, AsyncSnapshot<TodoListModel> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: buildList(snapshot)
                );
              } else if (snapshot.hasError) {
                return
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(snapshot.error.toString()),
                );
              }

              return Center(child: CircularProgressIndicator());
            },
          )
        ],
      ),
    );
  }

  //add next task
  Widget buildNextTaskInput(AsyncSnapshot<bool> snapshot) {
    bool isCorrectInputValue = snapshot.data;

    Color addIconColor = isCorrectInputValue ? Colors.blue : Colors.grey;
    Function addEventFunction = isCorrectInputValue ? _addTodoList : null;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Container(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Add a task',
            hintStyle: TextStyle(fontStyle: FontStyle.italic),
            suffixIcon: Container(
              child: FlatButton.icon(
                //disabledColor: Colors.grey[300],
                icon: Icon(Icons.add_circle, color: addIconColor),
                label: Text('ADD'),
                onPressed: addEventFunction,
              ),
            ),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onChanged: (val) => bloc.nextTaskSink.add(val),
        ),
      ),
    );
  }

  //list
  Widget buildList(AsyncSnapshot<TodoListModel> snapshot) {
    if (snapshot.data.list == null || snapshot.data.list.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: TextStyle(fontSize: 30),
        )
      );
    }
    
    //_positionController. reverse();
    return ListView.builder(
      itemCount: snapshot.data.list == null ? 0 : snapshot.data.list.length,
      itemBuilder: (BuildContext context, int index) {
        final isLoading = snapshot.data.isLoading;

        //list
        if (snapshot.error == null) {
          TodoModel todoModel = snapshot.data.list[index];
          TextStyle ts = todoModel.isFinished ? TextStyle(fontWeight: FontWeight.w300, fontSize: 20, decoration: TextDecoration.lineThrough, ) :
                                                TextStyle(fontWeight: FontWeight.w600, fontSize: 20, decoration: TextDecoration.none, );

          return SlideTransition(
            position: Tween(begin:Offset(2, 10), end: Offset.zero).animate(CurvedAnimation(parent: _positionController, curve: Curves.easeIn)),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300])),
              ),
              child: ListTile(
                title: Text(todoModel.name, style: ts,),
                trailing: Icon(todoModel.isFinished ? Icons.check_circle : Icons.radio_button_unchecked),
                onTap: ()  {
                  _setIsFinished(todoModel);
                  
                },
              )
            ),
          );
        }
        
        //error
        return ListTile(
          title: Text(
            'Error while loading data...',
            style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16.0),
          ),
          isThreeLine: false,
          leading: CircleAvatar(
            child: Text(snapshot.error),
            foregroundColor: Colors.white,
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  //
  /*Widget buildList(AsyncSnapshot<TodoListModel> snapshot) {
    if (snapshot.data.list == null || snapshot.data.list.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: TextStyle(fontSize: 30),
        )
      );
    }

    return ListView.builder(
      itemCount: snapshot.data.list == null ? 0 : snapshot.data.list.length,
      itemBuilder: (BuildContext context, int index) {
        final isLoading = snapshot.data.isLoading;

        //list
        if (snapshot.error == null) {
          TodoModel todoModel = snapshot.data.list[index];
          TextStyle ts = todoModel.isFinished ? TextStyle(fontWeight: FontWeight.w300, fontSize: 20, decoration: TextDecoration.lineThrough, ) :
                                                TextStyle(fontWeight: FontWeight.w600, fontSize: 20, decoration: TextDecoration.none, );

          return SlideTransition(
            position: _position,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300])),
              ),
              child: ListTile(
                title: Text(todoModel.name, style: ts,),
                trailing: Icon(todoModel.isFinished ? Icons.check_circle : Icons.radio_button_unchecked),
                onTap: ()  {
                  _setIsFinished(todoModel);
                },
              ),
            ),
          );
        }
        
        //error
        return ListTile(
          title: Text(
            'Error while loading data...',
            style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16.0),
          ),
          isThreeLine: false,
          leading: CircleAvatar(
            child: Text(snapshot.error),
            foregroundColor: Colors.white,
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }*/
}

