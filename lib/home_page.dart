import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  List streamdataKeys = [];
  TextEditingController classCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    classCtr.dispose();
    super.dispose();
  }
  void deleteData(String key) async {
    await ref.child(key).remove();
  }

  void createData(String key) async {
    await ref.update({key: 1});
  }

  void updateData(String keyIndex, int dataIndex) async {
    if (dataIndex == 0) {
      await ref.update({keyIndex: 1});
    } else {
      await ref.update({keyIndex: 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akıllı Kilit"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    Map dataStream = (snapshot.data!).snapshot.value as Map;
                    streamdataKeys = dataStream.keys.toList();
                    var streamData = dataStream.values.toList();
                    print('------$streamdataKeys $streamData');
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: streamdataKeys.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            color: Colors.grey.shade200,
                            child: ListTile(
                              textColor: streamData[index] == 0
                                  ? Colors.white
                                  : Colors.green,
                              tileColor: streamData[index] == 0
                                  ? Colors.green.shade400
                                  : null,
                              onTap: () {
                                updateData(
                                    streamdataKeys[index], streamData[index]);
                                //print(streamdataKeys[index]);
                              },
                              title: Text('Cihaz : ${streamdataKeys[index]}'),
                              trailing: streamData[index] == 0
                                  ? const Icon(Icons.lock, color: Colors.red)
                                  : Icon(Icons.lock_open,
                                      color: Colors.green.shade300),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Alert(
              context: context,
              title: "CİHAZ KODU",
              content: Column(
                children: <Widget>[
                  TextField(
                    controller: classCtr,
                    decoration: InputDecoration(
                      icon: Icon(Icons.add_to_photos_sharp),
                      labelText: 'Bir Cihaz Numarası Yazın',
                    ),
                  ),
                  // TextField(
                  //   obscureText: true,
                  //   decoration: InputDecoration(
                  //     icon: Icon(Icons.lock),
                  //     labelText: 'Password',
                  //   ),
                  // ),
                ],
              ),
              buttons: [
                DialogButton(
                  onPressed: () {
                    createData(classCtr.text);
                    classCtr.text = '';
                    Navigator.pop(context);
                  },
                  child: Text(
                    "EKLE",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                DialogButton(
                  onPressed: () {
                    deleteData(classCtr.text);
                    classCtr.text = '';
                    Navigator.pop(context);
                  },
                  child: Text(
                    "SİL",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
