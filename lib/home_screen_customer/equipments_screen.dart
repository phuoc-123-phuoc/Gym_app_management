import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screens_admin/add_equipments.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

class EquipmentsScreen extends StatefulWidget {
  @override
  _EquipmentsScreenState createState() => _EquipmentsScreenState();
}

class _EquipmentsScreenState extends State<EquipmentsScreen> {
  String searchQuery = '';
  final List<String> imgList = [
    'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg',
    'https://images.pexels.com/photos/3757958/pexels-photo-3757958.jpeg',
    'https://images.pexels.com/photos/1552249/pexels-photo-1552249.jpeg',
    'https://images.pexels.com/photos/4672712/pexels-photo-4672712.jpeg',
    'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Equipments'),
      body: SafeArea(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
              ),
              items: imgList
                  .map((item) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(item,
                              fit: BoxFit.cover, width: 1000),
                        ),
                      ))
                  .toList(),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(
                color: Palette.secondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Palette.primaryColor),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Search Equipment',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Palette.primaryColor,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('equipments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong',
                          style: TextStyle(color: Colors.red)),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // If we reach here, we have data
                  var equipments = snapshot.data!.docs.where((equipment) {
                    return equipment['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (equipments.isEmpty) {
                    return Center(
                      child: Text('No equipment found',
                          style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio:
                          0.6, // Width to height ratio of the grid items
                    ),
                    itemCount: equipments.length,
                    itemBuilder: (context, index) {
                      var equipment = equipments[index];
                      return InkWell(
                        onTap: () {
                          // Implement what happens on tap
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120.0,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.0),
                                  ),
                                  child: Image.network(
                                    equipment['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${equipment['name']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 13, 13, 13),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Category: ${equipment['category']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Status: ${equipment['status']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            dynamic conversationObject = {
              // 'appId': 'd735030dee920e962adc7a20f60b8d24',
              'appId': '12d6400690dd7702b971454c8d848f8a7',
            };
            dynamic result = await KommunicateFlutterPlugin.buildConversation(
              conversationObject,
            );
            print("Conversation builder success :" + result.toString());
          } on Exception catch (e) {
            print("Conversation build error occurred :" + e.toString());
          }
        },
        tooltip: 'Increment',
        child: ClipOval(
          child: Image.asset(
            'assets/images/Chat.jpg',
            fit: BoxFit.cover, // Đảm bảo hình ảnh đầy đủ và không bị biến dạng
            width:
                50, // Điều chỉnh kích thước của hình ảnh theo nhu cầu của bạn
            height: 50,
          ),
        ),
      ),
    );
  }
}
