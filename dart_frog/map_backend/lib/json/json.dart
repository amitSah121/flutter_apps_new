
class User {
  User({this.username, this.password, this.notes});

  String? password;
  String? username;
  Notes? notes;


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['username'] as String,
        password: json['password'] as String,
        notes: json['notes'] != null
          ? Notes.fromJson(json['notes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username' : username,
      'password' : password,
      'note' : notes?.toJson(),
    };
  }
}

class Notes {
  Notes({this.note});

  Map<String, Note>? note;


  factory Notes.fromJson(Map<String, dynamic> json) {
    Map<String, Note> temp = {}; // Map<String, Note>

    json.forEach((key, value){
      temp[key] = Note.fromJson(value as Map<String, dynamic>);
    });

    return Notes(
        note: temp
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> temp = {}; // Map<String, Note>
    
    note?.forEach((key, value){
      temp[key] = value.toJson();
    });

    
    return {
      'note' : temp,
    };
  }
}

class Note {
  Note({this.index, this.type, this.content});

  List<dynamic>? index;
  String? type;
  String? content;


  factory Note.fromJson(Map<String, dynamic> json) {
    // print(json);
    return Note(
        index: json['index'] as List<dynamic>,
        type: json['type'] as String,
        content: json['content'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'type': type,
      'content': content
    };
  }
}
