import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/services/stars_service.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/services/rewards_service.dart';
import 'package:welfarenet_mobile/models/star_claim_offer.dart';
import 'package:welfarenet_mobile/models/star_claim_request.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class LoyaltyRewards extends StatefulWidget {
  const LoyaltyRewards({super.key});

  @override
  State<LoyaltyRewards> createState() => _LoyaltyRewardsState();
}

class _LoyaltyRewardsState extends State<LoyaltyRewards>
    with SingleTickerProviderStateMixin {
  final StarsService _starsService = StarsService();
  final AuthService _authService = AuthService();
  final RewardsService _rewardsService = RewardsService();
  int _currentPoints = 0; // Current Unity Stars points
  bool _isLoadingBalance = true;
  bool _isLoadingOffers = true;
  List<StarClaimOffer> _offers = [];
  int _issuedRewardsCount = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadBalance();
    _loadOffers();
    _loadIssuedRewardsCount();
  }

  Future<void> _loadBalance() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo['success'] == true && userInfo['data'] != null) {
        final memberId = userInfo['data']['memberID'];
        final result = await _starsService.getMemberBalance(memberId);
        if (mounted && result['success'] == true) {
          setState(() {
            _currentPoints = result['balance'] ?? 0;
            _isLoadingBalance = false;
          });
        } else {
          setState(() {
            _isLoadingBalance = false;
          });
        }
      } else {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      print('Error loading balance: $e');
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  Future<void> _loadOffers() async {
    try {
      final result = await _rewardsService.getAllOffers();
      print('Offers load result: $result');
      if (mounted && result['success'] == true) {
        setState(() {
          _offers = result['offers'] ?? [];
          _isLoadingOffers = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingOffers = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load offers'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading offers: $e');
      if (mounted) {
        setState(() {
          _isLoadingOffers = false;
        });
      }
    }
  }

  Future<void> _loadIssuedRewardsCount() async {
    try {
      final result = await _rewardsService.getMemberClaimRequests();
      if (mounted && result['success'] == true) {
        final List<StarClaimRequest> requests = result['requests'] ?? [];
        final issuedCount =
            requests
                .where((req) => req.status.toUpperCase() == 'ISSUED')
                .length;
        setState(() {
          _issuedRewardsCount = issuedCount;
        });
      }
    } catch (e) {
      print('Error loading issued rewards count: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loyalty Rewards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7A5AF8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.white,
            onPressed: () {
              _showHowToEarnPointsDialog();
            },
            tooltip: 'How to Earn Points',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            color: Colors.white,
            onPressed: () {
              _showRedemptionHistory();
            },
            tooltip: 'Redemption History',
          ),
        ],
      ),
      body: Column(
        children: [_buildPointsHeader(), Expanded(child: _buildVoucherList())],
      ),
    );
  }

  Widget _buildPointsHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Hero(
            tag: 'unity_stars',
            child: Image.asset(
              'lib/assets/meteor-rain.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Unity Stars',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _isLoadingBalance
              ? const SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
              : TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: _currentPoints),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
          const SizedBox(height: 8),
          const Text(
            'Points Available',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Redeemed',
                  '$_issuedRewardsCount',
                  Icons.redeem,
                ),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildStatItem(
                  'Available',
                  '${_getAvailableVouchers()}',
                  Icons.card_giftcard,
                ),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildStatItem('Earned', '$_currentPoints', Icons.trending_up),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  int _getAvailableVouchers() {
    return _offers.where((v) => _currentPoints >= v.starsRequired).length;
  }

  // Helper method to get icon and color for offer based on reward type
  Map<String, dynamic> _getOfferDisplay(StarClaimOffer offer) {
    String rewardName = offer.reward.toUpperCase();

    if (rewardName.contains('VOUCHER')) {
      int value = offer.rewardValue.toInt();
      return {
        'icon': Icons.card_giftcard,
        'color':
            value >= 2000
                ? Colors.green
                : (value >= 1000 ? Colors.orange : const Color(0xFF7A5AF8)),
        'title': 'Rs.${value} Gift Voucher',
        'description': 'Redeem for Rs.${value} worth of vouchers',
      };
    } else if (rewardName.contains('PREMIUM')) {
      return {
        'icon': Icons.workspace_premium,
        'color': const Color(0xFFFFD700),
        'title': 'Premium Upgrade',
        'description': 'Upgrade to premium membership',
      };
    } else if (rewardName.contains('EVENT')) {
      return {
        'icon': Icons.event,
        'color': Colors.blue,
        'title': 'Event Access',
        'description': 'Register for events',
      };
    } else {
      return {
        'icon': Icons.redeem,
        'color': const Color(0xFF7A5AF8),
        'title': offer.reward.replaceAll('_', ' '),
        'description': 'Special reward offer',
      };
    }
  }

  Widget _buildVoucherList() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child:
          _isLoadingOffers
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF7A5AF8)),
                ),
              )
              : _offers.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No offers available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new rewards!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Vouchers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_offers.length} items',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._offers.map((offer) => _buildVoucherCard(offer)),
                ],
              ),
    );
  }

  Widget _buildVoucherCard(StarClaimOffer offer) {
    final bool canRedeem = _currentPoints >= offer.starsRequired;
    final int pointsNeeded =
        canRedeem ? 0 : offer.starsRequired - _currentPoints;
    final displayInfo = _getOfferDisplay(offer);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            canRedeem
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (displayInfo['color'] as Color).withValues(alpha: 0.1),
                    (displayInfo['color'] as Color).withValues(alpha: 0.05),
                  ],
                )
                : null,
        border: Border.all(
          color:
              canRedeem
                  ? (displayInfo['color'] as Color).withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
        color: !canRedeem ? Colors.grey.withValues(alpha: 0.05) : null,
        boxShadow:
            canRedeem
                ? [
                  BoxShadow(
                    color: (displayInfo['color'] as Color).withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color:
                            canRedeem
                                ? (displayInfo['color'] as Color).withValues(
                                  alpha: 0.2,
                                )
                                : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:
                            canRedeem
                                ? [
                                  BoxShadow(
                                    color: (displayInfo['color'] as Color)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        displayInfo['icon'] as IconData,
                        size: 40,
                        color:
                            canRedeem
                                ? displayInfo['color'] as Color
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayInfo['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  canRedeem ? Colors.black : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayInfo['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            canRedeem
                                ? displayInfo['color'] as Color
                                : Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.starsRequired} Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!canRedeem)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Need $pointsNeeded more',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Reward value: \Rs.${(offer.rewardValue).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: canRedeem ? () => _redeemOffer(offer) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canRedeem
                                ? const Color(0xFF7A5AF8)
                                : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        elevation: canRedeem ? 4 : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            canRedeem ? 'Redeem' : 'Locked',
                            style: TextStyle(
                              color:
                                  canRedeem ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (canRedeem) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!canRedeem)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, size: 40, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _redeemOffer(StarClaimOffer offer) {
    final displayInfo = _getOfferDisplay(offer);
    if (_currentPoints >= offer.starsRequired) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Confirm Redemption'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Redeem ${displayInfo['title']}?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Points Required: ${offer.starsRequired}'),
                  Text('Your Current Points: $_currentPoints'),
                  Text(
                    'Remaining Points: ${_currentPoints - offer.starsRequired}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Close the confirmation dialog first
                    Navigator.pop(dialogContext);

                    if (!mounted) return;

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (loadingContext) => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7A5AF8),
                            ),
                          ),
                    );

                    try {
                      // Get member ID
                      final userInfo = await _authService.getUserInfo();
                      if (!mounted) return;

                      if (userInfo['success'] == true &&
                          userInfo['data'] != null) {
                        final memberId = userInfo['data']['memberID'];

                        // Call redeem API
                        final result = await _rewardsService.redeemOffer(
                          memberId,
                          offer.claimTypeId,
                        );

                        if (!mounted) return;

                        Navigator.pop(context); // Close loading dialog

                        if (result['success'] == true) {
                          // Reload balance and issued count after successful redemption
                          await _loadBalance();
                          await _loadIssuedRewardsCount();
                          if (!mounted) return;
                          _showSuccessDialog(offer);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Failed to redeem offer',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to get user information'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5AF8),
                  ),
                  child: const Text(
                    'Redeem',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient points! You need ${offer.starsRequired - _currentPoints} more points.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(StarClaimOffer offer) {
    if (!mounted) return;

    final displayInfo = _getOfferDisplay(offer);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber),
                SizedBox(width: 8),
                Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  displayInfo['icon'] as IconData,
                  size: 60,
                  color: displayInfo['color'] as Color,
                ),
                const SizedBox(height: 16),
                Text(
                  'You have successfully requested your redeem:',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  displayInfo['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DEFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You will be notify when your reward is ready to use.',
                    style: TextStyle(color: Colors.grey[800], fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showRedemptionHistory() async {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7A5AF8)),
          ),
    );

    try {
      final result = await _rewardsService.getMemberClaimRequests();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        final List<StarClaimRequest> requests = result['requests'] ?? [];

        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF7A5AF8)),
                    SizedBox(width: 8),
                    Text('Redemption History'),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child:
                      requests.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No redemption history',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your redeemed rewards will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final request = requests.reversed.toList()[index];
                              return _buildHistoryItemFromRequest(request);
                            },
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to load redemption history',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHistoryItemFromRequest(StarClaimRequest request) {
    // Get display info based on reward type
    final displayInfo = _getRewardDisplayInfo(
      request.reward,
      request.rewardValue,
    );
    final statusColor = _getStatusColor(request.status);
    final formattedDate = _formatDate(request.appliedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (displayInfo['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (displayInfo['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (displayInfo['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  displayInfo['icon'] as IconData,
                  color: displayInfo['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayInfo['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: displayInfo['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${request.starsDeducted}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(request.status),
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (request.adminMessage != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.adminMessage!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRewardDisplayInfo(String reward, double value) {
    String rewardName = reward.toUpperCase();

    if (rewardName.contains('VOUCHER')) {
      int intValue = value.toInt();
      return {
        'icon': Icons.card_giftcard,
        'color':
            intValue >= 2000
                ? Colors.green
                : (intValue >= 1000 ? Colors.orange : const Color(0xFF7A5AF8)),
        'title': 'Rs.$intValue Gift Voucher',
      };
    } else if (rewardName.contains('PREMIUM')) {
      return {
        'icon': Icons.workspace_premium,
        'color': const Color(0xFFFFD700),
        'title': 'Premium Upgrade',
      };
    } else if (rewardName.contains('EVENT')) {
      return {
        'icon': Icons.event,
        'color': Colors.blue,
        'title': 'Event Access',
      };
    } else {
      return {
        'icon': Icons.redeem,
        'color': const Color(0xFF7A5AF8),
        'title': reward.replaceAll('_', ' '),
      };
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ISSUED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ISSUED':
        return Icons.check;
      case 'PENDING':
        return Icons.access_time;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.year} ${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  void _showHowToEarnPointsDialog() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Color(0xFF7A5AF8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'How to Earn Unity Stars',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn Unity Stars by completing these activities:',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildEarningMethod(
                    Icons.event_available_sharp,
                    'Attending Events',
                    'Earn 4 star for every event that you attend.',
                    Colors.green,
                  ),
                  _buildEarningMethod(
                    Icons.payment_sharp,
                    'On time membership payment',
                    'Earn 2 star for every on time payment of your membership fee.',
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DEFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF7A5AF8).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF7A5AF8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: Combine multiple activities to maximize your star earnings!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Color(0xFF7A5AF8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEarningMethod(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String date,
    int points,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 10,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '-$points',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
