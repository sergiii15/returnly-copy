
const fs = require('node:fs');
const assert = require('node:assert/strict');

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

async function main() {
  const testEnv = await initializeTestEnvironment({
    projectId: 'demo-returnly',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: fs.readFileSync('firestore.rules', 'utf8'),
    },
  });

  try {
    await testEnv.clearFirestore();

    // Create a test room without applying security rules.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore()
        .collection('chat_rooms')
        .doc('alice_bob')
        .set({
          users: ['alice', 'bob'],
          userEmails: {
            alice: 'alice@example.com',
            bob: 'bob@example.com',
          },
          itemTitle: 'Test Item',
          lastMessage: 'Hello',
          lastMessageId: 'message1',
          lastTimestamp: new Date(),
        });
    });

    const alice = testEnv.authenticatedContext('alice');
    const stranger = testEnv.authenticatedContext('stranger');

    const roomPath = 'chat_rooms/alice_bob';

    // A participant must be able to read the room.
    await assertSucceeds(
      alice.firestore().doc(roomPath).get()
    );

    // A stranger must not be able to read the room.
    await assertFails(
      stranger.firestore().doc(roomPath).get()
    );

    console.log('PASS: Participant can read the chat room.');
    console.log('PASS: Stranger cannot read the chat room.');

    // TEST: Create a room and send its first message.
    const charlie = testEnv.authenticatedContext('charlie', {
      email: 'charlie@example.com',
    });

    const db = charlie.firestore();

    const newRoomRef = db
      .collection('chat_rooms')
      .doc('charlie_david');

    const newMessageRef = newRoomRef
      .collection('messages')
      .doc('first_message');

const firebase = require('firebase/compat/app');
require('firebase/compat/firestore');
const FieldValue = firebase.firestore.FieldValue;

    await assertSucceeds(
      db.runTransaction(async (transaction) => {
        const roomSnapshot = await transaction.get(newRoomRef);

        if (roomSnapshot.exists) {
          throw new Error('Test room already exists.');
        }

        transaction.set(newRoomRef, {
          users: ['charlie', 'david'],
          userEmails: {
            charlie: 'charlie@example.com',
            david: 'david@example.com',
          },
          itemTitle: 'Test Backpack',
          lastMessage: 'Hello David!',
          lastMessageId: newMessageRef.id,
          lastTimestamp: FieldValue.serverTimestamp(),
        });

        transaction.set(newMessageRef, {
          senderId: 'charlie',
          senderEmail: 'charlie@example.com',
          receiverId: 'david',
          message: 'Hello David!',
          timestamp: FieldValue.serverTimestamp(),
        });
      })
    );

    console.log(
      'PASS: First message and chat room created together.'
    );

      // TEST: A stranger cannot modify another user's chat room.
  await assertFails(
    stranger.firestore().doc(roomPath).update({
      lastMessage: 'Hacked message',
    })
  );

  console.log('PASS: Stranger cannot modify another chat room.');
    // TEST: A stranger cannot send messages to another user's room.
  await assertFails(
    stranger.firestore()
      .collection('chat_rooms')
      .doc('alice_bob')
      .collection('messages')
      .doc('unauthorized_message')
      .set({
        senderId: 'stranger',
        senderEmail: 'stranger@example.com',
        receiverId: 'alice',
        message: 'Unauthorized message',
        timestamp: new Date(),
      })
  );

  console.log('PASS: Stranger cannot send messages to another chat room.');
    // TEST: A participant can send a second message.
  const secondMessageRef = newRoomRef.collection('messages').doc('second_message');

  await assertSucceeds(
    db.runTransaction(async (transaction) => {
      const roomSnapshot = await transaction.get(newRoomRef);

      if (!roomSnapshot.exists) {
        throw new Error('The chat room does not exist.');
      }

      transaction.update(newRoomRef, {
        lastMessage: 'How are you, David?',
        lastMessageId: secondMessageRef.id,
        lastTimestamp: FieldValue.serverTimestamp(),
      });

      transaction.set(secondMessageRef, {
        senderId: 'charlie',
        senderEmail: 'charlie@example.com',
        receiverId: 'david',
        message: 'How are you, David?',
        timestamp: FieldValue.serverTimestamp(),
      });
    })
  );

  console.log('PASS: Participant can send a second message.');
    // TEST: A participant cannot edit an existing message.
  await assertFails(
    db.collection('chat_rooms')
      .doc('charlie_david')
      .collection('messages')
      .doc('first_message')
      .update({
        message: 'Modified message',
      })
  );

  console.log('PASS: Participant cannot edit an existing message.');
    // TEST: A participant cannot delete an existing message.
  await assertFails(
    db.collection('chat_rooms')
      .doc('charlie_david')
      .collection('messages')
      .doc('first_message')
      .delete()
  );

  console.log('PASS: Participant cannot delete an existing message.');
    // TEST: A user cannot create a chat room without being a participant.
  await assertFails(
    stranger.firestore()
      .collection('chat_rooms')
      .doc('alice_bob_fake')
      .set({
        users: ['alice', 'bob'],
        userEmails: {
          alice: 'alice@example.com',
          bob: 'bob@example.com',
        },
        itemTitle: 'Fake Item',
        lastMessage: 'Fake message',
        lastMessageId: 'fake_message',
        lastTimestamp: new Date(),
      })
  );

  console.log('PASS: Stranger cannot create a room for other users.');
    // TEST: A user cannot impersonate another sender.
  await assertFails(
    db.collection('chat_rooms')
      .doc('charlie_david')
      .collection('messages')
      .doc('fake_sender_message')
      .set({
        senderId: 'david',
        senderEmail: 'david@example.com',
        receiverId: 'charlie',
        message: 'Fake message from David',
        timestamp: FieldValue.serverTimestamp(),
      })
  );

  console.log('PASS: User cannot impersonate another sender.');
  console.log('ALL TESTS PASSED');
  } finally {
    await testEnv.cleanup();
  }
}

main().catch((error) => {
  console.error('TEST FAILED:', error);
  process.exitCode = 1;
});








