import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holbegram/utils/posts.dart';
import 'package:holbegram/screens/Pages/add_image.dart';
import 'package:holbegram/screens/Pages/messages_screen.dart';
import 'package:badges/badges.dart' as custom_badge;


class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  FeedState createState() => FeedState();
}


class FeedState extends State<Feed> {
  String? selectedUid;
  bool hasUnreadMessages = false;
  int unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    checkForUnreadMessages();
  }

  
  void checkForUnreadMessages() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        hasUnreadMessages = snapshot.docs.isNotEmpty;
        unreadMessageCount = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Text(
                  'Holbegram',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 1),
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddImage(),
                    ),
                  );
                },
              ),
              
              custom_badge.Badge(
                position: custom_badge.BadgePosition.topEnd(top: 0, end: 3),
                badgeContent: Text(
                  unreadMessageCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                showBadge: hasUnreadMessages,
                child: IconButton(
                  icon: Icon(
                    Icons.message_outlined,
                    color: hasUnreadMessages
                        ? const Color.fromARGB(255, 41, 165, 45)
                        : Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagesScreen(),
                      ),
                    ).then((_) => checkForUnreadMessages());
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FollowingProfiles(onProfileSelected: onProfileSelected),
          ),
          SliverFillRemaining(
            child: Posts(filterUid: selectedUid),
          ),
        ],
      ),
    );
  }

  
  void onProfileSelected(String uid) {
    setState(() {
      selectedUid = uid;
    });
  }
}


class FollowingProfiles extends StatelessWidget {
  final Function(String) onProfileSelected;
  const FollowingProfiles({super.key, required this.onProfileSelected});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return currentUser == null
        ? const SizedBox.shrink()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('following')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              
              final followingDocs = snapshot.data?.docs ?? [];

              
              return followingDocs.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 20.0, bottom: 2.0, left: 8.0),
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: followingDocs.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(followingDocs[index].id)
                                .get(),
                            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }
                              if (userSnapshot.hasError) {
                                return const SizedBox.shrink();
                              }

                              
                              var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                              if (userData == null) {
                                return const SizedBox.shrink();
                              }

                              return GestureDetector(
                                onTap: () => onProfileSelected(followingDocs[index].id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(userData['photoUrl']),
                                        radius: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        userData['username'],
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
            },
          );
  }
}
