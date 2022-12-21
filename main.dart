import 'dart:developer';
import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_network/image_network.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'firebase_options.dart';
import 'package:getwidget/getwidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dog Swag Demo',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _postStream =
      FirebaseFirestore.instance.collection('posts').snapshots();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar:AppBar(title:Text('DogSwag')),
      backgroundColor: Color.fromARGB(31, 17, 16, 16),
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 150,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.book),
                      title: Text('Post a story'),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: ((context) => PostBox(
                                  size: size,
                                )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.face),
                      title: Text('Post a poem'),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: ((context) => PostBox(
                                  size: size,
                                )));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.post_add),
                      title: Text('Post a meme'),
                      onTap: () {Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: ((context) => PostBox(
                                  size: size,
                                  
                        
                        )));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _postStream,
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading"));
            }
            return snapshot.data!.size == 0
                ? const Center(
                    child: Text('NO data found'),
                  )
                : ListView.separated(
                    itemBuilder: ((BuildContext context, index) => Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
  decoration: BoxDecoration(
    
    border: Border.all(color: 
       Color(0xff2c3e50),
        width: 2.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.all(Radius.circular(30))
  ),
  

                              child:ImageNetwork(
                                    debugPrint: true,
                                    curve: Curves.easeIn,
                              
                                    onTap: () {
                                      String docId =
                                          snapshot.data!.docs[index].id;
                                      List<dynamic> comments = (snapshot
                                          .data!.docs[index]
                                          .get('comments'));
                                      String imgUrl =
                                          snapshot.data!.docs[index].get('img');
                                      showDialog(
                                          context: context,
                                          builder: ((context) =>
                                              DescriptionPage(
                                                  docId: docId,
                                                  size: size,
                                                  imgUrl: imgUrl,
                                                  comments: comments)));
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    image:
                                        snapshot.data!.docs[index].get('img'),
                                    height: size.height * 0.4,
                                    width: size.width * 0.4),

                                // ListView.builder(
                                //     itemBuilder: snapshot.data!.docs[index])
                             ) ],
                            ),
                          ],
                        )),
                    separatorBuilder: ((context, index) => Divider(
                          endIndent: size.width * 0.25,
                          indent: size.width * 1,
                        )),
                    itemCount: snapshot.data!.size);
          })),
    );
  }
}

class DescriptionPage extends StatelessWidget {
  const DescriptionPage(
      {super.key,
      required this.size,
      required this.imgUrl,
      required this.comments,
      required this.docId});

  final Size size;
  final String imgUrl;
  final String docId;
  final List<dynamic> comments;
  @override
  Widget build(BuildContext context) {
    String comment = '';
    TextEditingController commentController = TextEditingController();
    return AlertDialog(
      content: Column(
        children: [
   ImageNetwork(
              image: imgUrl,
              width: size.width * 0.5,
              height: size.height * 0.5),
          
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('Be The First One To Give This A Story'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                height: size.height * 0.2,
                width: size.width * 0.5,
                child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                    // shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: ((context, index) => Text(comments[index]))),
              ),
            ),
          if (comments.length < 10)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 10,
                  child: TextFormField(
                    controller: commentController,
                    onChanged: (value) => comment = value,
                    maxLength: 10,
                    autocorrect: true,
                    decoration: const InputDecoration(
                        labelText: 'Add Your Story',
                        border: OutlineInputBorder()),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () {
                          List<dynamic> newComments = comments;
                          newComments.add(comment);
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(docId)
                              .update({'img': imgUrl, 'comments': newComments});
                          commentController.clear();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.send)))
              ],
            )
        ],
      ),
    
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Go Back"))
      ],
    );
  }
}

class PostBox extends StatefulWidget {
  const PostBox({required this.size, super.key});
  final Size size;
  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  CollectionReference post = FirebaseFirestore.instance.collection('posts');
  String imgUrl = '';
  bool fetchedImg = false;
  bool posted = false;
  @override
  Widget build(BuildContext context) {
    TextEditingController url = TextEditingController();
    return Scaffold(
      body: AlertDialog(
        title: const Text('Create new post'),
        content: posted
            ? const Icon(
                Icons.check,
                size: 300,
                color: Colors.green,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: url,
                    onChanged: (value) => imgUrl = value,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter img url',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (!fetchedImg)
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            fetchedImg = !fetchedImg;
                            log(url.text);
                          });
                        },
                        child: fetchedImg
                            ? Container()
                            : const Text('Upload'))
                  else
                  ImageNetwork(
                        fitWeb: BoxFitWeb.fill,
                        image: imgUrl,
                        height: widget.size.height * 0.5,
                        width: widget.size.width * 0.5)
                ],
              ),
        actions: [
          if (fetchedImg)
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    fetchedImg = false;
                  });
                },
                child: const Text('remove image')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                post
                    .add({'count': 0, 'img': imgUrl, 'comments': []})
                    .then((value) => log("Post Added"))
                    .catchError((error) => log("Failed to add post: $error"));
                setState(() {
                  posted = true;
                });
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: ((context) => const AlertDialog(
                          content:
                              Icon(Icons.check, size: 300, color: Colors.green),
                        )));
              },
              child: const Text('Post')),
        ],
      ),
    );
  }
}

//  CollectionReference txt = FirebaseFirestore.instance.collection('test');
//   Future<void> addTxt() async {
//     var doc = await txt.where('txt', isEqualTo: 'hello world').get();
//     debugPrint(doc.docs.first.id);
//     String docId = doc.docs.first.id;

//     return txt.doc(docId).update({'txt': "getting started"});
//   }

//   return Center(
//       child: TextButton(
//     onPressed: addTxt,
//     child: const Text('add test'),
//   ));
