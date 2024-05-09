// It is a simple model or object of storing our data.
// ignore_for_file: unused_local_variable

class ChatUser {
  ChatUser({
    required this.image,
    required this.lastSeen,
    required this.createdAt,
    required this.is_Online,
    required this.id,
    required this.pushToken,
    required this.email,
    required this.About,
    required this.Name,
  });
  late String image;
  late String lastSeen;
  late String createdAt;
  late bool is_Online;
  late String id;
  late String pushToken;
  late String email;
  late String About;
  late String Name;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    lastSeen = json['last_seen'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    About = json['About'] ?? '';
    Name = json['Name'] ?? '';
    is_Online = json['is_Online'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['last_seen'] = lastSeen;
    data['created_at'] = createdAt;
    data['is_Online'] = is_Online;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['About'] = About;
    data['Name'] = Name;
    return data;
  }
}
