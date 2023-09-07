import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_app/models/stud_model.dart';
import 'package:flutter_firebase_app/utils/mysnackmsg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String dbRef = 'StudentRef';

  TextEditingController inputName = TextEditingController();
  TextEditingController rollNo = TextEditingController();
  TextEditingController subject = TextEditingController();

  bool loading = false;
  bool isUpdate = false;

  List<StudentModel> studentList = [];

  reset() {
    inputName.clear();
    rollNo.clear();
    subject.clear();
    setState(() {});
  }

  setUpdateStudent(StudentModel st) {
    setState(() {
      isUpdate = true;
      inputName.text = st.name ?? '';
      subject.text = st.subject ?? '';
      rollNo.text = st.rollno ?? '';
    });
  }

  getAllUsers() async {
    if (studentList.isNotEmpty) {
      studentList = [];
    }
    await db.collection(dbRef).get().then((value) {
      for (var e in value.docs) {
        print(e);
        studentList.add(StudentModel.fromFirestore(e));
      }

      setState(() {});
    });
  }

  updatStudent() async {
    if (rollNo.text.trim().isEmpty) {
      showMsg(context, 'Enter RollNo');
    } else if (inputName.text.trim().isEmpty) {
      showMsg(context, 'Enter Name');
    } else if (subject.text.trim().isEmpty) {
      showMsg(context, 'Enter Subject');
    } else {
      setState(() {
        loading = true;
      });

      try {
        StudentModel studentModel = StudentModel(
            name: inputName.text.trim(),
            subject: subject.text.trim(),
            rollno: rollNo.text.trim());
        await db
            .collection(dbRef)
            .doc(studentModel.rollno)
            .set(studentModel.toFirestore())
            .then((value) {
          setState(() {
            loading = false;
          });
          showMsg(context, 'Data Update !', isError: false);
          getAllUsers();
          isUpdate = false;
          reset();
        });
      } catch (e) {
        print(e);

        setState(() {
          loading = false;
        });
      }
    }
  }

  saveUser() async {
    if (rollNo.text.trim().isEmpty) {
      showMsg(context, 'Enter RollNo');
    } else if (inputName.text.trim().isEmpty) {
      showMsg(context, 'Enter Name');
    } else if (subject.text.trim().isEmpty) {
      showMsg(context, 'Enter Subject');
    } else {
      setState(() {
        loading = true;
      });

      try {
        StudentModel studentModel = StudentModel(
            name: inputName.text.trim(),
            subject: subject.text.trim(),
            rollno: rollNo.text.trim());
        await db
            .collection(dbRef)
            .doc(studentModel.rollno)
            .set(studentModel.toFirestore())
            .then((value) {
          setState(() {
            loading = false;
          });
          showMsg(context, 'Data Saved !', isError: false);
          getAllUsers();
          reset();
        });
      } catch (e) {
        print(e);

        setState(() {
          loading = false;
        });
      }
    }
  }

  onDelete(StudentModel st) async {
    db.collection(dbRef).doc(st.rollno).delete().then((value) {
      showMsg(context, 'Student Deleted', isError: false);
      setState(() {
        getAllUsers();
      });
    });
  }

  userInput(String title, String hint, TextInputType type,
      TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(hintText: hint, labelText: title),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                StudentModel st = studentList[index];
                return InkWell(
                  onTap: () {
                    setUpdateStudent(st);
                  },
                  child: Card(
                    child: ListTile(
                      leading: Text(st.rollno.toString()),
                      title: Text(st.name.toString()),
                      subtitle: Text(st.subject.toString()),
                      trailing: IconButton(
                          onPressed: () {
                            onDelete(st);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          )),
                    ),
                  ),
                );
              },
            ),
          ),
          userInput('Roll No', 'Enter Roll No', TextInputType.number, rollNo,
              readOnly: isUpdate),
          userInput('Name', 'Enter Name', TextInputType.text, inputName),
          userInput(
              'Subject', 'Enter Subject Name', TextInputType.text, subject),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loading
                  ? const SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        isUpdate ? updatStudent() : saveUser();
                      },
                      child: isUpdate
                          ? const Text('Update Data')
                          : const Text('Save Data')),
              isUpdate
                  ? IconButton(
                      onPressed: () {
                        isUpdate = false;
                        reset();
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ],
      ),
    );
  }
}
