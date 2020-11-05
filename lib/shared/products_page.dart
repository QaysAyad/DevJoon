import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjoon/designers/add_product_page.dart';
import 'package:devjoon/models/product.dart';
import 'package:devjoon/models/user.dart';
import 'package:devjoon/shared/product_page.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key key, this.isDesigner = false, this.user})
      : super(key: key);
  final bool isDesigner;
  final User user;

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
              if (isDesigner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Code: " + user.id),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(
                        'Add Product',
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductPage(
                            user: user,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .collection('products')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return CircularProgressIndicator();
                        List<Product> products = snapshot.data.docs
                            .map((e) => Product.fromJson(e.data()))
                            .toList();
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: ListView.separated(
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              Product product = products[index];
                              return ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      user: user,
                                      product: product,
                                    ),
                                  ),
                                ),
                                title: Text(product.name),
                                subtitle: Text('Steps: ' +
                                    product.steps.length.toString()),
                              );
                            },
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
