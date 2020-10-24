import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/shared/aboutme_page.dart';
import 'package:devjoon/models/user.dart';
import 'package:flutter/material.dart';

class HandcraftersPage extends StatefulWidget {
  HandcraftersPage({Key key}) : super(key: key);

  @override
  _HandcraftersPageState createState() => _HandcraftersPageState();
}

class _HandcraftersPageState extends State<HandcraftersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handcrafters'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            List<User> users =
                snapshot.data.docs.map((e) => User.fromJson(e.data())).toList();
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users[index];
                  return ListTile(
                    title: Text('User id: ' + user.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutMePage(),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
