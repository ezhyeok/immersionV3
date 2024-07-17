class UserData {
  // 싱글톤 인스턴스를 위한 정적 필드
  static final UserData _instance = UserData._internal();

  // 싱글톤 인스턴스에 접근할 수 있는 정적 메서드
  static UserData get instance => _instance;

  // 내부 생성자
  UserData._internal();

  // 저장할 데이터 필드
  String? uniqueId;
  String? nickName;
  String? profileImageUrl;
  String? kakaoId;


  // 데이터 설정 메서드
  void setUserData(String id, String name, String url) {
    uniqueId = id;
    nickName = name;
    profileImageUrl = url;
  }
  void setDefaultUrl(String url) {
    profileImageUrl = url;
  }
  void setKakaoId(String id) {
    kakaoId = id;
  }


  // 데이터 가져오기 메서드
  Map<String, String?> getUserData() {
    return {
      'uniqueId': uniqueId,
      'nickName': nickName,
      'profileImageUrl': profileImageUrl,
    };
  }
}
