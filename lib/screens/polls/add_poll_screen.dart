import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/poll/poll_bloc.dart';
import 'package:user_app/bloc/poll/poll_event.dart';
import 'package:user_app/bloc/poll/poll_state.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/icon_builder.dart';

class AddPollScreen extends StatefulWidget {
  const AddPollScreen({super.key});

  @override
  State<AddPollScreen> createState() => _AddPollScreenState();
}

class _AddPollScreenState extends State<AddPollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _optionControllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPoll() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bloc = context.read<PollBloc>();

    String? role = await PrefsService.getRole();
    if (role == null || role != UserRole.neta.toString()) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Only Netas can add polls'),
        ),
      );
      return;
    }

    String? userId = await PrefsService.getUserId();
    if(userId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    final question = _questionController.text.trim();
    final options = _optionControllers.map((controller) => controller.text.trim()).toList();


    bloc.add(AddPollEvent(question: question, options: options, userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PollBloc, PollState>(
      listener: (context, state) {
        if (state is PollAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poll added successfully'),
            ),
          );
          Navigator.pop(context);
        } else if (state is PollError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Add Poll",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(width: 50)
                ],
              ),
              _form()
            ],
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Poll Question', enabledBorder: UnderlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Please enter the poll question' : null,
            ),
            ...List.generate(_optionControllers.length, (index) {
              return TextFormField(
                controller: _optionControllers[index],
                decoration:
                    InputDecoration(labelText: 'Option ${index + 1}', enabledBorder: const UnderlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter an option' : null,
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addPoll();
              },
              child: const Text('Add Poll'),
            ),
          ],
        ),
      ),
    );
  }
}
