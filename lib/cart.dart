// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const CartPage(this.user, {Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<int> _totalPriceFuture;

  @override
  void initState() {
    super.initState();
    _totalPriceFuture = calculateTotalPrice();
  }

  Future<int> calculateTotalPrice() async {
    int totalPrice = 0;
    final cartItemsSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('user_id', isEqualTo: widget.user['id'])
        .get();

    for (var cartItem in cartItemsSnapshot.docs) {
      final activitySnapshot = await FirebaseFirestore.instance
          .collection('activites')
          .where('id', isEqualTo: cartItem['activity_id'])
          .get();
      if (activitySnapshot.docs.isNotEmpty) {
        for (var activityDoc in activitySnapshot.docs) {
          totalPrice += activityDoc.data()['price'] as int;
        }
      }
    }

    return totalPrice;
  }

  Future<int> removeFromCart(String activityId) async {
    final cartQuerySnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('user_id', isEqualTo: widget.user['id'])
        .where('activity_id', isEqualTo: activityId)
        .get();

    for (var cartItem in cartQuerySnapshot.docs) {
      await cartItem.reference.delete();
    }

    setState(() {
      _totalPriceFuture = calculateTotalPrice();
    });

    return _totalPriceFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: FutureBuilder<int>(
        future: _totalPriceFuture,
        builder: (context, totalPriceSnapshot) {
          if (totalPriceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var totalPrice = totalPriceSnapshot.data ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total du panier : $totalPrice €',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cart')
                      .where('user_id', isEqualTo: widget.user['id'])
                      .snapshots(),
                  builder: (context, cartSnapshot) {
                    if (cartSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cartDocs = cartSnapshot.data?.docs ?? [];

                    return ListView.builder(
                      itemCount: cartDocs.length,
                      itemBuilder: (context, cartIndex) {
                        final cartDoc = cartDocs[cartIndex];
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('activites')
                              .where('id', isEqualTo: cartDoc['activity_id'])
                              .get(),
                          builder: (context, activitiesSnapshot) {
                            if (activitiesSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final activitiesDocs =
                                activitiesSnapshot.data?.docs ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...activitiesDocs.map((activityDoc) {
                                  final activityData = activityDoc.data()
                                      as Map<String, dynamic>;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16.0),
                                      leading: activityData['img'] != null
                                          ? Image.network(
                                              activityData['img'],
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                            )
                                          : const SizedBox.shrink(),
                                      title: activityData['title'] != null
                                          ? Text(
                                              activityData['title'],
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8.0),
                                          activityData['location'] != null
                                              ? Text(
                                                  'Lieu: ${activityData['location']}',
                                                  style:
                                                      const TextStyle(fontSize: 16.0),
                                                )
                                              : const SizedBox.shrink(),
                                          const SizedBox(height: 4.0),
                                          activityData['price'] != null
                                              ? Text(
                                                  'Prix: ${activityData['price'].toString()} €',
                                                  style:
                                                      const TextStyle(fontSize: 16.0),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          removeFromCart(activityDoc['id']);
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}