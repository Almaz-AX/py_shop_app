import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

class DioService {
  final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

  Future<void> post({required String text, required XFile image, double? latitude, double? longitude}) async {
    try {
      final response = await dio.post('/posts',
          data: FormData.fromMap({
            'comment': text,
            'photo': image,
            'latitude': latitude,
            'longitude': longitude
          }));
      print(response.data);
    } catch (e) {
      print(e.toString());
    }
  }
}
