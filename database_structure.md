# Firestore Database Structure for RFID-BASED SMART SECURITY BOX MANAGEMENT SYSTEM FOR RAPIDKL

This document describes the Firestore collections and fields used in the project. Use this as a reference for setting up your Firestore database.

---

## 1. users (Collection)
- **Document ID:** User UID
- **Fields:**
  - `id` (string): Same as UID (redundancy for queries)
  - `role` (string): 'user' or 'admin'
  - `status` (string): 'pending', 'active', 'rejected'
  - `rfidUid` (string): RFID card UID assigned to user
  - `name` (string): Full name
  - `email` (string): Email address

---

## 2. lockers (Collection)
- **Document ID:** Locker UID
- **Fields:**
  - `id` (string): Locker UID
  - `status` (string): 'available', 'occupied', 'maintenance', 'offline'
  - `location` (string): Physical location/description
  - `name` (string): Locker label/name

---

## 3. lockerAssignments (Collection)
- **Document ID:** Assignment ID (auto or custom)
- **Fields:**
  - `id` (string): Assignment ID
  - `lockerId` (string): Locker document ID
  - `userId` (string): User document ID
  - `rfidUid` (string): Assigned RFID UID
  - `expiresAt` (timestamp): Expiry date/time
  - `status` (string): 'active', 'expired'

---

## 4. access_logs (Collection)
- **Document ID:** Auto-generated
- **Fields:**
  - `userId` (string): User document ID
  - `lockerId` (string): Locker document ID
  - `timestamp` (timestamp): When access was attempted
  - `result` (string): 'allowed', 'denied'
  - `action` (string): e.g., 'Locker Access'
  - `rfidUid` (string): RFID UID used
  - `userName` (string): User's name (if available)
  - `reason` (string/null): Reason for denial (if any)

---

## 5. security_events (Collection)
- **Document ID:** Auto-generated
- **Fields:**
  - `eventType` (string): Type of event (e.g., 'forced_open', 'tamper', etc.)
  - `timestamp` (timestamp): When event occurred
  - `details` (string): Additional details

---

## Security Rules
- All collections require authentication.
- Users can only read/write their own user documents.
- Lockers: read for authenticated users, write for admins only.
- Admin role validation for sensitive operations.
