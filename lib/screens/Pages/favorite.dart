import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Favorite extends StatelessWidget {
  const Favorite({super.key});

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
            title: Container(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Favorites',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Billabong',
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          
          SliverFillRemaining(
            child: StreamBuilder(
              
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                
                final favoriteDocs = snapshot.requireData.docs;

                
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    var favoriteDoc = favoriteDocs[index];

                    
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(favoriteDoc['postId'])
                          .get(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> postSnapshot) {
                        
                        if (postSnapshot.hasError) {
                          return Center(child: Text('Error: ${postSnapshot.error}'));
                        }
                        
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        
                        if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                          return Container();
                        }

                        
                        var post = postSnapshot.data!;

                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(post['postUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
