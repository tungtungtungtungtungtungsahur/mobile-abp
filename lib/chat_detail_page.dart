import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class ChatDetailPage extends StatefulWidget {
  final String receiverId;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic>? productInfo;

  const ChatDetailPage({
    super.key,
    required this.receiverId,
    required this.name,
    required this.avatarUrl,
    this.productInfo,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _chatId;

  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _showMap = false;
  bool _loadingMap = false;
  loc.Location? _locationService;

  @override
  void initState() {
    super.initState();
    _getOrCreateChat();
    _markMessagesAsRead();
    _locationService = loc.Location();
  }

  Future<void> _getOrCreateChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('Current user is null in _getOrCreateChat');
      return;
    }

    // Create a unique chat ID by combining both user IDs and product info
    final users = [currentUser.uid, widget.receiverId]
        .where((id) => id.isNotEmpty)
        .toList()
      ..sort();
    if (users.length < 2) {
      debugPrint('One or both user IDs are empty: users=$users');
    }
    final productName = widget.productInfo?['name']?.toString() ?? '';
    final productId = widget.productInfo?['id']?.toString() ?? '';

    // Ensure chatId is never empty by using a fallback
    _chatId = users.isNotEmpty
        ? '${users.join('_')}_${productId.isNotEmpty ? productId : productName.hashCode}'
        : DateTime.now().millisecondsSinceEpoch.toString();
    if (_chatId.isEmpty) {
      debugPrint(
          'Chat ID is empty, using fallback. users=$users, productId=$productId, productName=$productName');
      _chatId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Check if chat exists, if not create it
    final chatDoc = await _firestore.collection('chats').doc(_chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(_chatId).set({
        'participants': users,
        'productInfo': widget.productInfo,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final message = {
      'senderId': currentUser.uid,
      'receiverId': widget.receiverId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'productInfo': widget.productInfo,
    };

    // Add message to messages subcollection
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add(message);

    // Update last message in chat document
    await _firestore.collection('chats').doc(_chatId).update({
      'lastMessage': _messageController.text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingMap = true);
    try {
      bool serviceEnabled = await _locationService!.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService!.requestService();
        if (!serviceEnabled) {
          setState(() => _loadingMap = false);
          return;
        }
      }
      loc.PermissionStatus permissionGranted = await _locationService!.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationService!.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => _loadingMap = false);
          return;
        }
      }
      final locData = await _locationService!.getLocation();
      setState(() {
        _selectedLocation = LatLng(locData.latitude ?? 0.0, locData.longitude ?? 0.0);
        _loadingMap = false;
      });
      _mapController.move(_selectedLocation!, 15.0);
    } catch (e) {
      setState(() => _loadingMap = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    setState(() => _loadingMap = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _selectedLocation = LatLng(loc.latitude, loc.longitude);
          _loadingMap = false;
        });
        _mapController.move(_selectedLocation!, 15.0);
      } else {
        setState(() => _loadingMap = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi tidak ditemukan')),
        );
      }
    } catch (e) {
      setState(() => _loadingMap = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari lokasi: $e')),
      );
    }
  }

  void _shareSelectedLocation() async {
    if (_selectedLocation != null) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final message = {
        'senderId': currentUser.uid,
        'receiverId': widget.receiverId,
        'message': 'Lokasi: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'isLocation': true,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'productInfo': widget.productInfo,
      };

      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add(message);

      await _firestore.collection('chats').doc(_chatId).update({
        'lastMessage': '[Lokasi]',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      setState(() {
        _showMap = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${widget.productInfo?['sellerUsername'] ?? 'unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          if (widget.productInfo != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (widget.productInfo?['images'] != null &&
                            (widget.productInfo?['images'] as List).isNotEmpty)
                        ? Image.network(
                            widget.productInfo!['images'][0].toString(),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 30),
                          )
                        : const Icon(Icons.broken_image, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.productInfo?['name'] ?? '').toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${(widget.productInfo?['price'] ?? '').toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_showMap)
            Container(
              height: 320,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari lokasi...',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchLocation(_searchController.text);
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) _searchLocation(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loadingMap
                        ? Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _selectedLocation ?? LatLng(-6.2, 106.8),
                              zoom: 15.0,
                              onTap: (tapPosition, point) {
                                setState(() => _selectedLocation = point);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.app',
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40.0,
                                      height: 40.0,
                                      point: _selectedLocation!,
                                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('Kirim Lokasi'),
                    onPressed: _shareSelectedLocation,
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser?.uid;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final isRead = message['read'] ?? false;

                    // Check if this is a location message
                    final isLocation = message['isLocation'] == true;

                    // Check if this is the first message of the day
                    final bool showDate = index == messages.length - 1 ||
                        _isDifferentDay(
                          timestamp?.toDate(),
                          (messages[index + 1].data()
                                  as Map<String, dynamic>)['timestamp']
                              as Timestamp?,
                        );

                    return Column(
                      children: [
                        if (showDate)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDate(timestamp?.toDate()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isLocation
                                ? Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lokasi dibagikan',
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: 200,
                                        height: 120,
                                        child: FlutterMap(
                                          options: MapOptions(
                                            center: LatLng(
                                              message['latitude'] ?? 0.0,
                                              message['longitude'] ?? 0.0,
                                            ),
                                            zoom: 15.0,
                                            interactiveFlags: InteractiveFlag.none,
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                              subdomains: ['a', 'b', 'c'],
                                              userAgentPackageName:
                                                  'com.example.app',
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  point: LatLng(
                                                    message['latitude'] ?? 0.0,
                                                    message['longitude'] ?? 0.0,
                                                  ),
                                                  child: Icon(Icons.location_on,
                                                      color: Colors.red,
                                                      size: 40),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            timestamp != null
                                                ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                                                : '',
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 10,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              isRead
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 14,
                                              color: isRead
                                                  ? Colors.blue[100]
                                                  : Colors.white70,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: () {
                    setState(() {
                      _showMap = !_showMap;
                      if (_showMap && _selectedLocation == null) {
                        _getCurrentLocation();
                      }
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(DateTime? date1, Timestamp? date2) {
    if (date1 == null || date2 == null) return true;
    return date1.year != date2.toDate().year ||
        date1.month != date2.toDate().month ||
        date1.day != date2.toDate().day;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hari Ini';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
