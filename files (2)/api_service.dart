import 'package:dio/dio.dart';
import '../models/task.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // Use 'http://localhost:8000' for iOS simulator or web

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<List<Task>> getTasks({String? search, String? status}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status != 'All') params['status'] = status;

    final response = await _dio.get('/tasks', queryParameters: params);
    return (response.data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    final response = await _dio.post('/tasks', data: data);
    return Task.fromJson(response.data);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/tasks/$id', data: data);
    return Task.fromJson(response.data);
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete('/tasks/$id');
  }

  Future<void> reorderTasks(List<Map<String, dynamic>> items) async {
    await _dio.patch('/tasks/reorder/bulk', data: {'items': items});
  }
}
