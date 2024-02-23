import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit_simple/app/pages/home/cubit/todo_cubit.dart';
import 'package:flutter_cubit_simple/app/pages/home/cubit/todo_states.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TodoCubit cubit;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<TodoCubit>(context);
    cubit.stream.listen((state) {
      if (state is ErrorTodoState) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          BlocBuilder(
            bloc: cubit,
            builder: (context, state) {
              if (state is InitialTodoState) {
                return const Center(
                  child: Text('Nenhuma tarefa foi adicionada ainda'),
                );
              } else if (state is LoadingTodoState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is LoadedTodoState) {
                return _buildTodoList(state.todos);
              } else {
                return _buildTodoList(cubit.todos);
              }
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  offset: const Offset(0, -5),
                  blurRadius: 4,
                )
              ]),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                  child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Digitie um nome',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      cubit.addTodo(todo: _nameController.text);
                      _nameController.clear();
                    },
                    child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white),
                        )),
                  )
                ],
              )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTodoList(List<String> todos) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (_, index) {
        return ListTile(
          leading: CircleAvatar(
              child: Center(
            child: Text(todos[index][0]),
          )),
          title: Text(todos[index]),
          trailing: IconButton(
            onPressed: () {
              cubit.removeTodo(index: index);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
