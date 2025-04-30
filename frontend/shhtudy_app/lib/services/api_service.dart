import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = AppConfig.apiBaseUrl;

  ApiService() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // 회원가입
  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
    required String idToken,
  }) async {
    try {
      print('회원가입 시도 - URL: $_baseUrl/users');
      print('요청 데이터: name=$name, phone=$phone');
      
      final response = await _dio.post(
        '$_baseUrl/users',
        data: {
          'name': name,
          'phoneNumber': phone,  // phoneNumber로 키 이름 변경
          'password': password,
          'confirmPassword': password,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        ),
      );
      print('회원가입 성공: ${response.data}');
    } catch (e) {
      if (e is DioException) {
        print('회원가입 실패 - 상태 코드: ${e.response?.statusCode}');
        print('에러 응답: ${e.response?.data}');
        print('요청 URL: ${e.requestOptions.uri}');
        print('요청 헤더: ${e.requestOptions.headers}');
      }
      print('회원가입 실패: $e');
      throw e;
    }
  }

  // 로그인
  Future<String> login({
    required String phone,
    required String password,
  }) async {
    try {
      print('로그인 시도 - URL: $_baseUrl/users/login');
      final response = await _dio.post(
        '$_baseUrl/users/login',
        data: {
          'phoneNumber': phone,
          'password': password,
        },
      );
      return response.data['firebaseUid'];
    } catch (e) {
      if (e is DioException) {
        print('로그인 실패 - 상태 코드: ${e.response?.statusCode}');
        print('에러 응답: ${e.response?.data}');
      }
      print('로그인 실패: $e');
      throw e;
    }
  }
} 