import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';

class PackageScreenMembers extends StatelessWidget {
  final String memberId;

  PackageScreenMembers({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Available Packages'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('packages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    int fee = (data['fee'] as num).toInt(); // Convert to int
                    int duration =
                        (data['duration'] as num).toInt(); // Convert to int
                    return PackageCard(
                      imageUrl: data['image_url'] ?? '',
                      name: data['name'] ?? 'No Name',
                      fee: fee,
                      duration: duration,
                      description: data['description'] ?? 'No Description',
                      docId: doc.id,
                      memberId: memberId,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PackageCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final int fee;
  final int duration;
  final String description;
  final String docId;
  final String memberId;

  PackageCard({
    required this.imageUrl,
    required this.name,
    required this.fee,
    required this.duration,
    required this.description,
    required this.docId,
    required this.memberId,
  });

  @override
  _PackageCardState createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _status;
  String? _selectedTrainer;
  String? _selectedTrainerName;
  List<DropdownMenuItem<String>> _trainerItems = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetails();
    _fetchTrainers();
  }

  Future<void> _fetchSubscriptionDetails() async {
    String userId = widget.memberId;

    QuerySnapshot subscriptionSnapshot = await FirebaseFirestore.instance
        .collection('buyPackages')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (subscriptionSnapshot.docs.isNotEmpty) {
      var doc = subscriptionSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _startDate = (doc['startDate'] as Timestamp).toDate();
        _endDate = (doc['endDate'] as Timestamp).toDate();
        _status = doc['status'];
        _selectedTrainer = doc['trainerId'];
        _selectedTrainerName = doc['trainerName'];
      });
    }
  }

  Future<void> _fetchTrainers() async {
    QuerySnapshot trainerSnapshot =
        await FirebaseFirestore.instance.collection('trainers').get();

    setState(() {
      _trainerItems = trainerSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(data['name']),
        );
      }).toList();
    });
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String userId = widget.memberId;

    // Kiểm tra gói hiện tại của người dùng
    QuerySnapshot existingSubscriptionSnapshot = await FirebaseFirestore
        .instance
        .collection('buyPackages')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingSubscriptionSnapshot.docs.isNotEmpty) {
      var existingSubscription = existingSubscriptionSnapshot.docs.first;
      var existingData = existingSubscription.data() as Map<String, dynamic>;
      DateTime endDate = (existingData['endDate'] as Timestamp).toDate();

      if (endDate.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only subscribe to one package at a time.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        // Move the expired package to historyPackages
        await FirebaseFirestore.instance.collection('historyPackages').add({
          'userId': userId,
          'userName': existingData['userName'],
          'packageId': existingData['packageId'],
          'name': existingData['name'],
          'fee': existingData['fee'],
          'duration': existingData['duration'],
          'description': existingData['description'],
          'trainerId': existingData['trainerId'],
          'trainerName': existingData['trainerName'],
          'status': 'expired',
          'startDate': existingData['startDate'],
          'endDate': existingData['endDate'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Delete the expired package from buyPackages
        await existingSubscription.reference.delete();
      }
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a start date.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_selectedTrainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a trainer.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? userName;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        userName = userSnapshot.get('name');
      } else {
        userName = 'Unknown User';
      }
    } catch (e) {
      userName = 'Unknown User';
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Subscription'),
        content: Text(
            'Are you sure you want to subscribe to "${widget.name}" for ${widget.duration} months starting from ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'} at \$${widget.fee} with trainer "${_selectedTrainerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('buyPackages').add({
          'userId': userId,
          'userName': userName,
          'packageId': widget.docId,
          'name': widget.name,
          'fee': widget.fee,
          'duration': widget.duration,
          'description': widget.description,
          'trainerId': _selectedTrainer,
          'trainerName': _selectedTrainerName,
          'status': 'wait for confirmation',
          'startDate': _startDate,
          'endDate': _endDate,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to "${widget.name}"!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate =
        DateTime.now().add(Duration(days: 365)); // One year from now

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
        _endDate = DateTime(pickedDate.year, pickedDate.month + widget.duration,
            pickedDate.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('buyPackages')
          .where('userId', isEqualTo: widget.memberId)
          .where('packageId', isEqualTo: widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isSubscribed = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        bool isExpired = _endDate != null && _endDate!.isBefore(DateTime.now());
        return Card(
          margin: EdgeInsets.all(12.0),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[600],
                            size: 50,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fee: \$${widget.fee}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Trainer Name: ${_selectedTrainerName ?? 'No Trainer Selected'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Duration Package: ${widget.duration} months',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Description: ${widget.description}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_status != null) ...[
                      Text(
                        'Status: ${_status}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _status == 'wait for confirmation'
                              ? Colors.orange
                              : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    if (isSubscribed) ...[
                      Text(
                        'Start Date: ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      if (isExpired)
                        Text(
                          'This package has expired.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ] else ...[
                      GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _startDate == null
                                  ? 'Select Start Date'
                                  : 'Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_startDate != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTrainer,
                        hint: Text('Select Trainer'),
                        items: _trainerItems,
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              _selectedTrainer = value;
                            });

                            // Fetch the trainer's name directly from Firestore
                            DocumentSnapshot trainerSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('trainers')
                                    .doc(value)
                                    .get();
                            if (trainerSnapshot.exists) {
                              setState(() {
                                _selectedTrainerName =
                                    trainerSnapshot.get('name');
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      if (_selectedTrainerName != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Selected Trainer: $_selectedTrainerName',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _isLoading || (isSubscribed && !isExpired)
                        ? null
                        : () => _handleSubscribe(context),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text(
                            isSubscribed && !isExpired
                                ? 'Subscribed'
                                : 'Subscribe',
                          ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isSubscribed && !isExpired
                          ? Colors.grey
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ),
              if (isSubscribed && !isExpired)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
