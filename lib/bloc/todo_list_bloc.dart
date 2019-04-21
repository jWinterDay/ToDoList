import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:todo_list/resources/todo_list_repository.dart';
import 'package:todo_list/models/todo_list_model.dart';


//Function projectEq = const ListEquality().equals;

class TodoListBloc {
  final _todoListRepository = TodoListRepository();

  //list fetcher
  final PublishSubject<TodoListModel> _todoListFetcher = new PublishSubject<TodoListModel>();
  StreamSink<TodoListModel> get inSink => _todoListFetcher.sink;
  Observable<TodoListModel> get todoListStream => _todoListFetcher.stream;

  //search
  final PublishSubject<String> _searchController = new PublishSubject<String>();
  StreamSink<String> get searchSink => _searchController.sink;
  ValueConnectableObservable<String> _searchValueStream;

  //input new task
  final PublishSubject<String> _nextTaskFetcher = new PublishSubject<String>();
  StreamSink<String> get nextTaskSink => _nextTaskFetcher.sink;
  ValueConnectableObservable<String> _nextTaskValueStream;
  Observable<bool> _nextTaskStream;
  Observable<bool> get nextTaskStream => _nextTaskStream;

  //constructor
  TodoListBloc() {
    //search
    _searchValueStream =
      _searchController.stream
        .debounce(Duration(milliseconds: 300))
        .doOnData((val) {
          fetchTodoList(filterName: val);
        })
        .publishValue();
    
    //next task
    _nextTaskValueStream = _nextTaskFetcher.stream.publishValue();
    
    //determine correct input text. Convert input value to bool result
    _nextTaskStream =
      _nextTaskFetcher.stream
        .debounce(Duration(milliseconds: 300))
        .map((val) {
          return val != null && val.trim() != '';
        });

    _searchValueStream.connect();//start listen search input
    _nextTaskValueStream.connect();//start listen new task name input
  }


  fetchTodoList({String filterName=''}) async {
    TodoListModel todoList;

    try {
      todoList = await _todoListRepository.getTodoList(filterName: filterName);
      inSink.add(todoList);
    } catch (err) {
      inSink.add(new TodoListModel(error: err, isLoading: false, list: null));
    }

    return todoList;
  }

  addTodoList() async {
    String taskName = _nextTaskValueStream.value;
    await _todoListRepository.newTodoList(taskName);

    //refresh with current filter value
    String search = _searchValueStream.value;

    fetchTodoList(filterName: search);
  }

  setFinished(int todoListId,) async {
    await _todoListRepository.setFinished(todoListId);

    //refresh with current filter value
    String search = _searchValueStream.value;
    fetchTodoList(filterName: search);
  }

  dispose() async {
    await _todoListFetcher.drain();
    await _todoListFetcher.close();

    await _nextTaskFetcher.drain();
    await _nextTaskFetcher.close();

    await _searchController.drain();
    await _searchController.close();
  }
}