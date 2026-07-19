const mongoose = require('mongoose');

const moderationTagSchema = new mongoose.Schema({
  contentType: {
    type: String,
    required: true,
    enum: ['video', 'image', 'text', 'audio'],
    index: true
  },
  contentId: {
    type: String,
    required: true,
    index: true
  },
  tag: {
    type: String,
    required: true,
    enum: [
      'safe',
      'explicit',
      'violence',
      'nudity',
      'hate_speech',
      'harassment',
      'spam',
      'illegal',
      'minor_present',
      'drug_reference',
      'self_harm',
      'other'
    ],
    index: true
  },
  confidence: {
    type: Number,
    required: true,
    min: 0,
    max: 1
  },
  source: {
    type: String,
    enum: ['ai_auto', 'ai_assisted', 'user_report', 'moderator'],
    required: true
  },
  reviewedBy: {
    type: String,
    default: null
  },
  reviewedAt: {
    type: Date,
    default: null
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'escalated'],
    default: 'pending',
    index: true
  },
  notes: {
    type: String,
    default: ''
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
  timestamps: true,
  collection: 'moderation_tags'
});

// Compound indexes
moderationTagSchema.index({ contentType: 1, contentId: 1 });
moderationTagSchema.index({ status: 1, tag: 1 });
moderationTagSchema.index({ reviewedBy: 1, reviewedAt: -1 });

// Static method to get pending reviews
moderationTagSchema.statics.getPendingReviews = function(limit = 100) {
  return this.find({ status: 'pending' })
    .sort({ confidence: -1, timestamp: 1 })
    .limit(limit)
    .lean();
};

// Static method to get content by tag
moderationTagSchema.statics.getByTag = function(tag, status = 'approved') {
  return this.find({ tag, status })
    .sort({ timestamp: -1 })
    .lean();
};

// Static method to flag content
moderationTagSchema.statics.flagContent = function(contentType, contentId, tag, confidence, source) {
  return this.findOneAndUpdate(
    {
      contentType,
      contentId,
      tag
    },
    {
      $set: {
        confidence,
        source,
        status: 'pending',
        reviewedBy: null,
        reviewedAt: null
      },
      $inc: { 'metadata.flagCount': 1 }
    },
    {
      upsert: true,
      new: true
    }
  );
};

const ModerationTag = mongoose.model('ModerationTag', moderationTagSchema);

module.exports = ModerationTag;
