const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Cloud Function to send push notifications
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be logged in to send notifications');
  }

  // Get user role from Firestore
  const userId = context.auth.uid;
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const userData = userDoc.data();
  const userRole = userData?.role || 'user';

  // Only coaches and admins can send notifications
  if (userRole !== 'coach' && userRole !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only coaches can send notifications');
  }

  // Get notification data
  const { token, title, body, type } = data;

  if (!token || !title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: token, title, or body');
  }

  // Build the message
  const message = {
    token: token,
    notification: {
      title: title,
      body: body,
    },
    data: {
      type: type || 'general',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
        },
      },
    },
  };

  try {
    // Send the notification
    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent successfully:', response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Optional: Test function to verify setup
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});