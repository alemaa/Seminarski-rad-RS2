class Payment {
  final int? id;
  final String? method;
  final String? status;
  final int? orderId;

  Payment({this.id, this.method, this.status, this.orderId});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      method: json['method'],
      status: json['status'],
      orderId: json['orderId'],
    );
  }
}
