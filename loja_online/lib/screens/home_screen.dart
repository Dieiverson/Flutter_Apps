import 'package:flutter/material.dart';
import 'package:loja_online/main.dart';
import 'package:loja_online/tabs/home_tab.dart';
import 'package:loja_online/tabs/orders_tab.dart';
import 'package:loja_online/tabs/products_tab.dart';
import 'package:loja_online/widgets/cart_button.dart';
import 'package:loja_online/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          floatingActionButton: CartButton(),
          body: HomeTab(),
          drawer: CustomDrawer(pageController),
        ),
        Scaffold(
          floatingActionButton: CartButton(),
          appBar: AppBar(
            title: Text("Produtos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(pageController),
          body: ProductsTab(),
        ),
        Container(color: Colors.amber),
        Scaffold(
          appBar: AppBar(
            title: Text("Meus Pedidos"),
            centerTitle: true,
          ),
          body: OrdersTab(),
          drawer: CustomDrawer(pageController),
        )
      ],
    );
  }
}
