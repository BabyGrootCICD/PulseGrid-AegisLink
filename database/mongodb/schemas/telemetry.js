const mongoose = require('mongoose');

const telemetryLogSchema = new mongoose.Schema({
  deviceId: {
    type: String,
    required: true,
    index: true
  },
  metric: {
    type: String,
    required: true,
    enum: ['temperature', 'vibration', 'battery', 'usage', 'error']
  },
  value: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    default: ''
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: false,
  collection: 'telemetry_logs'
});

// Compound index for efficient queries
telemetryLogSchema.index({ deviceId: 1, metric: 1, timestamp: -1 });
telemetryLogSchema.index({ timestamp: 1 }, { expireAfterSeconds: 7776000 }); // 90 days TTL

// Static method to get latest telemetry for a device
telemetryLogSchema.statics.getLatestByDevice = function(deviceId, metric) {
  return this.findOne({ deviceId, metric })
    .sort({ timestamp: -1 })
    .lean();
};

// Static method to get telemetry in time range
telemetryLogSchema.statics.getInTimeRange = function(deviceId, metric, startDate, endDate) {
  return this.find({
    deviceId,
    metric,
    timestamp: { $gte: startDate, $lte: endDate }
  }).sort({ timestamp: 1 }).lean();
};

const TelemetryLog = mongoose.model('TelemetryLog', telemetryLogSchema);

module.exports = TelemetryLog;
