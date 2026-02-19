class PaymentModel {
  final int paymentId;
  final int userId;
  final String paymentType;
  final String? description;
  final double amount;
  final String status;
  final DateTime paymentDate;
  final DateTime? approvedDate;
  final String? receiptUrl;

  PaymentModel({
    required this.paymentId,
    required this.userId,
    required this.paymentType,
    this.description,
    required this.amount,
    required this.status,
    required this.paymentDate,
    this.approvedDate,
    this.receiptUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId'] ?? 0,
      userId: json['userId'] ?? 0,
      paymentType: json['paymentType'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['paymentStatus'] ?? 'PENDING',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'paymentType': paymentType,
      'description': description,
      'amount': amount,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'receiptUrl': receiptUrl,
    };
  }

  // Helper method to format date
  String getFormattedDate() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${paymentDate.day} ${months[paymentDate.month - 1]} ${paymentDate.year}';
  }

  // Convert to Map for displaying in UI
  Map<String, dynamic> toDisplayMap() {
    return {
      'date': getFormattedDate(),
      'type': paymentType,
      'description': description,
      'amount': amount,
      'status': status,
      'paymentId': paymentId,
      'receiptUrl': receiptUrl,
    };
  }
}
