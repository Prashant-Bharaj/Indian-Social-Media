import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indiansocialmedia/models/user.dart';
import 'package:indiansocialmedia/pages/search.dart';
import 'package:indiansocialmedia/widgets/header.dart';
import 'package:indiansocialmedia/widgets/post.dart';
import 'package:indiansocialmedia/widgets/progress.dart';

import 'home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress(context);
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}

/*
class _TimelineState extends State<Timeline> {

  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
//    createUser();
//  updateUser();
  deleteUser();
//    getUsers();
//  getUsersById();
  }

//  getUsers() async {
//     userRef.getDocuments()
//         .then((QuerySnapshot snapshot){
//    final QuerySnapshot snapshot = await userRef
//              .limit(2)
//            .orderBy('postsCount', descending: true)
//            .where('postsCount', isEqualTo: 3)
//            .where('username', isEqualTo: 'Yuvraj')

//        .getDocuments();
//    setState(() {
//      users = snapshot.documents;
//    });
//    snapshot.documents.forEach((DocumentSnapshot doc) {
//      print(doc.data);
////      print(doc.documentID);
////      print(doc.exists);
////      print(doc.reference);
//    });
////     });
//  }

//  getUsersById() async {
//    final String id = 'nupgGdM4uSOpb1lvB8rm';
//    final doc = await userRef.document(id).get();
//    print(doc.data);
//        .then((DocumentSnapshot doc){
//      print(doc.data);
//    });
//  }

  createUser(){
    userRef.document('alpha4').setData({
      'username': 'Rahul',
      'postsCount': 10,
      'isAdmin': false,
    });
  }
/*  updateUser(){
    userRef.document('asdefdef').updateData({
      'username': 'Jim Qwick',
      'postsCount': 100,
      'isAdmin': false,
    });
  }*/
  updateUser() async{
    final doc = await userRef.document('alppha4').get();
    if(doc.exists){
    doc.reference.updateData({
    'username': 'Jim Qwick',
    'postsCount': 100,
    'isAdmin': false,
    });
    }
  }
//  deleteUser(){
//    userRef.document('asdefdef').delete();
//  }
  deleteUser() async{
    final doc = await userRef.document('alppha2').get();
    if(doc.exists){
      doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Container(
//        child: ListView(
//          children: users.map((users) => Text(users['username'])).toList(),
//        ),
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: userRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress(context);
              }
              final List<Text> children = snapshot.data.documents
//                  .map((doc) => Text('${doc['postsCount'].toString()}'))
                  .map((doc) => Text(doc['username']))
                  .toList();
              return ListView(
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }
}
*/
