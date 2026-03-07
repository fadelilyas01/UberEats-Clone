"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.detectGpsAnomaly = exports.verifyDeviceOnLogin = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const db = admin.firestore();
/**
 * Device Fingerprinting Security Module
 *
 * Prevents fraud through:
 * 1. Multi-account detection (same device, multiple accounts)
 * 2. Promo abuse prevention
 * 3. GPS spoofing detection (anomaly in location patterns)
 */
exports.verifyDeviceOnLogin = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
    }
    const uid = context.auth.uid;
    const deviceInfo = data.deviceInfo;
    if (!deviceInfo || !deviceInfo.device_id) {
        throw new functions.https.HttpsError('invalid-argument', 'Device info required');
    }
    // 1. Generate device fingerprint hash
    const fingerprint = generateFingerprint(deviceInfo);
    // 2. Check if this device is associated with other accounts
    const existingDevices = await db.collection('device_fingerprints')
        .where('fingerprint', '==', fingerprint)
        .get();
    const associatedAccounts = existingDevices.docs
        .map(doc => doc.data().user_id)
        .filter(id => id !== uid);
    if (associatedAccounts.length > 0) {
        console.warn(`⚠️ Device ${fingerprint} linked to multiple accounts: ${associatedAccounts.join(', ')}`);
        // Flag user for review if too many accounts
        if (associatedAccounts.length >= 2) {
            await db.collection('users').doc(uid).update({
                'security.multi_account_flag': true,
                'security.flagged_at': admin.firestore.FieldValue.serverTimestamp(),
            });
            // Don't block, but restrict promos
            return {
                allowed: true,
                promo_eligible: false,
                reason: 'Device associated with multiple accounts',
            };
        }
    }
    // 3. Register this device for the user
    await db.collection('device_fingerprints').add({
        user_id: uid,
        fingerprint: fingerprint,
        device_info: deviceInfo,
        first_seen: admin.firestore.FieldValue.serverTimestamp(),
        last_seen: admin.firestore.FieldValue.serverTimestamp(),
    });
    // 4. Update user's known devices
    await db.collection('users').doc(uid).update({
        'security.last_device_fingerprint': fingerprint,
        'security.last_login_device': deviceInfo.model,
        'security.last_login_at': admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`✅ Device verified for user ${uid}: ${fingerprint}`);
    return {
        allowed: true,
        promo_eligible: true,
    };
});
/**
 * GPS Anomaly Detection
 *
 * Detects:
 * - Impossible travel (too fast between locations)
 * - Mock locations / GPS spoofing
 * - Jumpy coordinates
 */
exports.detectGpsAnomaly = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
    }
    const uid = context.auth.uid;
    const { lat, lng, accuracy, isMocked, timestamp } = data;
    // 1. Check if location is mocked (Android only)
    if (isMocked === true) {
        console.warn(`🚨 Mock location detected for user ${uid}`);
        await flagUser(uid, 'mock_location_detected');
        return { valid: false, reason: 'Mock location detected' };
    }
    // 2. Check location history for impossible travel
    const lastLocationDoc = await db.collection('users').doc(uid)
        .collection('location_history')
        .orderBy('timestamp', 'desc')
        .limit(1)
        .get();
    if (!lastLocationDoc.empty) {
        const lastLoc = lastLocationDoc.docs[0].data();
        const timeDiff = (timestamp - lastLoc.timestamp) / 1000; // seconds
        const distance = haversineDistance(lastLoc.lat, lastLoc.lng, lat, lng);
        const speed = distance / timeDiff; // km/s
        // Max realistic speed: 50 km/s (teleportation threshold)
        // Normal car: ~0.03 km/s (100 km/h)
        if (speed > 0.05 && timeDiff < 60) { // More than 180 km/h for short period
            console.warn(`🚨 Impossible travel detected for user ${uid}: ${speed * 3600} km/h`);
            await flagUser(uid, 'impossible_travel');
            return { valid: false, reason: 'Suspicious location change' };
        }
    }
    // 3. Store location for future checks
    await db.collection('users').doc(uid)
        .collection('location_history')
        .add({
        lat, lng, accuracy, timestamp,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { valid: true };
});
// Helper Functions
function generateFingerprint(deviceInfo) {
    const raw = `${deviceInfo.platform}-${deviceInfo.device_id}-${deviceInfo.model}`;
    return crypto.createHash('sha256').update(raw).digest('hex').slice(0, 32);
}
async function flagUser(uid, reason) {
    await db.collection('users').doc(uid).update({
        'security.flagged': true,
        'security.flag_reason': reason,
        'security.flagged_at': admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection('audit_logs').add({
        action: 'security_flag',
        user_id: uid,
        reason: reason,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
}
function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
//# sourceMappingURL=security.js.map