import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * FCM Notification Service
 * 
 * Centralized notification logic for all user types:
 * - Customers: Order updates
 * - Couriers: New offers, timer warnings
 * - Restaurants: New orders
 */

// Triggered when order status changes
export const onOrderStatusChange = functions.firestore
    .document('orders/{orderId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        const orderId = context.params.orderId;

        if (before.status === after.status) return; // No status change

        console.log(`📋 Order ${orderId} status: ${before.status} → ${after.status}`);

        // Get customer FCM token
        const customerDoc = await db.collection('users').doc(after.customer_id).get();
        const customerToken = customerDoc.data()?.fcm_token;

        switch (after.status) {
            case 'CONFIRMED':
                await sendNotification(customerToken, {
                    title: '✅ Commande confirmée',
                    body: 'Votre commande est en préparation !',
                    data: { order_id: orderId, screen: 'tracking' },
                });
                break;

            case 'ASSIGNED':
                await sendNotification(customerToken, {
                    title: '🚴 Livreur assigné',
                    body: `${after.courier_name || 'Un livreur'} arrive bientôt !`,
                    data: { order_id: orderId, screen: 'tracking' },
                });
                break;

            case 'PICKED_UP':
                await sendNotification(customerToken, {
                    title: '📦 Commande récupérée',
                    body: 'Votre commande est en route !',
                    data: { order_id: orderId, screen: 'tracking' },
                });
                break;

            case 'DELIVERED':
                await sendNotification(customerToken, {
                    title: '🎉 Livraison effectuée',
                    body: 'Bon appétit ! N\'oubliez pas de noter votre livreur.',
                    data: { order_id: orderId, screen: 'rating' },
                });
                break;
        }
    });

// Send offer notification to courier
export const notifyCourier = functions.firestore
    .document('users/{courierId}/offers/{offerId}')
    .onCreate(async (snap, context) => {
        const courierId = context.params.courierId;
        const offer = snap.data();

        const courierDoc = await db.collection('users').doc(courierId).get();
        const courierToken = courierDoc.data()?.fcm_token;

        if (!courierToken) {
            console.warn(`⚠️ Courier ${courierId} has no FCM token`);
            return;
        }

        // High priority for time-sensitive offers
        await messaging.send({
            token: courierToken,
            notification: {
                title: '🔔 Nouvelle course disponible !',
                body: `${offer.earnings?.toFixed(2) || '?'} € • Expire dans 30s`,
            },
            data: {
                order_id: offer.orderId,
                type: 'new_offer',
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'offers',
                    sound: 'offer_alert.mp3',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'offer_alert.aiff',
                        badge: 1,
                    },
                },
            },
        });

        console.log(`📲 Offer notification sent to courier: ${courierId}`);
    });

// Helper function
async function sendNotification(
    token: string | undefined,
    payload: { title: string; body: string; data?: Record<string, string> }
) {
    if (!token) {
        console.warn('⚠️ No FCM token provided');
        return;
    }

    try {
        await messaging.send({
            token,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data,
            android: {
                priority: 'high',
            },
        });
        console.log(`✅ Notification sent: ${payload.title}`);
    } catch (error: any) {
        // Handle invalid tokens (user uninstalled app, etc)
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
            console.warn('⚠️ Invalid token, should be removed from DB');
        } else {
            console.error('❌ FCM send error:', error);
        }
    }
}
