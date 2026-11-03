
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  Stream<QuerySnapshot> getChatRooms() {
    final currentUser = _auth.currentUser!;

    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUser.uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser!;
    final chatRoomId = getChatRoomId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String otherUserEmail,
    required String itemTitle,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      throw StateError('User must be signed in.');
    }

    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty || cleanMessage.length > 2000) {
      throw ArgumentError('Message must contain 1-2000 characters.');
    }

    if (otherUserId == currentUser.uid) {
      throw ArgumentError('Cannot send a message to yourself.');
    }

    final chatRoomId = getChatRoomId(currentUser.uid, otherUserId);

    final chatRoomRef =
        _firestore.collection('chat_rooms').doc(chatRoomId);

    final messageRef =
        chatRoomRef.collection('messages').doc();

    await _firestore.runTransaction((transaction) async {
      final chatRoomSnapshot = await transaction.get(chatRoomRef);

      if (chatRoomSnapshot.exists) {
        final users = List<String>.from(
          chatRoomSnapshot.data()?['users'] ?? [],
        );

        if (users.length != 2 ||
            !users.contains(currentUser.uid) ||
            !users.contains(otherUserId)) {
          throw StateError('Invalid chat room participants.');
        }

        transaction.update(chatRoomRef, {
          'lastMessage': cleanMessage,
          'lastMessageId': messageRef.id,
          'lastTimestamp': FieldValue.serverTimestamp(),
        });
      } else {
        final users = [currentUser.uid, otherUserId]..sort();

        transaction.set(chatRoomRef, {
          'users': users,
          'userEmails': {
            currentUser.uid: currentUser.email,
            otherUserId: otherUserEmail,
          },
          'itemTitle': itemTitle,
          'lastMessage': cleanMessage,
          'lastMessageId': messageRef.id,
          'lastTimestamp': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(messageRef, {
        'senderId': currentUser.uid,
        'senderEmail': currentUser.email,
        'receiverId': otherUserId,
        'message': cleanMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
