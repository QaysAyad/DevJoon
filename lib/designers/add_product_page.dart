import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/designers/add_product_step_page.dart';
import 'package:devjoon/models/product.dart';
import 'package:devjoon/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as ImageCoding;

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key key, this.user}) : super(key: key);
  final User user;

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  Product _product;
  GlobalKey<FormState> _formKey;
  TextEditingController _question1;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _product = Product(name: '', steps: <ProductStep>[]);
    _question1 = TextEditingController(text: _product.name);
    _formKey = GlobalKey<FormState>();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DevJoon'),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                buildTextFormField(context, 'Product Name', _question1),
                MaterialButton(
                  minWidth: double.infinity,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                    'Add Step',
                  ),
                  onPressed: () async {
                    final step = await Navigator.push<ProductStep>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductStepPage(),
                      ),
                    );
                    if (step != null) {
                      _product.steps.add(step);
                      setState(() {});
                    }
                  },
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _product.steps.length,
                    itemBuilder: (context, index) {
                      ProductStep step = _product.steps[index];
                      return Card(
                        child: SizedBox(
                          height: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (index + 1).toString() + '. ' + step.text,
                                style: TextStyle(fontSize: 20),
                              ),
                              Expanded(
                                child: Card(
                                  child: step.imageFile != null
                                      ? Image.file(step.imageFile,
                                          fit: BoxFit.cover)
                                      : CachedNetworkImage(
                                          imageUrl: step.imageUrl),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
                MaterialButton(
                    minWidth: double.infinity,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'Save Product',
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _product.name = _question1.value.text;
                        // Scaffold.of(context).showSnackBar(
                        //     SnackBar(content: Text('Processing Data')));
                        try {
                          final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                Future.microtask(() async {
                                  for (var step in _product.steps) {
                                    if (step.imageFile != null) {
                                      String imageUrl = await _uploadImage(
                                          step.imageFile, _user.id);
                                      step.imageUrl = imageUrl;
                                    }
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_user.id)
                                      .collection('products')
                                      .doc()
                                      .set(_product.toJson());
                                  Navigator.of(context).pop(true);
                                });
                                return Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 8),
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Loading...'),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              });
                          if (result == true) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          print(e);
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Something went wrong')));
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(
    BuildContext context,
    String labelText,
    TextEditingController _question1,
  ) {
    return TextFormField(
        maxLines: null,
        controller: _question1,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).errorColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).errorColor, width: 2),
          ),
          labelText: labelText,
        ),
        autovalidateMode: AutovalidateMode.always,
        validator: (_value) =>
            _value.isEmpty ? 'Please enter some text' : null);
  }
}

Future<String> _uploadImage(File image, String uid) async {
  if (image != null) {
    final StorageReference _storage = FirebaseStorage.instance.ref();
    StorageUploadTask _uploadTask;
    String _milliSeconds = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = 'users/$uid/images/${uid + '_' + _milliSeconds}.png';
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
