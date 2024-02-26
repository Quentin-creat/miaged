import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miaged/main.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  LoginPage({super.key});

  void fail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Connexion échouée, adresse email ou mot de passe incorrecte'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miaged'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(
                labelText: 'Login',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (username.text.isEmpty || password.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Un des champs est manquant'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                var db = FirebaseFirestore.instance;
                db
                    .collection("user")
                    .where("username", isEqualTo: username.text)
                    .limit(1)
                    .get()
                    .then((value) => {
                          if (value.docs.isNotEmpty)
                            {
                              if (value.docs.first.data()["password"] ==
                                  password.text)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Utilisateur connecté avec succès'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  ),
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen(
                                            value.docs.first.data())),
                                  )
                                }
                              else
                                {fail(context)}
                            }
                          else
                            {fail(context)}
                        });
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}