import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

ContactHelper helper = ContactHelper();
List<Contact> contacts = [];
enum OrderOptions {orderaz,orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BuildApp(context);
  }


  Widget BuildApp(BuildContext context) {
    Widget homePage = Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        actions: [
          PopupMenuButton<OrderOptions> (itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions> (child: Text("Ordernar de A-Z"),
            value: OrderOptions.orderaz,),
            const PopupMenuItem<OrderOptions> (child: Text("Ordernar de Z-A"),
            value: OrderOptions.orderza,)

        ],
          onSelected: _OrderList,
          )],
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _ShowContactPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _ContactCard(context, index);
        },
        padding: EdgeInsets.all(10.0),
      ),
    );

    return homePage;
  }

  Widget _ContactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.0),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _ShowOptions(context, index);
      },
    );
  }

  void _ShowOptions(BuildContext context, int index)
  {
    showModalBottomSheet(context: context, builder: (context)
    {
      return BottomSheet(onClosing: (){}, builder: (context)
      {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text("Ligar",style: TextStyle(color: Colors.white,fontSize: 20.0),),
                onPressed: ()
                {
                    launch("tel:${contacts[index].phone}");
                    Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text("Editar",style: TextStyle(color: Colors.white,fontSize: 20.0),),
                onPressed:(){
                  Navigator.pop(context);
                  _ShowContactPage(contact: contacts[index]);
              },

              ),
              ElevatedButton(
                child: Text("Excluir",style: TextStyle(color: Colors.white,fontSize: 20.0),),
                onPressed: ()
                {
                  Navigator.pop(context);
                  helper.DeleteContact(contacts[index].id);
                  setState(() {
                    contacts.removeAt(index);
                  });

                },
              )
            ],
          ),
        );
      });
    });
  }
  void _ShowContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null)
        await helper.UpdateContact(recContact);
      else
        await helper.SaveContact(recContact);

      _GetAllContacts();
    }
  }

  void _GetAllContacts() {
    helper.GetAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  @override
  void initState() {
    _GetAllContacts();
    super.initState();
  }

  void _OrderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
         return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b)
        {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {
    });
  }
}
