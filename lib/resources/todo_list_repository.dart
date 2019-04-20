import 'todo_list_api_provider.dart';

class TodoListRepository {
  final TodoListApiProvider _todoListProvider = new TodoListApiProvider();

  getTodoList({String filterName = ''}) => _todoListProvider.getTodoList(filterName: filterName);
  setFinished(int todoListId,) => _todoListProvider.setFinished(todoListId,);
  newTodoList(String name) => _todoListProvider.newTodoList(name);
}