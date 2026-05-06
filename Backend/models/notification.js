const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema(
  {
    orderId: { type: String, required: true, index: true },
    customerEmail: { type: String, required: true, lowercase: true, trim: true, index: true },
    title: { type: String, required: true, trim: true },
    message: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: ['Pending', 'Preparing', 'Ready', 'Completed', 'Rejected'],
      required: true,
    },
    items: { type: [String], default: [] },
    read: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Notification', NotificationSchema);
