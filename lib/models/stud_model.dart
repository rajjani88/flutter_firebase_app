import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? name;
  final String? subject;
  final String? rollno;

  StudentModel({this.name, this.subject, this.rollno});

  factory StudentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    //SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return StudentModel(
      name: data?['name'],
      subject: data?['subject'],
      rollno: data?['rollno'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (subject != null) "subject": subject,
      if (rollno != null) "rollno": rollno,
    };
  }
}
