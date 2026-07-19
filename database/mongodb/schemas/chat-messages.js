const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
  roomId: {
    type: String,
    required: true,
    index: true
  },
  senderId: {
    type: String,
    required: true,
    index: true
  },
  content: {
    type: String,
    required: true
  },
  encrypted: {
    type: Boolean,
    default: false
  },
  encryptionKeyVersion: {
    type: Number,
    default: 1
  },
  type: {
    type: String,
    enum: ['text', 'image', 'system', 'tip'],
    default: 'text'
  },
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: false,
  collection: 'chat_messages'
});

// Compound indexes
chatMessageSchema.index({ roomId: 1, timestamp: -1 });
chatMessageSchema.index({ senderId: 1, timestamp: -1 });

// TTL index - auto-delete messages after 30 days (configurable per room)
chatMessageSchema.index({ timestamp: 1 }, { expireAfterSeconds: 2592000 });

// Static method to get messages for a room
chatMessageSchema.statics.getRoomMessages = function(roomId, limit = 50, before = null) {
  const query = { roomId };
  if (before) {
    query.timestamp = { $lt: before };
  }
  return this.find(query)
    .sort({ timestamp: -1 })
    .limit(limit)
    .lean();
};

// Static method to get unread count
chatMessageSchema.statics.getUnreadCount = function(roomId, afterTimestamp) {
  return this.countDocuments({
    roomId,
    timestamp: { $gt: afterTimestamp }
  });
};

const ChatMessage = mongoose.model('ChatMessage', chatMessageSchema);

module.exports = ChatMessage;
