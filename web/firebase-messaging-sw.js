// Import and configure Firebase
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker
const firebaseConfig = {
  apiKey: "AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc",
  authDomain: "rfid-locker-system-85ecc.firebaseapp.com",
  projectId: "rfid-locker-system-85ecc",
  storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
  messagingSenderId: "610520452603",
  appId: "1:610520452603:web:95f7b9a9b4e97c33c9cf5e"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Background message handler (triggered when app is in background)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'New notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
    // Add any additional options here
  };

  // Show the notification
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
  console.log('Notification clicked: ', event);
  
  // Close the notification popup
  event.notification.close();
  
  // Get the URL from the notification data or use a default
  const urlToOpen = event.notification.data?.url || '/';
  
  // Open the app or a specific URL when the notification is clicked
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((windowClients) => {
      // Check if there's already a window/tab open with the target URL
      for (const client of windowClients) {
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      
      // If no window/tab is found, open a new one
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
      
      return null;
    })
  );
});

// Handle push subscription
self.addEventListener('pushsubscriptionchange', (event) => {
  console.log('Push subscription changed: ', event);
  
  // This event is triggered when the push subscription is updated
  event.waitUntil(
    Promise.resolve()
      .then(() => {
        // You can add logic here to update the subscription on your server
        console.log('Push subscription changed, update the server if needed');
      })
      .catch((error) => {
        console.error('Error handling push subscription change: ', error);
      })
  );
});

// Handle install event
self.addEventListener('install', (event) => {
  console.log('Service Worker installing.');
  // Skip waiting to activate the new service worker immediately
  self.skipWaiting();
});

// Handle activate event
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating.');
  // Take control of all pages under this service worker's scope immediately
  event.waitUntil(clients.claim());
});
