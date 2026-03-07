"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.acceptOrder = void 0;
const admin = require("firebase-admin");
const functions = require("firebase-functions");
// Note: Ensure @google-cloud/redis is installed for caching if needed
// import { createClient } from 'redis';
admin.initializeApp();
const db = admin.firestore();
/**
 * Attempt to assign an order to a courier using a Transaction.
 * This guarantees that even if 50 couriers click "Accept" at the exact same millisecond,
 * only ONE will succeed. The others will receive a "Too Late" error.
 */
exports.acceptOrder = functions.https.onCall(async (data, context) => {
    // 1. Security Check
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
    }
    const courierId = context.auth.uid;
    const orderId = data.orderId;
    if (!orderId) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing orderId.');
    }
    const orderRef = db.collection('orders').doc(orderId);
    // 2. The Critical Section (Firestore Transaction)
    try {
        const result = await db.runTransaction(async (transaction) => {
            const orderDoc = await transaction.get(orderRef);
            if (!orderDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'Order does not exist.');
            }
            const orderData = orderDoc.data();
            // 3. Validation: Is it still pending?
            if ((orderData === null || orderData === void 0 ? void 0 : orderData.status) !== 'PENDING' && (orderData === null || orderData === void 0 ? void 0 : orderData.status) !== 'BROADCASTING') {
                // Return a specific flag so the UI can show "Taken by another courier"
                throw new Error('ORDER_ALREADY_TAKEN');
            }
            // 4. State Mutation
            // Assign to this courier and change status to LOCKED/ASSIGNED immediately
            transaction.update(orderRef, {
                status: 'ASSIGNED',
                courier_id: courierId,
                accepted_at: admin.firestore.FieldValue.serverTimestamp(),
                // Optimistic locking version increment if needed, but tx handles it
            });
            return { success: true, message: 'Order assigned successfully.' };
        });
        // 5. Post-Transaction Side Effects (can be async/detached)
        console.log(`Order ${orderId} assigned to ${courierId}`);
        // await notifyRestaurant(orderId); 
        return result;
    }
    catch (error) {
        console.warn(`Concurrency conflict for order ${orderId}: ${error.message}`);
        if (error.message === 'ORDER_ALREADY_TAKEN') {
            return {
                success: false,
                code: 'ALREADY_TAKEN',
                message: 'This order was just accepted by another courier.'
            };
        }
        // Retry logic is generally NOT needed for "First come first serve", 
        // we just fail if the doc changed under us.
        throw new functions.https.HttpsError('aborted', 'Could not assign order.');
    }
});
//# sourceMappingURL=concurrency_controller.js.map