importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDhzr85jPExzZs3cpyF9R-xA_h0f783zmA",
    authDomain: "ditokokuid-a2ff4.firebaseapp.com",
    projectId: "ditokokuid-a2ff4",
    storageBucket: "ditokokuid-a2ff4.firebasestorage.app",
    messagingSenderId: "268802509862",
    appId: "1:268802509862:web:8e688673b4b3ff61adaae7",
    measurementId: "G-EHQ1MQ0QNR"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});