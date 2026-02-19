class StarClaimOffer {
  final int claimTypeId;
  final String reward;
  final int starsRequired;
  final double rewardValue;

  StarClaimOffer({
    required this.claimTypeId,
    required this.reward,
    required this.starsRequired,
    required this.rewardValue,
  });

  factory StarClaimOffer.fromJson(Map<String, dynamic> json) {
    return StarClaimOffer(
      claimTypeId: json['claimTypeId'] as int,
      reward: json['reward'] as String,
      starsRequired: json['starsRequired'] as int,
      rewardValue: (json['rewardValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claimTypeId': claimTypeId,
      'reward': reward,
      'starsRequired': starsRequired,
      'rewardValue': rewardValue,
    };
  }
}
