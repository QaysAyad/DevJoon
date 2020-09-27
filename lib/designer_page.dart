import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/data.dart';
import 'package:devjoon/handcrafters_page.dart';
import 'package:devjoon/questions_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImageCoding;

class DesignerPage extends StatefulWidget {
  DesignerPage({Key key}) : super(key: key);

  @override
  _DesignerPageState createState() => _DesignerPageState();
}

class _DesignerPageState extends State<DesignerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevJoon'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(kUserId)
                          .collection('images')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return CircularProgressIndicator();
                        List<String> images = snapshot.data.docs
                            .map<String>((e) => e.data()['imageUrl'] as String)
                            .toList();
                        print(images);
                        return Wrap(
                            children: images
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                          imageUrl: e,
                                        ),
                                      ),
                                    ))
                                .toList());
                      }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'Questions',
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionsPage(),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) => MaterialButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(
                        'Handcrafters',
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HandcraftersPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> _uploadImage(File image) async {
  if (image != null) {
    final StorageReference _storage = FirebaseStorage.instance.ref();
    StorageUploadTask _uploadTask;
    String _milliSeconds = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath =
        'users/$kUserId/images/${kUserId + '_' + _milliSeconds}.png';
    ImageCoding.Image _image =
        ImageCoding.decodeImage(await image.readAsBytes());
    _uploadTask =
        _storage.child(filePath).putData(ImageCoding.encodePng(_image));
    await _uploadTask.onComplete;
    String downloadUrl = await _uploadTask.lastSnapshot.ref.getDownloadURL();
    print(downloadUrl);
    return downloadUrl;
  }
}
