import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:py_shop_app/dio_service.dart';
import 'package:py_shop_app/post_screen.dart';

class TakePostScreen extends StatefulWidget {
  const TakePostScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePostScreenState createState() => TakePostScreenState();
}

class TakePostScreenState extends State<TakePostScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final textController = TextEditingController();
  final dioService = DioService();
  bool loadingProgress = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _takePost() async {
    if (loadingProgress == true) {
      return;
    }
    loadingProgress = true;
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!mounted) return;
      final position = await _determinePosition();
      await dioService.post(
          text: textController.text,
          image: image,
          latitude: position.latitude,
          longitude: position.longitude);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostScreen(
            imagePath: image.path,
            comment: textController.text,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
    loadingProgress = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать пост')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              children: [
                CameraPreview(_controller),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textController,
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _takePost();
        },
        label:const Text('Опубликовть пост'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
