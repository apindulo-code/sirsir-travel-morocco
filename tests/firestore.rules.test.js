import fs from 'node:fs';
import test, { before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';

const projectId = 'demo-sirsir-travel-morocco';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
    },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
});

after(async () => {
  await env.cleanup();
});

const profile = (uid) => ({
  uid,
  displayName: 'Test User',
  email: 'test@example.com',
  phoneNumber: null,
  preferredLanguage: 'ar',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
});

const booking = (uid) => ({
  userId: uid,
  origin: 'طنجة',
  destination: 'الرباط',
  travelDate: Timestamp.fromDate(new Date('2027-01-10T10:00:00Z')),
  passengerName: 'Test Passenger',
  passengerPhone: '+212600000000',
  providerName: 'Demo provider',
  displayedPrice: 100,
  currency: 'MAD',
  status: 'requested',
  createdAt: serverTimestamp(),
});

test('unauthenticated users cannot read or write private profiles', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/user-a')));
  await assertFails(setDoc(doc(db, 'users/user-a'), profile('user-a')));
});

test('a user can create and read their own profile but not another profile', async () => {
  const db = env.authenticatedContext('user-a').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/user-a'), profile('user-a')));
  await assertSucceeds(getDoc(doc(db, 'users/user-a')));
  await assertFails(getDoc(doc(db, 'users/user-b')));
});

test('users cannot create untracked subcollections under their profile', async () => {
  const db = env.authenticatedContext('user-a').firestore();
  await assertFails(setDoc(
    doc(db, 'users/user-a/private-data/secret'),
    { note: 'This path is not part of the supported user data model' },
  ));
});

test('public travel catalog is readable but never writable from a client', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDocs(collection(db, 'destinations')));
  await assertFails(setDoc(doc(db, 'destinations/new-place'), { name: 'Injected' }));
});

test('a user can create and read their own booking only', async () => {
  const ownerDb = env.authenticatedContext('user-a').firestore();
  const otherDb = env.authenticatedContext('user-b').firestore();
  const created = await assertSucceeds(addDoc(collection(ownerDb, 'bookings'), booking('user-a')));
  await assertSucceeds(getDoc(doc(ownerDb, 'bookings', created.id)));
  await assertFails(getDoc(doc(otherDb, 'bookings', created.id)));
});

test('users cannot create bookings for another account or with invalid prices', async () => {
  const db = env.authenticatedContext('user-a').firestore();
  await assertFails(addDoc(collection(db, 'bookings'), booking('user-b')));
  await assertFails(addDoc(collection(db, 'bookings'), {
    ...booking('user-a'),
    displayedPrice: -1,
  }));
});

test('reviews are private to their author and validated', async () => {
  const ownerDb = env.authenticatedContext('user-a').firestore();
  const otherDb = env.authenticatedContext('user-b').firestore();
  const created = await assertSucceeds(addDoc(collection(ownerDb, 'reviews'), {
    userId: 'user-a',
    subjectId: 'destination-1',
    subjectType: 'destination',
    rating: 5,
    comment: 'Good place',
    createdAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(doc(ownerDb, 'reviews', created.id)));
  await assertFails(getDoc(doc(otherDb, 'reviews', created.id)));
  await assertFails(addDoc(collection(ownerDb, 'reviews'), {
    userId: 'user-a',
    subjectId: 'destination-1',
    subjectType: 'destination',
    rating: 6,
    comment: 'Invalid rating',
    createdAt: serverTimestamp(),
  }));
});


test('profile updates are owner-only and restricted to approved fields', async () => {
  const ownerDb = env.authenticatedContext('user-a').firestore();
  const otherDb = env.authenticatedContext('user-b').firestore();
  const ownerProfile = doc(ownerDb, 'users/user-a');

  await assertSucceeds(setDoc(ownerProfile, profile('user-a')));
  await assertSucceeds(updateDoc(ownerProfile, {
    displayName: 'Updated User',
    updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(doc(otherDb, 'users/user-a'), {
    displayName: 'Unauthorized edit',
    updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(ownerProfile, { uid: 'user-b' }));
});

test('booking cancellation is owner-only and cannot rewrite booking details', async () => {
  const ownerDb = env.authenticatedContext('user-a').firestore();
  const otherDb = env.authenticatedContext('user-b').firestore();
  const created = await assertSucceeds(addDoc(
    collection(ownerDb, 'bookings'),
    booking('user-a'),
  ));
  const ownerBooking = doc(ownerDb, 'bookings', created.id);

  await assertFails(deleteDoc(doc(otherDb, 'bookings', created.id)));
  await assertSucceeds(updateDoc(ownerBooking, {
    status: 'cancelled',
    updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(ownerBooking, {
    destination: 'مراكش',
  }));
});

test('review changes and deletion are restricted to the review owner', async () => {
  const ownerDb = env.authenticatedContext('user-a').firestore();
  const otherDb = env.authenticatedContext('user-b').firestore();
  const created = await assertSucceeds(addDoc(collection(ownerDb, 'reviews'), {
    userId: 'user-a',
    subjectId: 'destination-1',
    subjectType: 'destination',
    rating: 4,
    comment: 'Initial review',
    createdAt: serverTimestamp(),
  }));
  const ownerReview = doc(ownerDb, 'reviews', created.id);

  await assertFails(updateDoc(doc(otherDb, 'reviews', created.id), {
    rating: 1,
    comment: 'Unauthorized edit',
  }));
  await assertSucceeds(updateDoc(ownerReview, {
    rating: 5,
    comment: 'Updated review',
  }));
  await assertFails(updateDoc(ownerReview, { userId: 'user-b' }));
  await assertFails(deleteDoc(doc(otherDb, 'reviews', created.id)));
  await assertSucceeds(deleteDoc(ownerReview));
});
