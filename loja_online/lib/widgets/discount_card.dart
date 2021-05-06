import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loja_online/models/cart_model.dart';
import 'package:loja_online/utils/to_upper_case.dart';

class DiscountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(
          "Cupom de Desconto",
          textAlign: TextAlign.start,
          style:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        leading: Icon(Icons.card_giftcard),
        trailing: Icon(Icons.add),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              inputFormatters: [
                UpperCaseTextFormatter()
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Insira seu Cupom"),
              initialValue: CartModel.of(context).couponCode ?? "",
              onFieldSubmitted: (text)
              {
                Firestore.instance.collection("coupons").document(text).get().then((docSnap)
                {
                    if(docSnap.data != null)
                      {
                        CartModel.of(context).setCoupon(text, docSnap.data["percent"]);
                        final snack = SnackBar(
                            content: Text("Desconto de ${docSnap.data["percent"]}% aplicado!"),
                            backgroundColor: Theme.of(context).primaryColor,
                            duration: Duration(seconds: 2));
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      }
                    else
                      {
                        CartModel.of(context).setCoupon(null, 0);
                        final snack = SnackBar(
                            content: Text("Cupom não existente!"),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 2));
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      }
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
