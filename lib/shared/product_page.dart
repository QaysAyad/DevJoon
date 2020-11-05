import 'package:cached_network_image/cached_network_image.dart';
import 'package:devjoon/models/product.dart';
import 'package:devjoon/models/user.dart';
import 'package:devjoon/shared/half_transparent_camera_page.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key key, this.user, this.product}) : super(key: key);
  @required
  final User user;
  @required
  final Product product;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product _product;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _product = widget.product;
    _user = widget.user;
  }

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
              Text('Product Name: ' + _product.name),
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
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalfTransparentCameraPage(
                              step: step,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  (index + 1).toString() + '. ' + step.text,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Expanded(
                                child: step.imageFile != null
                                    ? Image.file(step.imageFile,
                                        fit: BoxFit.cover)
                                    : CachedNetworkImage(
                                        imageUrl: step.imageUrl,
                                        fit: BoxFit.cover),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
