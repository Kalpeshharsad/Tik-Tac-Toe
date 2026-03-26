const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Listens for new documents in the 'notifications' collection and sends
 * an FCM push notification to the target user.
 */
exports.sendInviteNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreated(async (snapshot, context) => {
      const data = snapshot.data();
      const targetUserId = data.to;
      const fromUsername = data.from;

      if (!targetUserId) {
        console.error("No target user ID provided in notification document");
        return null;
      }

      try {
        // 1. Get the target user's FCM token from the 'users' collection
        const userDoc = await admin.firestore().collection("users").doc(targetUserId).get();
        if (!userDoc.exists) {
          console.error(`User ${targetUserId} not found in 'users' collection`);
          return null;
        }

        const fcmToken = userDoc.data().fcmToken;
        if (!fcmToken) {
          console.error(`No FCM token found for user ${targetUserId}`);
          return null;
        }

        // 2. Construct the message
        const message = {
          token: fcmToken,
          notification: {
            title: "Game Invite! 🎮",
            body: `${fromUsername} has invited you to a Tic-Tac-Toe match.`,
          },
          data: {
            type: "invite",
            from: fromUsername,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                contentAvailable: true,
                badge: 1,
                sound: "default",
              },
            },
          },
        };

        // 3. Send the message
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);

        // 4. Optionally delete the notification document once handled
        // await snapshot.ref.delete();
        
        return response;
      } catch (error) {
        console.error("Error sending push notification:", error);
        return null;
      }
    });
