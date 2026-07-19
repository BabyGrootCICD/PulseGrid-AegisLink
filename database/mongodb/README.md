# MongoDB Schemas (Mongoose)

## Overview

This directory contains Mongoose schemas for MongoDB collections used in the PulseGrid-AegisLink (AuraSync) platform.

## Structure

```
database/mongodb/
├── schemas/
│   ├── telemetry.js        # IoT device telemetry logs
│   ├── chat-messages.js    # Room chat messages
│   └── moderation.js       # Content moderation tags
└── README.md
```

## Collections

### telemetry_logs

High-frequency IoT device telemetry data with TTL indexing.

**Schema:**
```javascript
{
  deviceId: String,      // Device identifier
  metric: String,        // temperature, vibration, battery, usage, error
  value: Number,         // Metric value
  unit: String,          // Optional unit
  timestamp: Date,       // When recorded
  metadata: Map          // Additional data
}
```

**Indexes:**
- `{ deviceId: 1, metric: 1, timestamp: -1 }` - Device metric queries
- `{ timestamp: 1 }` - TTL index (90 days)

**Methods:**
- `getLatestByDevice(deviceId, metric)` - Get latest value
- `getInTimeRange(deviceId, metric, start, end)` - Time range queries

### chat_messages

Room chat messages with encryption support.

**Schema:**
```javascript
{
  roomId: String,        // Room identifier
  senderId: String,      // Sender user ID
  content: String,       // Message content (encrypted if E2EE)
  encrypted: Boolean,    // Whether content is encrypted
  type: String,          // text, image, system, tip
  timestamp: Date        // When sent
}
```

**Indexes:**
- `{ roomId: 1, timestamp: -1 }` - Room message history
- `{ senderId: 1, timestamp: -1 }` - User message history
- `{ timestamp: 1 }` - TTL index (30 days)

**Methods:**
- `getRoomMessages(roomId, limit, before)` - Get messages with pagination
- `getUnreadCount(roomId, afterTimestamp)` - Get unread count

### moderation_tags

Content moderation tags with review workflow.

**Schema:**
```javascript
{
  contentType: String,   // video, image, text, audio
  contentId: String,     // Content identifier
  tag: String,           // safe, explicit, violence, nudity, etc.
  confidence: Number,    // 0-1 confidence score
  source: String,        // ai_auto, ai_assisted, user_report, moderator
  reviewedBy: String,    // Moderator user ID
  reviewedAt: Date,      // When reviewed
  status: String,        // pending, approved, rejected, escalated
  notes: String          // Review notes
}
```

**Indexes:**
- `{ contentType: 1, contentId: 1 }` - Content lookup
- `{ status: 1, tag: 1 }` - Review queue
- `{ reviewedBy: 1, reviewedAt: -1 }` - Moderator activity

**Methods:**
- `getPendingReviews(limit)` - Get pending moderation queue
- `getByTag(tag, status)` - Get content by moderation tag
- `flagContent(type, id, tag, confidence, source)` - Flag content for review

## Usage

### Connecting

```javascript
const mongoose = require('mongoose');

await mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});
```

### Querying

```javascript
const TelemetryLog = require('./schemas/telemetry');

// Get latest temperature reading
const latest = await TelemetryLog.getLatestByDevice('device-123', 'temperature');

// Get chat messages for a room
const ChatMessage = require('./schemas/chat-messages');
const messages = await ChatMessage.getRoomMessages('room-456', 50);

// Get pending moderation reviews
const ModerationTag = require('./schemas/moderation');
const pending = await ModerationTag.getPendingReviews(100);
```

## Environment Variables

```env
MONGODB_URI=mongodb://aurasync:aurasync_dev@localhost:27017/aurasync
MONGODB_DB=aurasync
```
