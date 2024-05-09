// It Is Simple Model To Store Our Messages.
class Message {
  Message({
    required this.toID,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromID,
    required this.sent,
  });
  late final String toID;
  late final String msg;
  late final String read;
  late final String fromID;
  late final String sent;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    toID = json['toID'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromID = json['fromID'].toString();
    sent = json['sent'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toID'] = toID;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromID'] = fromID;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
