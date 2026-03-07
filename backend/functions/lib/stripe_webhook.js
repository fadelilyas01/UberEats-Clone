"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhook = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const db = admin.firestore();
/**
 * Stripe Webhook Handler
 *
 * Listens for payment events from Stripe and updates the order accordingly.
 * This is the critical link between payment confirmation and order dispatch.
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
    // 1. Verify Stripe Signature
    const signature = req.headers['stripe-signature'];
    // const endpointSecret = functions.config().stripe?.webhook_secret || 'whsec_test';
    if (!signature) {
        console.error('❌ Missing Stripe signature');
        res.status(400).send('Missing signature');
        return;
    }
    // In production: Use stripe.webhooks.constructEvent(req.rawBody, signature, endpointSecret)
    // For now, we parse directly
    let event;
    try {
        event = req.body;
    }
    catch (err) {
        console.error('❌ Webhook parsing failed:', err);
        res.status(400).send('Invalid payload');
        return;
    }
    console.log(`📨 Received Stripe event: ${event.type}`);
    // 2. Handle Events
    switch (event.type) {
        case 'payment_intent.succeeded':
            await handlePaymentSuccess(event.data.object);
            break;
        case 'payment_intent.payment_failed':
            await handlePaymentFailure(event.data.object);
            break;
        case 'charge.refunded':
            await handleRefund(event.data.object);
            break;
        default:
            console.log(`ℹ️ Unhandled event type: ${event.type}`);
    }
    res.status(200).json({ received: true });
});
async function handlePaymentSuccess(paymentIntent) {
    var _a;
    const { order_id, user_id, restaurant_id } = paymentIntent.metadata;
    if (!order_id) {
        console.error('❌ Missing order_id in payment metadata');
        return;
    }
    console.log(`✅ Payment successful for order: ${order_id}`);
    const orderRef = db.collection('orders').doc(order_id);
    // Update order to CONFIRMED (This will trigger dispatchOrder via Firestore trigger)
    await orderRef.update({
        status: 'CONFIRMED',
        payment_status: 'paid',
        stripe_payment_id: paymentIntent.id,
        paid_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Log for audit
    await db.collection('audit_logs').add({
        action: 'payment_confirmed',
        order_id: order_id,
        user_id: user_id,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Notify restaurant (FCM)
    const restaurantDoc = await db.collection('restaurants').doc(restaurant_id).get();
    const fcmToken = (_a = restaurantDoc.data()) === null || _a === void 0 ? void 0 : _a.fcm_token;
    if (fcmToken) {
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: '🔔 Nouvelle commande !',
                body: `Commande #${order_id.slice(-6)} - ${(paymentIntent.amount / 100).toFixed(2)} €`,
            },
            data: {
                order_id: order_id,
                type: 'new_order',
            },
        });
        console.log(`📲 FCM sent to restaurant: ${restaurant_id}`);
    }
}
async function handlePaymentFailure(paymentIntent) {
    const { order_id } = paymentIntent.metadata;
    if (!order_id)
        return;
    console.warn(`❌ Payment failed for order: ${order_id}`);
    await db.collection('orders').doc(order_id).update({
        status: 'PAYMENT_FAILED',
        payment_status: 'failed',
    });
}
async function handleRefund(chargeObject) {
    // Simplified refund handling
    console.log(`💸 Refund processed: ${chargeObject.id}`);
    await db.collection('audit_logs').add({
        action: 'refund_processed',
        stripe_charge_id: chargeObject.id,
        amount: chargeObject.amount,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
}
//# sourceMappingURL=stripe_webhook.js.map