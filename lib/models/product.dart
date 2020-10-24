import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String name;
  List<ProductStep> steps;
  Timestamp createdAt;
  Product({this.name, this.steps, this.createdAt});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        name: json['name'],
        steps: (json['steps'] as List)
            ?.map((e) => e == null ? null : ProductStep.fromJson(e))
            ?.toList(),
        createdAt: json['createdAt']);
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>()
    ..addAll({
      'name': this.name,
      'steps': steps?.map((e) => e?.toJson())?.toList(),
      'createdAt': FieldValue.serverTimestamp()
    });
}

class ProductStep {
  String text;
  String imageUrl;
  File imageFile;
  ProductStep({this.text, this.imageUrl, this.imageFile});
  factory ProductStep.fromJson(Map<String, dynamic> json) =>
      ProductStep(text: json['text'], imageUrl: json['imageUrl']);

  Map<String, dynamic> toJson() => Map<String, dynamic>()
    ..addAll({'text': this.text, 'imageUrl': this.imageUrl});
}
