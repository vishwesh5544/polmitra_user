import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/utils/text_builder.dart';

import '../../models/event.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final bool isUploadEnabled;

  const EventDetailsScreen({required this.event, this.isUploadEnabled = true, super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final Event _event;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _event = widget.event;
    });
  }

  Future<void> _pickImages(int maxFiles) async {
    if (maxFiles == 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You can only upload 3 images'),
        duration: Duration(seconds: 2),
      ));
    }

    final List<XFile> pickedFileList = await _picker.pickMultiImage();
    if (pickedFileList.isNotEmpty) {
      setState(() {
        _imageFileList = pickedFileList;
      });
    }
  }

  void _closeSheet() {

  }

  @override
  Widget build(BuildContext context) {
    // adding comment for testing workflow
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Event Details',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _event.images.first,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBuilder.getText(text: _event.date, fontSize: 18, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        TextBuilder.getText(text: _event.eventName, fontSize: 18, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        TextBuilder.getText(text: _event.address, fontSize: 14, fontWeight: FontWeight.normal),
                        TextBuilder.getText(text: _event.city.cityname, fontSize: 14, fontWeight: FontWeight.normal),
                        TextBuilder.getText(text: _event.state.statename, fontSize: 14, fontWeight: FontWeight.normal),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextBuilder.getText(text: _event.description, overflow: TextOverflow.visible, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextBuilder.getText(text: 'Event photos:', fontSize: 16, fontWeight: FontWeight.bold),
                  if (widget.isUploadEnabled)
                    IconButton(
                      onPressed: () {
                        _pickImages(_imageFileList.length);
                      },
                      icon: const Icon(Icons.add_a_photo),
                    )
                ],
              ),
              const SizedBox(height: 10),
              CarouselSlider.builder(
                  itemCount: _event.images.length,
                  itemBuilder: (context, index, realIndex) {
                    return CachedNetworkImage(
                      imageUrl: _event.images[index],
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  options: CarouselOptions(
                    height: 180,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
