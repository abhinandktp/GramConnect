import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class WasteComplaintApp extends StatelessWidget {
  final String phoneNumber;

  const WasteComplaintApp({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: Colors.blue,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat',
      ),
      home: ComplaintHomePage(phoneNumber: phoneNumber),
    );
  }
}

class ComplaintHomePage extends StatelessWidget {
  final String phoneNumber;

  ComplaintHomePage({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Waste Dumping Complaints',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: ComplaintTab(phoneNumber: phoneNumber),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.add_alert, color: Colors.white),
        label: Text('Report Issue', style: TextStyle(color: Colors.white)),
        onPressed: () => showComplaintDialog(context, phoneNumber),
      ),
    );
  }
}

void showComplaintDialog(BuildContext context, String phoneNumber) {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String location = '';
  File? _image;
  final picker = ImagePicker();

  Future<File?> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Report Waste Issue",
              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Issue Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title, color: Colors.blue),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onChanged: (value) => title = value,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, color: Colors.blue),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onChanged: (value) => description = value,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onChanged: (value) => location = value,
                  ),
                  SizedBox(height: 15),
                  Text("Add Photo Proof",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final image = await getImage();
                      setState(() => _image = image);
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _image == null
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.blue, size: 40),
                            SizedBox(height: 8),
                            Text('Tap to add photo', style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      )
                          : Stack(
                        children: [
                          Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.close, size: 18, color: Colors.red),
                                onPressed: () => setState(() => _image = null),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Photo helps authorities verify the issue',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('SUBMIT COMPLAINT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(ctx);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator(color: Colors.green)),
                  );

                  String? imageUrl;
                  if (_image != null) {
                    try {
                      final storageRef = FirebaseDatabase.instance
                          .ref()
                          .child('complaint_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

                      // await storageRef.putFile(_image!);
                      // imageUrl = await storageRef.getDownloadURL();
                    } catch (e) {
                      print('Error uploading image: $e');
                    }
                  }

                  try {
                    final databaseRef = FirebaseDatabase.instance.ref('complaints');
                    final newComplaintRef = databaseRef.push();

                    await newComplaintRef.set({
                      'title': title,
                      'description': description,
                      'location': location,
                      'contact': phoneNumber,
                      'imageUrl': imageUrl,
                      'likes': {},
                      'dislikes': {},
                      'likeCount': 0,  // Initialize like count
                      'dislikeCount': 0, // Initialize dislike count
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Complaint submitted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit complaint: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ),
  );
}

class ComplaintTab extends StatefulWidget {
  final String phoneNumber;

  ComplaintTab({required this.phoneNumber});

  @override
  _ComplaintTabState createState() => _ComplaintTabState();
}

class _ComplaintTabState extends State<ComplaintTab> {
  final DatabaseReference _complaintRef = FirebaseDatabase.instance.ref('complaints');
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  void _loadComplaints() {
    _complaintRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Complaint> loadedComplaints = [];
        data.forEach((key, value) {
          loadedComplaints.add(Complaint.fromMap(
            complaintId: key.toString(),
            map: Map<String, dynamic>.from(value as Map),
          ));
        });
        loadedComplaints.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        setState(() {
          _complaints = loadedComplaints;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _complaints = [];
          _isLoading = false;
          _hasError = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    });
  }

  void _updateVote(String complaintId, bool isLike) {
    final complaintRef = _complaintRef.child(complaintId);
    complaintRef.once().then((snapshot) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      final likes = Map<dynamic, dynamic>.from(data['likes'] ?? {});
      final dislikes = Map<dynamic, dynamic>.from(data['dislikes'] ?? {});
      int likeCount = data['likeCount'] ?? 0;
      int dislikeCount = data['dislikeCount'] ?? 0;

      if (isLike) {
        if (likes.containsKey(widget.phoneNumber)) {
          // User already liked - remove like
          likes.remove(widget.phoneNumber);
          likeCount--;
        } else {
          // Add like
          likes[widget.phoneNumber] = true;
          likeCount++;

          // Remove dislike if exists
          if (dislikes.containsKey(widget.phoneNumber)) {
            dislikes.remove(widget.phoneNumber);
            dislikeCount--;
          }
        }
      } else {
        if (dislikes.containsKey(widget.phoneNumber)) {
          // User already disliked - remove dislike
          dislikes.remove(widget.phoneNumber);
          dislikeCount--;
        } else {
          // Add dislike
          dislikes[widget.phoneNumber] = true;
          dislikeCount++;

          // Remove like if exists
          if (likes.containsKey(widget.phoneNumber)) {
            likes.remove(widget.phoneNumber);
            likeCount--;
          }
        }
      }

      // Update all values in a single transaction
      complaintRef.update({
        'likes': likes,
        'dislikes': dislikes,
        'likeCount': likeCount,
        'dislikeCount': dislikeCount,
      });
    });
  }

  void _deleteComplaint(String complaintId, String? imageUrl) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
            onPressed: () async {
              Navigator.pop(ctx);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator(color: Colors.green)),
              );

              try {
                // // Delete image from storage if exists
                // if (imageUrl != null && imageUrl.isNotEmpty) {
                //   final storageRef = FirebaseDatabase.instance.refFromURL(imageUrl);
                //   // await storageRef.delete();
                // }

                // Delete complaint from database
                await _complaintRef.child(complaintId).remove();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Complaint deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete complaint: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 20),
            Text('Loading complaints...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text('Failed to load complaints', style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
              onPressed: _loadComplaints,
            ),
          ],
        ),
      );
    }

    if (_complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: Colors.green[300]),
            SizedBox(height: 20),
            Text(
              'No complaints reported yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              'Be the first to report a waste issue!',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('REPORT AN ISSUE', style: TextStyle(color: Colors.white)),
              onPressed: () => showComplaintDialog(context, widget.phoneNumber),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: _complaints.length,
      itemBuilder: (ctx, index) => ComplaintItem(
        complaint: _complaints[index],
        onLike: () => _updateVote(_complaints[index].complaintId, true),
        onDislike: () => _updateVote(_complaints[index].complaintId, false),
        onDelete: () => _deleteComplaint(_complaints[index].complaintId, _complaints[index].imageUrl),
        currentUserPhone: widget.phoneNumber,
      ),
    );
  }
}

class Complaint {
  final String complaintId;
  final String title;
  final String description;
  final String location;
  final String contact;
  final String? imageUrl;
  final Map<dynamic, dynamic> likes;
  final Map<dynamic, dynamic> dislikes;
  final int likeCount;
  final int dislikeCount;
  final DateTime timestamp;

  Complaint({
    required this.title,
    required this.description,
    required this.location,
    required this.contact,
    required this.timestamp,
    this.complaintId = '',
    this.imageUrl,
    this.likes = const {},
    this.dislikes = const {},
    this.likeCount = 0,
    this.dislikeCount = 0,
  });

  factory Complaint.fromMap({
    required String complaintId,
    required Map<String, dynamic> map,
  }) {
    return Complaint(
      complaintId: complaintId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      contact: map['contact'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      imageUrl: map['imageUrl'],
      likes: Map<dynamic, dynamic>.from(map['likes'] ?? {}),
      dislikes: Map<dynamic, dynamic>.from(map['dislikes'] ?? {}),
      likeCount: map['likeCount'] ?? 0,
      dislikeCount: map['dislikeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'contact': contact,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'likes': likes,
      'dislikes': dislikes,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
    };
  }
}

class ComplaintItem extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onDelete;
  final String currentUserPhone;

  ComplaintItem({
    required this.complaint,
    required this.onLike,
    required this.onDislike,
    required this.onDelete,
    required this.currentUserPhone,
  });

  @override
  Widget build(BuildContext context) {
    final hasLiked = complaint.likes.containsKey(currentUserPhone);
    final hasDisliked = complaint.dislikes.containsKey(currentUserPhone);
    final isOwner = complaint.contact == currentUserPhone;

    return Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    complaint.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(complaint.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Reported by: ${complaint.contact}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 16),
                SizedBox(width: 6),
                Text(
                  complaint.location,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              complaint.description,
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            SizedBox(height: 12),
            if (complaint.imageUrl != null && complaint.imageUrl!.isNotEmpty)
        Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
    complaint.imageUrl!,
    height: 180,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
    Container(
    height: 180,
    color: Colors.grey[200],
    child: Center(child: Icon(Icons.broken_image)),
    ),
    ),
    ),
    ),
    Divider(color: Colors.grey[300]),
    SizedBox(height: 8),
    Row(
    children: [
    InkWell(
    onTap: onLike,
    borderRadius: BorderRadius.circular(20),
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    color: hasLiked ? Colors.green[50] : Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: hasLiked ? Colors.green : Colors.grey[300]!,
    ),
    ),
    child: Row(
    children: [
    Icon(
    Icons.thumb_up,
    size: 18,
    color: hasLiked ? Colors.green : Colors.grey,
    ),
    SizedBox(width: 6),
    Text(
    '${complaint.likeCount}',
    style: TextStyle(
    color: hasLiked ? Colors.green : Colors.grey,
    fontWeight: FontWeight.bold
    ),
    ),
    ],
    ),
    ),
    ),
    SizedBox(width: 16),
    InkWell(
    onTap: onDislike,
    borderRadius: BorderRadius.circular(20),
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    color: hasDisliked ? Colors.red[50] : Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: hasDisliked ? Colors.red : Colors.grey[300]!,
    ),
    ),
    child: Row(
    children: [
    Icon(
    Icons.thumb_down,
    size: 18,
    color: hasDisliked ? Colors.red : Colors.grey,
    ),
    SizedBox(width: 6),
    Text(
    '${complaint.dislikeCount}',
    style: TextStyle(
    color: hasDisliked ? Colors.red : Colors.grey,
    fontWeight: FontWeight.bold
    ),
    ),
    ],
    ),
    ),
    ),
    Spacer(),
    if (isOwner)
    Text(
    'Your complaint',
    style: TextStyle(fontSize: 12, color: Colors.green, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    ],
    ),
    ),
    );
  }
}