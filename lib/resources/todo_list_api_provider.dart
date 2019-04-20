import 'package:sqflite/sqflite.dart';

import 'package:todo_list/models/todo_list_model.dart';
import 'package:todo_list/database.dart';// as database;

class TodoListApiProvider {
  Future<TodoListModel> getTodoList({String filterName = ''}) async {
    //check for injection
    RegExp reg = RegExp(r"^(\w{0,20})$", caseSensitive: false);
    if(!reg.hasMatch(filterName??'')) {
      return new TodoListModel(error: 'wrong type of search', isLoading: false, list: null);
    }

    Database db = await DBProvider.instance.database;
    //var res = await db.query('todo_list', where: "name like '%$filterName%'", orderBy: 'is_finished');
    var res = await db.rawQuery(
      '''
      select *
        from todo_list
       where name like '%$filterName%'
       order by is_finished, name-- is_finished, name
      '''
    );// query('todo_list', where: "name like '%$filterName%'", orderBy: 'is_finished');
    List<TodoModel> list = res.isNotEmpty ? res.map((p) => TodoModel.fromJson(p)).toList() : [];

    return new TodoListModel(isLoading: false, list: list);
  }

  setFinished(int todoListId,) async {
    Database db = await DBProvider.instance.database;

    await db.rawUpdate(
      '''
      update todo_list
         set is_finished = case when is_finished = 1 then 0 else 1 end
       where todo_list_id = ?
      ''',
      [todoListId]
    );
  }

  newTodoList(String name) async {
    Database db = await DBProvider.instance.database;

    await db.rawInsert(
      '''
      insert into todo_list(name)
      values(?)
      ''',
      [name]
    );
  }
}