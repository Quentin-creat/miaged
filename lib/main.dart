import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miaged Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  //create fail method :
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

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  MainScreen(this.user);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Ajouter les pages à la liste _pages avec le paramètre user
    _pages.addAll([
      ActivitiesPage(widget.user),
      CartPage(widget.user),
      ProfilePage(widget.user),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class ActivitiesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ActivitiesPage(this.user, {Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final List<Map<String, dynamic>> activities = [];
  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  void loadActivities() {
    db.collection("activites").get().then((value) {
      setState(() {
        activities.addAll(value.docs.map((doc) => doc.data()).toList());
      });
    });
    print(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des activités'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ActivityDetailPage(activity, widget.user, context),
                  ),
                );
              },
              leading: activity['img'] != null
                  ? Image.network(
                      activity['img'],
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    )
                  : SizedBox
                      .shrink(), // Utiliser SizedBox.shrink() pour un widget invisible
              title: activity['title'] != null
                  ? Text(
                      activity['title'],
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : SizedBox.shrink(),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  activity['location'] != null
                      ? Text(
                          'Lieu: ${activity['location']}',
                          style: TextStyle(fontSize: 16.0),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 4.0),
                  activity['price'] != null
                      ? Text(
                          'Prix: ${activity['price'].toString()} €',
                          style: TextStyle(fontSize: 16.0),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> activityDetails;
  final Map<String, dynamic> user;
  final BuildContext context;

  ActivityDetailPage(this.activityDetails, this.user, this.context);

  Future<void> addToCart() async {
    try {
      // Ajoutez l'activité au panier avec un identifiant unique
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
      // Gérez les erreurs éventuelles
      print('Erreur lors de l\'ajout de l\'activité au panier : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'activité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 20.0),
              child: Image.network(
                activityDetails['img'],
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Titre : ${activityDetails['title']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Catégorie : ${activityDetails['category']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Nombre de participants minimum : ${activityDetails['minPart']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Lieu : ${activityDetails['location']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Prix : ${activityDetails['price']} €',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: addToCart,
              child: Text('Ajouter au panier'),
            ),
          ],
        ),
      ),
    );
  }
}

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
        title: Text('Panier'),
      ),
      body: FutureBuilder<int>(
        future: _totalPriceFuture,
        builder: (context, totalPriceSnapshot) {
          if (totalPriceSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var totalPrice = totalPriceSnapshot.data ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total du panier : $totalPrice €',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      return Center(child: CircularProgressIndicator());
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
                              return Center(child: CircularProgressIndicator());
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
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16.0),
                                      leading: activityData['img'] != null
                                          ? Image.network(
                                              activityData['img'],
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                            )
                                          : SizedBox.shrink(),
                                      title: activityData['title'] != null
                                          ? Text(
                                              activityData['title'],
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8.0),
                                          activityData['location'] != null
                                              ? Text(
                                                  'Lieu: ${activityData['location']}',
                                                  style:
                                                      TextStyle(fontSize: 16.0),
                                                )
                                              : SizedBox.shrink(),
                                          SizedBox(height: 4.0),
                                          activityData['price'] != null
                                              ? Text(
                                                  'Prix: ${activityData['price'].toString()} €',
                                                  style:
                                                      TextStyle(fontSize: 16.0),
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
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

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _passwordController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.user['address']);
    _cityController = TextEditingController(text: widget.user['city']);
    _postalCodeController =
        TextEditingController(text: widget.user['postal_code']);
    _passwordController = TextEditingController(text: widget.user['password']);
    _birthdayController = TextEditingController(text: widget.user['birthday']);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: widget.user['id'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({
          'address': _addressController.text,
          'city': _cityController.text,
          'postal_code': _postalCodeController.text,
          'password': _passwordController.text,
          'birthday': _birthdayController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur modifié avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              readOnly: true,
              initialValue: widget.user['username'],
              decoration: InputDecoration(labelText: 'Login'),
            ),
            TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            TextFormField(
              controller: _birthdayController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: 'Anniversaire',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextFormField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'Code postal',
              ),
            ),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Ville'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Valider'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur déconnecté avec succès'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Text('Déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
