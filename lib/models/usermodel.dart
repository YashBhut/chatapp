class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? pushToken;

  UserModel({this.uid, this.fullname, this.email, this.profilepic, this.pushToken});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    pushToken = map["pushToken"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "pushToken" : pushToken,
    };
  }
}