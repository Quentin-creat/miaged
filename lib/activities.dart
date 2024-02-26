// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miaged/activity_detail.dart';

class ActivitiesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ActivitiesPage(this.user, {Key? key}) : super(key: key);
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<String> _categories = [
    "Toutes",
    "visite",
    "plein air",
    "culture",
    "atelier"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des activités'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories
            .map((category) => _buildActivitiesList(category))
            .toList(),
      ),
    );
  }

  Widget _buildActivitiesList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: category == "Toutes"
          ? FirebaseFirestore.instance.collection("activites").snapshots()
          : FirebaseFirestore.instance
              .collection("activites")
              .where("category", isEqualTo: category)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final activities = snapshot.data!.docs;
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetailPage(
                      activity.data() as Map<String, dynamic>,
                      widget.user,
                      context,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: activity['img'] != null
                      ? Image.network(
                          activity['img'],
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                  title: activity['title'] != null
                      ? Text(
                          activity['title'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      activity['location'] != null
                          ? Text(
                              'Lieu: ${activity['location']}',
                              style: const TextStyle(fontSize: 16.0),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 4.0),
                      activity['price'] != null
                          ? Text(
                              'Prix: ${activity['price'].toString()} €',
                              style: const TextStyle(fontSize: 16.0),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}