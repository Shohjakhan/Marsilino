import 'package:dio/dio.dart';

void main() async {
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://marsilino.onrender.com/api/v1/tags/',
    );
    final body = response.data;
    List<dynamic> tagList;
    if (body is Map<String, dynamic> &&
        body['success'] == true &&
        body['data'] is List) {
      tagList = body['data'] as List<dynamic>;
    } else if (body is List) {
      tagList = body;
    } else {
      print('Invalid structure');
      return;
    }

    print('tagList: $tagList');
  } catch (e) {
    print('Error: $e');
  }
}
