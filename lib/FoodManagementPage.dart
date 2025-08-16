import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FoodManagementApp extends StatelessWidget {
  final String phoneNumber;

  const FoodManagementApp({super.key, required this.phoneNumber});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: Colors.blue,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Food Management',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            backgroundColor: Colors.green[700],
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.fastfood), text: 'Post Food'),
                Tab(icon: Icon(Icons.shopping_cart), text: 'Request Food'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PostFoodTab(phoneNumber: phoneNumber),
              RequestFoodTab(phoneNumber: phoneNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class PostFoodTab extends StatefulWidget {
  final String phoneNumber;

  PostFoodTab({required this.phoneNumber});

  @override
  _PostFoodTabState createState() => _PostFoodTabState();
}

class _PostFoodTabState extends State<PostFoodTab> {
  final DatabaseReference _foodRef = FirebaseDatabase.instance.ref('food');
  List<FoodPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _foodRef.child('post').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<FoodPost> loadedPosts = [];
        data.forEach((phone, userPosts) {
          if (userPosts != null) {
            (userPosts as Map<dynamic, dynamic>).forEach((key, value) {
              loadedPosts.add(FoodPost.fromMap(
                postId: key,
                map: value,
                userPhone: phone,
              ));
            });
          }
        });
        setState(() => _posts = loadedPosts);
      } else {
        setState(() => _posts = []);
      }
    });
  }

  void _addNewPost(FoodPost newPost) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _foodRef.child('post/${widget.phoneNumber}/$timestamp').set(newPost.toMap());
  }

  void _deletePost(String userPhone, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this food post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _foodRef.child('post/$userPhone/$postId').remove();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Food post deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _posts.isEmpty
          ? Center(
        child: Text(
          'No food posts available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (ctx, index) => FoodPostItem(
          _posts[index],
          onDelete: () => _deletePost(
            _posts[index].userPhone,
            _posts[index].postId,
          ),
          isOwner: _posts[index].userPhone == widget.phoneNumber,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showPostFoodDialog(context),
      ),
    );
  }

  void _showPostFoodDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String foodName = '';
    String quantity = '';
    DateTime cookedTime = DateTime.now();
    TextEditingController _dateController = TextEditingController(
      text: DateFormat.yMd().add_jm().format(DateTime.now()),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Post Food", style: TextStyle(color: Colors.green[700])),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood, color: Colors.blue),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onChanged: (value) => foodName = value,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale, color: Colors.blue),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onChanged: (value) => quantity = value,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Cooked Time',
                    prefixIcon: Icon(Icons.access_time, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 2)),
                    );
                    if (selected != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        cookedTime = DateTime(
                          selected.year,
                          selected.month,
                          selected.day,
                          time.hour,
                          time.minute,
                        );
                        _dateController.text = DateFormat.yMd().add_jm().format(cookedTime);
                      }
                    }
                  },
                ),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newPost = FoodPost(
                  foodName: foodName,
                  quantity: quantity,
                  cookedTime: cookedTime,
                  contact: widget.phoneNumber,
                  userPhone: widget.phoneNumber,
                );
                _addNewPost(newPost);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Food posted successfully!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class RequestFoodTab extends StatefulWidget {
  final String phoneNumber;

  RequestFoodTab({required this.phoneNumber});

  @override
  _RequestFoodTabState createState() => _RequestFoodTabState();
}

class _RequestFoodTabState extends State<RequestFoodTab> {
  final DatabaseReference _foodRef = FirebaseDatabase.instance.ref('food');
  List<FoodRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    _foodRef.child('request').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<FoodRequest> loadedRequests = [];
        data.forEach((phone, userRequests) {
          if (userRequests != null) {
            (userRequests as Map<dynamic, dynamic>).forEach((key, value) {
              loadedRequests.add(FoodRequest.fromMap(
                requestId: key,
                map: value,
                userPhone: phone,
              ));
            });
          }
        });
        setState(() => _requests = loadedRequests);
      } else {
        setState(() => _requests = []);
      }
    });
  }

  void _addNewRequest(FoodRequest newRequest) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _foodRef.child('request/${widget.phoneNumber}/$timestamp').set(newRequest.toMap());
  }

  void _deleteRequest(String userPhone, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this food request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _foodRef.child('request/$userPhone/$requestId').remove();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Food request deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _requests.isEmpty
          ? Center(
        child: Text(
          'No food requests available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (ctx, index) => FoodRequestItem(
          _requests[index],
          onDelete: () => _deleteRequest(
            _requests[index].userPhone,
            _requests[index].requestId,
          ),
          isOwner: _requests[index].userPhone == widget.phoneNumber,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showRequestFoodDialog(context),
      ),
    );
  }

  void _showRequestFoodDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String item = '';
    String quantity = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Request Food", style: TextStyle(color: Colors.blue)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood, color: Colors.green),
                ),
                onChanged: (value) => item = value,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale, color: Colors.green),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (value) => quantity = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newRequest = FoodRequest(
                  item: item.isNotEmpty ? item : null,
                  quantity: quantity,
                  contact: widget.phoneNumber,
                  userPhone: widget.phoneNumber,
                );
                _addNewRequest(newRequest);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Food request submitted!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Data Models
class FoodPost {
  final String postId;
  final String userPhone;
  final String foodName;
  final String quantity;
  final DateTime cookedTime;
  final String contact;

  FoodPost({
    required this.foodName,
    required this.quantity,
    required this.cookedTime,
    required this.contact,
    required this.userPhone,
    this.postId = '',
  });

  factory FoodPost.fromMap({
    required String postId,
    required Map<dynamic, dynamic> map,
    required String userPhone,
  }) {
    return FoodPost(
      postId: postId,
      userPhone: userPhone,
      foodName: map['foodName'],
      quantity: map['quantity'],
      cookedTime: DateTime.parse(map['cookedTime']),
      contact: map['contact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'quantity': quantity,
      'cookedTime': cookedTime.toIso8601String(),
      'contact': contact,
    };
  }
}

class FoodRequest {
  final String requestId;
  final String userPhone;
  final String? item;
  final String quantity;
  final String contact;

  FoodRequest({
    this.item,
    required this.quantity,
    required this.contact,
    required this.userPhone,
    this.requestId = '',
  });

  factory FoodRequest.fromMap({
    required String requestId,
    required Map<dynamic, dynamic> map,
    required String userPhone,
  }) {
    return FoodRequest(
      requestId: requestId,
      userPhone: userPhone,
      item: map['item'],
      quantity: map['quantity'],
      contact: map['contact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (item != null) 'item': item,
      'quantity': quantity,
      'contact': contact,
    };
  }
}

// UI Components with delete option
class FoodPostItem extends StatelessWidget {
  final FoodPost post;
  final VoidCallback onDelete;
  final bool isOwner;

  FoodPostItem(this.post, {required this.onDelete, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    post.foodName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
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
              children: [
                Icon(Icons.scale, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text('Quantity: ${post.quantity}'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text('Cooked: ${DateFormat.yMd().add_jm().format(post.cookedTime)}'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text('Contact: ${post.contact}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodRequestItem extends StatelessWidget {
  final FoodRequest request;
  final VoidCallback onDelete;
  final bool isOwner;

  FoodRequestItem(this.request, {required this.onDelete, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.item ?? 'Any Food',
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
              children: [
                Icon(Icons.scale, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text('Quantity: ${request.quantity}'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text('Contact: ${request.contact}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}