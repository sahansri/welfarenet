class StarClaimRequest {
  final int requestId;
  final int memberId;
  final String memberName;
  final int claimTypeId;
  final String reward;
  final int starsRequired;
  final double rewardValue;
  final int starsDeducted;
  final String status;
  final String appliedAt;
  final String? processedAt;
  final String? processedBy;
  final String? adminMessage;

  StarClaimRequest({
    required this.requestId,
    required this.memberId,
    required this.memberName,
    required this.claimTypeId,
    required this.reward,
    required this.starsRequired,
    required this.rewardValue,
    required this.starsDeducted,
    required this.status,
    required this.appliedAt,
    this.processedAt,
    this.processedBy,
    this.adminMessage,
  });

  factory StarClaimRequest.fromJson(Map<String, dynamic> json) {
    return StarClaimRequest(
      requestId: json['requestId'] as int,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      claimTypeId: json['claimTypeId'] as int,
      reward: json['reward'] as String,
      starsRequired: json['starsRequired'] as int,
      rewardValue: (json['rewardValue'] as num).toDouble(),
      starsDeducted: json['starsDeducted'] as int,
      status: json['status'] as String,
      appliedAt: json['appliedAt'] as String,
      processedAt: json['processedAt'] as String?,
      processedBy: json['processedBy'] as String?,
      adminMessage: json['adminMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'memberId': memberId,
      'memberName': memberName,
      'claimTypeId': claimTypeId,
      'reward': reward,
      'starsRequired': starsRequired,
      'rewardValue': rewardValue,
      'starsDeducted': starsDeducted,
      'status': status,
      'appliedAt': appliedAt,
      'processedAt': processedAt,
      'processedBy': processedBy,
      'adminMessage': adminMessage,
    };
  }
}
