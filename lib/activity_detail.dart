import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> activityDetails;
  final Map<String, dynamic> user;
  final BuildContext context;

  const ActivityDetailPage(this.activityDetails, this.user, this.context, {super.key});

  Future<void> addToCart() async {
    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'user_id': user['id'],
        'activity_id': activityDetails['id'],
        'quantity': 1
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activité ajoutée au panier'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Erreur lors de l\'ajout de l\'activité au panier : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'activité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Image.network(
                activityDetails['img'],
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Titre : ${activityDetails['title']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Catégorie : ${activityDetails['category']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Nombre de participants minimum : ${activityDetails['minPart']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Lieu : ${activityDetails['location']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Prix : ${activityDetails['price']} €',
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: addToCart,
              child: const Text('Ajouter au panier'),
            ),
          ],
        ),
      ),
    );
  }
}

