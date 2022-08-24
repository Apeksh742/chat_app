const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");
const { firestore } = require("firebase-admin");
admin.initializeApp(functions.config().functions);


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

exports.api = functions.https.onRequest(async (request, response) => {
  switch (request.method) {
    case 'GET':
      const res = await axios.get('https://jsonplaceholder.typicode.com/users/1')
      response.send(res.data);
      break;
    case 'POST':
      const body = request.body;
      response.send(body);
      break;
    case 'DELETE':
      response.send('It was delete request');
      break;
    default:
      response.send('Unsupported request');
      break;
  }
});

exports.messageTrigger = functions.firestore.document('/test/{Id}').onCreate(async (snapshot, context) => {
  if (snapshot.empty) {
    console.log("No devices found");
    return;
  }
  var tokens = [
    "cIyevg19QQWKgG5UJGhWUz:APA91bGHvYSusV1PpZ6O3vs87uugWDXJ1w0zTBbb-2_6vWWZxk3QIiqa_l4bnPrOpJ8fcJ6tMm31E2dV8v356HamrysHKvudgId_-OHBONusqNWM6NGktN3_SI14n_RW1RdRCnJSii25",
  ];
  var payload = {
    notification: {  //This is the payload for the notification          
      title: "New Message",
      body: snapshot.data().message,
      sound: "default"
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      message: "Sample Push Message"
    }
  };
  try {
    var response = await admin.messaging().sendToDevice(tokens, payload);
    console.log("Successfully sent message:", response);
    console.log(response.results[0].error);
  } catch (error) {
    console.log(error);
  }
  return Promise.resolve();
});
// we can get the other user name by checking which name is not present in users list and sentBy and then take out its fcm token from users collection
exports.chatTrigger = functions.firestore.document('/ChatRoom/{chatRoomId}/chats/{messageId}').onCreate(async (snapshot, context) => {
  if (snapshot.empty) {
    // console.log("No messages found");
    return;
  }
  var receiverUserName = "";
  var usersList = snapshot.data().users;
  var receiverFCMToken = [];
  // console.log(usersList);
  for (var i in usersList) {
    if (usersList[i] != snapshot.data().sentBy) {
      receiverUserName = usersList[i];
    }
  }
  var senderId = "";
  if (snapshot.data().senderId != null) {
    senderId = snapshot.data().senderId;
  } else {
    return;
  }
  var receiverFCMToken = [];
  var senderProfileImage = "";
  await firestore().collectionGroup('Users').where('uid', '==', senderId).limit(1).get().then((snapshot) => {
    if (snapshot.docs[0].data().profileURL != null) {
      senderProfileImage = snapshot.docs[0].data().profileURL;
    }
  });
  await firestore().collectionGroup('Users').where('Username', '==', receiverUserName).limit(1).get().then((snapshot) => {
    if (snapshot.docs[0].data().fcmToken != null) {
      receiverFCMToken.push(snapshot.docs[0].data().fcmToken);
    } else {
      return;
    }
  });
  // await admin.firestore().collection('Users').get().then(snapshot => {
  //   snapshot.forEach(doc => {
  //     if (doc.data().Username == receiverUserName) {
  //       // receiverEmail = doc.data().Email;
  //       receiverFCMToken = doc.data().fcmToken;
  //       // console.log("receiverEmail Found: " + receiverEmail);
  //     }
  //     // console.log("Present email: " + doc.data().Email);
  //   });
  // });

  var payload = {
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      senderName: snapshot.data().sentBy,
      message: snapshot.data().message,
      senderProfileURL: senderProfileImage,
      isPhoto: String(snapshot.data().isPhoto),
    }
  };
  try {
    var response = await admin.messaging().sendToDevice(receiverFCMToken, payload);
    console.log("Successfully sent message:", response);
    console.log(response.results[0].error);
  } catch (error) {
    console.log(error);
  }
  return Promise.resolve();
});

// exports.cgTestFunc = functions.https.onRequest(async (request, response) => {
//   await firestore().collectionGroup('Users').where('uid', '==', 'BmL4e65bskcjbXGluilmWgGM8942').limit(1).get().then((snapshot) => {
//     console.log(snapshot.docs[0].data().);
//   })
// });
