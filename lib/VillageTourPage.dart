import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Review {
  final String userId;
  final String text;
  final double rating;

  Review({
    required this.userId,
    required this.text,
    required this.rating,
  });
}

class VillagePost {
  final String placeName;
  final String location;
  final String description;
  final List<String> imagePaths;
  final String userId;
  List<Review> reviews;
  double averageRating;

  VillagePost({
    required this.placeName,
    required this.location,
    required this.description,
    required this.imagePaths,
    required this.userId,
    this.reviews = const [],
    this.averageRating = 0.0,
  });
}

class VillageTourPage extends StatefulWidget {
  @override
  _VillageTourPageState createState() => _VillageTourPageState();
}

class _VillageTourPageState extends State<VillageTourPage> with SingleTickerProviderStateMixin {
  final String _currentUserId = 'user1';
  List<VillagePost> _allPosts = [
    VillagePost(
      placeName: 'Kozhikode Beach',
      location: 'Near the Lighthouse',
      description: 'The iconic beach of Calicut, famous for its breathtaking sunset views and vibrant street food stalls. The perfect place for an evening stroll.',
      imagePaths: [],
      userId: 'Amal',
      reviews: [
        Review(userId: 'Reshma', text: 'Loved the vibe! The Pazhampori from the stalls was amazing.', rating: 5.0),
        Review(userId: 'Arjun', text: 'Gets a bit crowded, but the view is unbeatable.', rating: 4.5),
      ],
    ),
    VillagePost(
      placeName: 'Mishkal Mosque',
      location: 'Kuttichira',
      description: 'A beautiful and historic mosque with unique architectural style, built without any domes or minarets. A must-visit for history and architecture enthusiasts.',
      imagePaths: [],
      userId: 'Farah',
      reviews: [
        Review(userId: 'Amal', text: 'The old-world charm is incredible. So much history here.', rating: 5.0),
        Review(userId: 'Reshma', text: 'Quiet and very peaceful.', rating: 4.0),
      ],
    ),
    VillagePost(
      placeName: 'Mananchira Square',
      location: 'City Center',
      description: 'A serene public park surrounding the historic Mananchira pond. A great place to relax, especially in the evening with the musical fountain.',
      imagePaths: [],
      userId: 'Anand',
      reviews: [
        Review(userId: 'Farah', text: 'A clean and well-maintained park. The lighting is beautiful at night.', rating: 4.5),
        Review(userId: 'Arjun', text: 'The pond is a lovely centerpiece. A very calming atmosphere.', rating: 5.0),
      ],
    ),
    VillagePost(
      placeName: 'Thusharagiri Waterfalls',
      location: 'Kodenchery, Kozhikode',
      description: 'A series of waterfalls surrounded by lush greenery. The trek to the top is challenging but rewarding. Perfect for nature lovers and adventurers.',
      imagePaths: [],
      userId: 'Reshma',
      reviews: [
        Review(userId: 'Amal', text: 'Absolutely stunning! The sound of the water is so refreshing.', rating: 5.0),
        Review(userId: 'Anand', text: 'The trekking trail is a bit tricky, but the view is worth it.', rating: 4.0),
      ],
    ),
    VillagePost(
      placeName: 'Kallai River',
      location: 'Kallai',
      description: 'Once a bustling hub for the timber trade, the Kallai River is now a calm waterway with a rich history. A peaceful spot to watch local life.',
      imagePaths: [],
      userId: 'Arjun',
      reviews: [
        Review(userId: 'Farah', text: 'Learned so much about the timber history. A good visit.', rating: 4.0),
      ],
    ),
    VillagePost(
      placeName: 'S.M. Street (Mittayi Theruvu)',
      location: 'Sweet Meat Street, City Center',
      description: 'Kozhikode\'s famous shopping street, known for its sweet shops, local delicacies, and vibrant atmosphere. A sensory overload in the best way!',
      imagePaths: [],
      userId: 'Amal',
      reviews: [
        Review(userId: 'Reshma', text: 'The Kozhikodan Halwa is a must-try here! Absolutely delicious.', rating: 5.0),
        Review(userId: 'Anand', text: 'Crowded but great for finding local snacks.', rating: 4.5),
      ],
    ),
  ];

  Set<VillagePost> _selectedPosts = {};
  late TabController _tabController;
  final ValueNotifier<bool> _showFABNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _showFABNotifier.value = _tabController.index == 0;
    });
    _calculateAllAverageRatings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showFABNotifier.dispose();
    super.dispose();
  }

  void _calculateAllAverageRatings() {
    for (var post in _allPosts) {
      _calculateAverageRating(post);
    }
  }

  void _calculateAverageRating(VillagePost post) {
    if (post.reviews.isEmpty) {
      post.averageRating = 0.0;
    } else {
      double totalRating = 0;
      for (var review in post.reviews) {
        totalRating += review.rating;
      }
      post.averageRating = totalRating / post.reviews.length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Village Tour', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
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
            Tab(text: 'View Places'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildViewPlacesTab(),
          _buildMyPostsTab(),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showFABNotifier,
        builder: (context, showFAB, child) {
          return showFAB
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
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
                  onPressed: _showAddPostForm,
                  label: Text(
                    'Add Place',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildViewPlacesTab() {
    if (_allPosts.isEmpty) {
      return Center(child: Text('No places have been posted yet.', style: TextStyle(color: Colors.grey, fontSize: 16)));
    }
    return ListView.builder(
      itemCount: _allPosts.length,
      padding: EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final post = _allPosts[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showDetailedPostView(post),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.imagePaths.isNotEmpty && !kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(post.imagePaths.first),
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
                          post.placeName,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text(post.location, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < post.averageRating.floor() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            SizedBox(width: 8),
                            Text('${post.averageRating.toStringAsFixed(1)}/5.0'),
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

  Widget _buildMyPostsTab() {
    final myPosts = _allPosts.where((p) => p.userId == _currentUserId).toList();
    if (myPosts.isEmpty) {
      return Center(child: Text('You have not posted any places yet.', style: TextStyle(color: Colors.grey, fontSize: 16)));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: myPosts.length,
            itemBuilder: (context, index) {
              final post = myPosts[index];
              final isSelected = _selectedPosts.contains(post);
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: CheckboxListTile(
                  title: Text(post.placeName),
                  subtitle: Text('Location: ${post.location}'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedPosts.add(post);
                      } else {
                        _selectedPosts.remove(post);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        if (_selectedPosts.isNotEmpty)
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
                onPressed: _removeSelectedPosts,
                icon: Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  'Remove Selected (${_selectedPosts.length})',
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

  void _showAddPostForm() {
    _showFABNotifier.value = false;
    final placeNameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    List<String> _dialogImagePaths = [];
    double _rating = 0.0;

    Future<void> _pickImages(ImageSource source, StateSetter dialogSetState) async {
      final picker = ImagePicker();
      if (source == ImageSource.camera) {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          dialogSetState(() {
            _dialogImagePaths.add(pickedFile.path);
          });
        }
      } else {
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles != null) {
          dialogSetState(() {
            _dialogImagePaths.addAll(pickedFiles.map((x) => x.path));
          });
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: Text('Add New Place', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dialogImagePaths.isNotEmpty)
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _dialogImagePaths.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: kIsWeb
                                  ? Image.network(_dialogImagePaths[index], fit: BoxFit.cover, width: 150)
                                  : Image.file(File(_dialogImagePaths[index]), fit: BoxFit.cover, width: 150),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: _dialogImagePaths.isNotEmpty ? 10 : 0),
                    ElevatedButton.icon(
                      onPressed: _dialogImagePaths.length >= 5 ? null : () {
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
                                      _pickImages(ImageSource.gallery, dialogSetState);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImages(ImageSource.camera, dialogSetState);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text(_dialogImagePaths.isNotEmpty ? 'Add More Pictures' : 'Add Pictures (Max 5)'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: placeNameController,
                      decoration: InputDecoration(
                        labelText: 'Place Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.place),
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
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Rating:', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  dialogSetState(() {
                                    _rating = index + 1.0;
                                  });
                                },
                                // ✅ FIXED: Reduced padding to fit stars in one line
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Icon(
                                    index < _rating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 28, // Adjusted size to be smaller
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
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
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (placeNameController.text.isNotEmpty && locationController.text.isNotEmpty && descriptionController.text.isNotEmpty && _rating > 0 && _dialogImagePaths.isNotEmpty) {
                      final newPost = VillagePost(
                        placeName: placeNameController.text,
                        location: locationController.text,
                        description: descriptionController.text,
                        imagePaths: _dialogImagePaths,
                        userId: _currentUserId,
                        reviews: [Review(userId: _currentUserId, text: 'Initial rating by poster', rating: _rating)],
                      );
                      setState(() {
                        _allPosts.add(newPost);
                        _calculateAverageRating(newPost);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Place added successfully!')),
                      );
                      _showFABNotifier.value = true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all mandatory fields (marked with *) and add at least one photo and a rating.')),
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

  void _showDetailedPostView(VillagePost post) {
    _showFABNotifier.value = false;
    final reviewController = TextEditingController();
    double _newRating = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(post.placeName, style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (post.imagePaths.isNotEmpty)
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imagePaths.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: kIsWeb
                                  ? Image.network(post.imagePaths[index], fit: BoxFit.cover, width: 250)
                                  : Image.file(File(post.imagePaths[index]), fit: BoxFit.cover, width: 250),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 10),
                    Text('Location: ${post.location}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.description, style: TextStyle(fontSize: 14)),
                    SizedBox(height: 20),
                    Text('Average Rating: ${post.averageRating.toStringAsFixed(1)}/5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < post.averageRating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (post.reviews.isEmpty)
                      Text('No reviews yet.')
                    else
                      ...post.reviews.map((review) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          color: Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('User ${review.userId.replaceAll('user', '')}:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    ...List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating.floor() ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ],
                                ),
                                Text(review.text),
                              ],
                            ),
                          ),
                        ),
                      )),
                    SizedBox(height: 20),
                    Text('Add Your Review:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        labelText: 'Your review...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10),
                    Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              dialogSetState(() {
                                _newRating = index + 1.0;
                              });
                            },
                            // ✅ FIXED: Reduced padding to fit stars in one line
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(
                                index < _newRating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 28, // Adjusted size to be smaller
                              ),
                            ),
                          );
                        }),
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
                ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty && _newRating > 0) {
                      setState(() {
                        post.reviews.add(Review(userId: _currentUserId, text: reviewController.text, rating: _newRating));
                        _calculateAverageRating(post);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Review added successfully!')),
                      );
                      _showFABNotifier.value = true;
                    }
                  },
                  child: Text('Submit Review'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeSelectedPosts() {
    setState(() {
      _allPosts.removeWhere((post) => _selectedPosts.contains(post));
      _selectedPosts.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected posts removed.')),
    );
  }
}