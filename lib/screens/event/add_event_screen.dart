import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/bloc/polmitra_event/pevent_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_event.dart';
import 'package:user_app/bloc/polmitra_event/pevent_state.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/icon_builder.dart';
import 'package:user_app/utils/text_builder.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList = [];



  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      _dateController.text = _formatDate(selectedDate);
      _timeController.text = _formatTime(selectedTime);
    });
  }

  void _addEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bloc = context.read<EventBloc>();

    String? role = await PrefsService.getRole();
    if (role == null || role != UserRole.karyakarta.toString()) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Only Karyakartas can add events'),
        ),
      );
      return;
    }

    String? userId = await PrefsService.getUserId();
    if (userId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    String? netaId = await PrefsService.getNetaId();
    if (netaId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Neta not found'),
        ),
      );
      return;
    }

    final eventName = _eventNameController.text.trim();
    final eventDescription = _eventDescriptionController.text.trim();
    final location = _locationController.text.trim();

    bloc.add(UploadDataEvent(
      eventName: eventName,
      description: eventDescription,
      location: location,
      date: _formatDate(selectedDate),
      time: _formatTime(selectedTime),
      karyakartaId: userId,
      netaId: netaId,
      images: _imageFileList,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, PolmitraEventState>(
      listener: (context, state) {
        if (state is AddEventLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(minutes: 60),
              content: Text('Adding event...'),
            ),
          );
        } else if (state is AddEventSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added successfully'),
            ),
          );
          Navigator.pop(context);
        } else if (state is AddEventFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconBuilder.buildButton(
                      icon: Icons.arrow_back_ios_new_outlined,
                      color: ColorProvider.normalBlack,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      size: 20),
                  TextBuilder.getText(
                      text: "Add Event", color: ColorProvider.normalBlack, fontWeight: FontWeight.bold, fontSize: 25),
                  const SizedBox(width: 50)
                ],
              ),
              _form(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime, initialEntryMode: TimePickerEntryMode.input);
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFileList = await _picker.pickMultiImage();
    if (pickedFileList.isNotEmpty) {
      setState(() {
        _imageFileList = pickedFileList;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: 'Event name', enabledBorder: UnderlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _eventDescriptionController,
              decoration: const InputDecoration(labelText: 'Description', enabledBorder: UnderlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () {
                _selectDate(context);
              },
              decoration: const InputDecoration(labelText: 'Date', enabledBorder: UnderlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _timeController,
              readOnly: true,
              onTap: () {
                _selectTime(context);
              },
              decoration: const InputDecoration(labelText: 'Time', enabledBorder: UnderlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', enabledBorder: UnderlineInputBorder()),
                  ),
                ),
                IconBuilder.buildButton(
                  icon: Icons.add_a_photo,
                  onPressed: _pickImages,
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: ColorProvider.lightGreyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addEvent();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
