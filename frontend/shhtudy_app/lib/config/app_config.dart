class AppConfig {
  // 실제 기기에서 테스트할 때는 서버의 실제 IP 주소로 변경
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080', // Android 에뮬레이터 기본값
  );
  
  // Firebase 설정
  static const String firebaseApiKey = 'AIzaSyBNnE7H-DCakKhisDGIU1xtp9TDx6uzaQ8';
  static const String firebaseAppId = '1:712677754253:android:eb5930be254b1ef75969c4';
  static const String firebaseProjectId = 'shhtudy-44b72';
} 

/*Platform  Firebase App Id
web       1:712677754253:web:7a665008eff30cbe5969c4
android   1:712677754253:android:eb5930be254b1ef75969c4
ios       1:712677754253:ios:3d3d5d811f7a50335969c4
macos     1:712677754253:ios:3d3d5d811f7a50335969c4
windows   1:712677754253:web:7a665008eff30cbe5969c4*/