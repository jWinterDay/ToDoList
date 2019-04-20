import 'dart:convert';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

TodoListModel todoListModelFromJson(String str) => TodoListModel.fromJson(json.decode(str));

String todoListModelToJson(TodoListModel data) => json.encode(data.toJson());



class TodoListModel {
  String error;
  bool isLoading;
  List<TodoModel> list;

  TodoListModel({
    this.error,
    this.isLoading,
    this.list,
  });

  factory TodoListModel.fromJson(Map<String, dynamic> json) => new TodoListModel(
    error: json["error"],
    isLoading: json["is_loading"],
    list: new List<TodoModel>.from(json["list"].map((x) => TodoModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "is_loading": isLoading,
    "list": new List<dynamic>.from(list.map((x) => x.toJson())),
  };

  @override
  String toString() {
    return
    """
    (error: $error, is loading: $isLoading, list: $list)
    """;
  }
}

class TodoModel {
  int todoListId;
  String name;
  bool isFinished;
  String guid;

  TodoModel({
    this.todoListId,
    this.name,
    this.isFinished,
    this.guid,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => new TodoModel(
    todoListId: json["todo_list_id"],
    name: json["name"],
    isFinished: json["is_finished"] == 1,
    guid: json["guid"],
  );

  Map<String, dynamic> toJson() => {
    "todo_list_id": todoListId,
    "name": name,
    "is_finished": isFinished ? 1 : 0,
    "guid": guid,
  };

  @override
  String toString() {
    return
    """
    (id: $todoListId, name: $name, is finished: $isFinished)
    """;
  }
}
