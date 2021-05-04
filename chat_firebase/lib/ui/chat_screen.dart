import 'dart:io';

import 'package:chat_firebase/ui/chat_message.dart';
import 'package:chat_firebase/ui/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
bool isLoading = false;
class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;

  Future<FirebaseUser> GetUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void SendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await GetUser();
    if (user == null) {
      final snack = SnackBar(
          content: Text("Não foi possível fazer o login. Tente novamente!"),
          duration: Duration(seconds: 5));
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time":Timestamp.now()
    };
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString()
          ).putFile(imgFile);
      setState(() {
        isLoading = true;
      });
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
      setState(() {
        isLoading = false;
      });
    }
    if (text != null) data['text'] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'Chat App'),
        elevation: 0,
        centerTitle: true,
        actions: [
          _currentUser != null ? IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){
            FirebaseAuth.instance.signOut();
            googleSignIn.signOut();
            final snack = SnackBar(
                content: Text("Você saiu com sucesso!"),
                duration: Duration(seconds: 5));
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snack);
          }) : Container()
        ],
      ),
      
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance.collection("messages").orderBy("time").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessage(
                              documents[index].data,
                              documents[index].data["uid"] == _currentUser?.uid);
                        });
                }
              },
            ),
          ),
          isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(SendMessage)
        ],
      ),
    );
  }
}
