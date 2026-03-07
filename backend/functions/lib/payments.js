"use strict";
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPaymentIntent = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
const stripe = new stripe_1.default(((_a = functions.config().stripe) === null || _a === void 0 ? void 0 : _a.secret_key) || 'sk_test_YOUR_STRIPE_SECRET_KEY_HERE', {
    apiVersion: '2023-10-16',
});
const db = admin.firestore();
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    // 1. Auth Check
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
    }
    const { amount, currency, restaurantId } = data;
    const userId = context.auth.uid;
    if (!amount || !currency) {
        throw new functions.https.HttpsError('invalid-argument', 'Amount and currency are required');
    }
    try {
        // 2. Create Payment Intent
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100),
            currency: currency,
            automatic_payment_methods: { enabled: true },
            metadata: {
                user_id: userId,
                restaurant_id: restaurantId || 'unknown',
            },
        });
        // 3. Create Pending Order in Firestore
        // We create it now so we have an ID to track, but status is PENDING_PAYMENT
        const orderRef = await db.collection('orders').add({
            user_id: userId,
            restaurant_id: restaurantId,
            amount: amount,
            currency: currency,
            status: 'PENDING_PAYMENT',
            payment_intent_id: paymentIntent.id,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Update intent with order ID for webhook tracking
        await stripe.paymentIntents.update(paymentIntent.id, {
            metadata: { order_id: orderRef.id }
        });
        return {
            clientSecret: paymentIntent.client_secret,
            orderId: orderRef.id,
        };
    }
    catch (error) {
        console.error('Stripe Error:', error);
        throw new functions.https.HttpsError('internal', 'Unable to create payment intent');
    }
});
//# sourceMappingURL=payments.js.map