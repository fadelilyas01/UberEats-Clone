import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize if not already initialized (in index.ts usually, but good for standalone generic usage)
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();

/**
 * SMART DISPATCH SYSTEM (Core "Brain")
 * 
 * Triggered when a new order is placed (status: PENDING).
 * 1. Calculates travel times (Simulating Google Matrix API).
 * 2. Scores couriers based on Proximity, Rating, and "Silent Auction" status.
 * 3. Creates "Assignment Offers" for the top 3 couriers.
 */
export const dispatchOrder = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snap, context) => {
        const order = snap.data();
        const orderId = context.params.orderId;

        if (!order.pickup_geo || !order.dropoff_geo) {
            console.error(`Order ${orderId} missing geo data`);
            return;
        }

        console.log(`🧠 Smart Dispatch analysis started for Order: ${orderId}`);

        // 1. Find Active Couriers (Simulated Geo-Query)
        // In production, use GeoFlutterFire or Algolia Geo-Search
        const couriersSnapshot = await db.collection('users')
            .where('role', '==', 'courier')
            .where('courier_meta.status', '==', 'online')
            .limit(20)
            .get();

        const candidates: any[] = [];

        // 2. The "Silent Auction" & Scoring Algorithm
        for (const doc of couriersSnapshot.docs) {
            const courier = doc.data();
            const courierGeo = courier.courier_meta.current_location;

            if (!courierGeo) continue;

            // A. Distance Calculation (Manhattan vs Real Haversine for MVP)
            const distanceKm = calculateHaversine(
                order.pickup_geo.lat, order.pickup_geo.lng,
                courierGeo.lat, courierGeo.lng
            );

            // Filter: Must be within 5km
            if (distanceKm > 5.0) continue;

            // B. Score Calculation
            // Lower score = Better (like Golf). Score = Distance / Rating^Alpha
            // Rating 5.0 reduces effective distance more than Rating 4.0
            const rating = courier.courier_meta.score || 4.5;
            const activeJobs = courier.courier_meta.active_jobs_count || 0;

            // "Batching" Logic: If courier has 1 job closely aligned, they are ELIGIBLE but with penalty
            // If > 1 job, they are excluded (unless "Super Courier")
            if (activeJobs > 1) continue;

            let score = distanceKm * 100; // Base: 100 points per km
            score = score / (rating / 4.0); // Better rating = Lower score (priority)

            // Silent Auction / Priority Boost
            if (courier.courier_meta.is_gold_tier) {
                score = score * 0.85; // 15% advantage
            }

            candidates.push({
                courierId: doc.id,
                score: score,
                distance: distanceKm,
                token: courier.fcm_token
            });
        }

        // 3. Sort by Best Score (Lowest)
        candidates.sort((a, b) => a.score - b.score);

        // 4. Select Top 3 Candidates
        const topCandidates = candidates.slice(0, 3);
        console.log(`🎯 Found ${topCandidates.length} potential couriers from ${candidates.length} candidates.`);

        // 5. Send Offers (Idempotent Notification)
        const batch = db.batch();

        for (const candidate of topCandidates) {
            // Create an Offer document
            // This allows the Courier App to listen to `users/{uid}/offers`
            const offerRef = db.collection('users')
                .doc(candidate.courierId)
                .collection('offers')
                .doc(orderId);

            batch.set(offerRef, {
                orderId: orderId,
                score: candidate.score,
                offered_at: admin.firestore.FieldValue.serverTimestamp(),
                expires_at: admin.firestore.Timestamp.fromMillis(Date.now() + 30000), // 30s expiry
                status: 'pending' // pending | accepted | rejected | missed
            });
        }

        // 6. Update Order State
        batch.update(snap.ref, {
            status: 'BROADCASTING',
            broadcasting_to_count: topCandidates.length,
            algorithm_version: 'v2_smart_matrix'
        });

        await batch.commit();
        console.log(`✅ Offers dispatched to: ${topCandidates.map(c => c.courierId).join(', ')}`);
    });

/**
 * Helper: Haversine Formula for generic distance
 */
function calculateHaversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Radius of the earth in km
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

function deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
}
