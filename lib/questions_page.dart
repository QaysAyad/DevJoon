import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/question.dart';
import 'package:flutter/material.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({Key key}) : super(key: key);

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _answer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Questions'),
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('questions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator();
                List<Question> questions = snapshot.data.docs
                    .map((e) => Question.fromJson(e.data()))
                    .toList();
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      Question question = questions[index];
                      if (question.answer == null)
                        return Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(question.question)),
                              TextFormField(
                                  maxLines: null,
                                  controller: _answer,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).errorColor,
                                          width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).errorColor,
                                          width: 2),
                                    ),
                                  ),
                                  autovalidate: true,
                                  validator: (_value) => _value.isEmpty
                                      ? 'Please enter some text'
                                      : null),
                              MaterialButton(
                                  minWidth: double.infinity,
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  child: Text(
                                    'Answer',
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Processing Data')));
                                      try {
                                        question.answer = _answer.value.text;
                                        await snapshot
                                            .data.docs[index].reference
                                            .update(question.toJson());
                                      } catch (e) {
                                        print(e);
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Something went wrong')));
                                      }
                                    }
                                  }),
                            ],
                          ),
                        );
                      return ListTile(
                        title: Text(question.question),
                        subtitle: question.answer != null
                            ? Text(question.answer)
                            : null,
                      );
                    },
                  ),
                );
              }),
        ));
  }
}
