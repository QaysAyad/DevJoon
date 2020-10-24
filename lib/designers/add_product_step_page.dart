import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/models/data.dart';
import 'package:devjoon/models/product.dart';
import 'package:devjoon/models/question.dart';
import 'package:devjoon/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as ImageCoding;
import 'package:image_picker/image_picker.dart';

class AddProductStepPage extends StatefulWidget {
  AddProductStepPage({Key key, this.step}) : super(key: key);
  final ProductStep step;
  @override
  _AddProductStepPageState createState() => _AddProductStepPageState();
}

class _AddProductStepPageState extends State<AddProductStepPage> {
  GlobalKey<FormState> _formKey;
  TextEditingController _question1;
  ProductStep _step;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _step = widget.step ?? ProductStep();
    _question1 = TextEditingController(text: _step.text ?? '');
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Step')),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  buildTextFormField(context, 'Step description', _question1),
                  SizedBox(height: 16),
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () async {
                        PickedFile image = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        _step.imageFile = File(image.path);
                        setState(() {});
                      },
                      child: SizedBox(
                        height: 300,
                        child: _step.imageFile == null && _step.imageUrl == null
                            ? Card(
                                color: Theme.of(context).primaryColorLight,
                                child: Center(
                                  child: Text(
                                    "Select Image",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              )
                            : _step.imageFile != null
                                ? Image.file(_step.imageFile)
                                : CachedNetworkImage(imageUrl: _step.imageUrl),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Builder(builder: (context) {
                    return MaterialButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          _step.text = _question1.value.text;
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                          try {
                            Navigator.pop(context, _step);
                          } catch (e) {
                            print(e);
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Something went wrong')));
                          }
                        }
                      },
                      child: Text('Save'),
                    );
                  }),
                ],
              ),
            )));
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
