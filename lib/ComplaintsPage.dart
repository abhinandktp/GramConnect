// complaints_page.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ComplaintPost {
  final String? imagePath;
  final String shortDescription;
  final String description;
  final String location;
  final String userId;
  int likes;
  int dislikes;

  ComplaintPost({
    this.imagePath,
    required this.shortDescription,
    required this.description,
    required this.location,
    required this.userId,
    this.likes = 0,
    this.dislikes = 0,
  });
}

class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> with SingleTickerProviderStateMixin {
  final String _currentUserId = 'Anurag';
  List<ComplaintPost> _allComplaints = [
    ComplaintPost(
      imagePath: null,
      shortDescription: 'Large Pothole',
      description: 'There is a very large and dangerous pothole on main street near the park entrance. It has been there for over a month and is a hazard to vehicles and pedestrians.',
      location: 'Main St, Downtown',
      userId: 'user2',
    ),
    ComplaintPost(
      imagePath: null,
      shortDescription: 'Uncollected Garbage',
      description: 'Garbage has not been collected from the curb for over a week in our residential area. The bins are overflowing and attracting pests. This is a public health concern.',
      location: 'Residential Area C',
      userId: 'user1',
    ),
  ];
  Set<ComplaintPost> _selectedComplaints = {};
  Map<ComplaintPost, String> _userInteractions = {};

  late TabController _tabController;
  final ValueNotifier<bool> _showFABNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _showFABNotifier.value = _tabController.index == 0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showFABNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        // ✅ FIXED: Add a back button for navigation
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'View Complaints'),
            Tab(text: 'My Complaints'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildViewComplaintsTab(),
          _buildMyComplaintsTab(),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showFABNotifier,
        builder: (context, showFAB, child) {
          return showFAB
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity, // This makes the button full-width
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade800, Colors.green.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FloatingActionButton.extended(
                  onPressed: _showAddComplaintForm,
                  label: Text(
                    'Add Complaint',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  icon: Icon(Icons.add_circle_outline, color: Colors.white),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          )
              : SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the button at the bottom
    );
  }

  Widget _buildViewComplaintsTab() {
    return _allComplaints.isEmpty
        ? Center(child: Text('No complaints have been posted yet.', style: TextStyle(color: Colors.grey, fontSize: 16)))
        : ListView.builder(
      itemCount: _allComplaints.length,
      padding: EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final complaint = _allComplaints[index];
        final userAction = _userInteractions[complaint];

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showDetailedComplaintView(complaint),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (complaint.imagePath != null && !kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(complaint.imagePath!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.location,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text(complaint.shortDescription, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (userAction == 'like') {
                                    complaint.likes--;
                                    _userInteractions.remove(complaint);
                                  } else if (userAction == 'dislike') {
                                    complaint.dislikes--;
                                    complaint.likes++;
                                    _userInteractions[complaint] = 'like';
                                  } else {
                                    complaint.likes++;
                                    _userInteractions[complaint] = 'like';
                                  }
                                });
                              },
                              icon: Icon(Icons.thumb_up, color: userAction == 'like' ? Colors.green : Colors.grey),
                              label: Text('${complaint.likes}'),
                            ),
                            SizedBox(width: 8.0),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (userAction == 'dislike') {
                                    complaint.dislikes--;
                                    _userInteractions.remove(complaint);
                                  } else if (userAction == 'like') {
                                    complaint.likes--;
                                    complaint.dislikes++;
                                    _userInteractions[complaint] = 'dislike';
                                  } else {
                                    complaint.dislikes++;
                                    _userInteractions[complaint] = 'dislike';
                                  }
                                });
                              },
                              icon: Icon(Icons.thumb_down, color: userAction == 'dislike' ? Colors.red : Colors.grey),
                              label: Text('${complaint.dislikes}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyComplaintsTab() {
    final myComplaints = _allComplaints.where((c) => c.userId == _currentUserId).toList();
    if (myComplaints.isEmpty) {
      return Center(child: Text('You have not posted any complaints yet.', style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: myComplaints.length,
            itemBuilder: (context, index) {
              final complaint = myComplaints[index];
              final isSelected = _selectedComplaints.contains(complaint);
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: CheckboxListTile(
                  title: Text(complaint.shortDescription),
                  subtitle: Text('Location: ${complaint.location}'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedComplaints.add(complaint);
                      } else {
                        _selectedComplaints.remove(complaint);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        if (_selectedComplaints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Colors.red.shade800, Colors.red.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _removeSelectedComplaints,
                icon: Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  'Remove Selected (${_selectedComplaints.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddComplaintForm() {
    _showFABNotifier.value = false;
    final shortDescriptionController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String? _dialogImagePath;

    Future<void> _pickImage(ImageSource source, StateSetter dialogSetState) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        dialogSetState(() {
          _dialogImagePath = pickedFile.path;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: Text('Add New Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dialogImagePath != null && !kIsWeb)
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Image.file(
                          File(_dialogImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: _dialogImagePath != null ? 10 : 0),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.photo_library),
                                    title: Text('Photo Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery, dialogSetState);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera, dialogSetState);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text(_dialogImagePath != null ? 'Change Image' : 'Add Image'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: shortDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Short Description *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Detailed Description *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showFABNotifier.value = true;
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (locationController.text.isNotEmpty && descriptionController.text.isNotEmpty && shortDescriptionController.text.isNotEmpty) {
                      final newComplaint = ComplaintPost(
                        shortDescription: shortDescriptionController.text,
                        location: locationController.text,
                        description: descriptionController.text,
                        imagePath: _dialogImagePath,
                        userId: _currentUserId,
                      );
                      setState(() {
                        _allComplaints.add(newComplaint);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Complaint added successfully!')),
                      );
                      _showFABNotifier.value = true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all mandatory fields (marked with *)')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailedComplaintView(ComplaintPost complaint) {
    _showFABNotifier.value = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(complaint.shortDescription, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (complaint.imagePath != null && !kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Image.file(
                      File(complaint.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                Text('Location: ${complaint.location}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(complaint.description, style: TextStyle(fontSize: 14)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Likes: ${complaint.likes}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    Text('Dislikes: ${complaint.dislikes}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showFABNotifier.value = true;
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _removeSelectedComplaints() {
    setState(() {
      _allComplaints.removeWhere((complaint) => _selectedComplaints.contains(complaint));
      _selectedComplaints.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected complaints removed.')),
    );
  }
}