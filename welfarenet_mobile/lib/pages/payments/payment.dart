import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/payments/membership_fee.dart';
import 'package:welfarenet_mobile/pages/payments/donation.dart';
import 'package:welfarenet_mobile/pages/payments/payment_detail.dart';
import 'package:welfarenet_mobile/pages/payments/all_payments.dart';
import 'package:welfarenet_mobile/services/payment_service.dart';
import 'package:welfarenet_mobile/models/payment_model.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final PaymentService _paymentService = PaymentService();
  String _selectedTab = 'Review';
  bool _isLoading = true;

  double _totalAmount = 0.0;
  double _pendingAmount = 0.0;
  double _approvedAmount = 0.0;

  List<PaymentModel> _reviewPayments = [];
  List<PaymentModel> _approvedPayments = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final totalFuture = _paymentService.getTotalAmount();
      final pendingFuture = _paymentService.getPendingTotalAmount();
      final approvedFuture = _paymentService.getApprovedTotalAmount();
      final reviewPaymentsFuture = _paymentService.getPendingPayments();
      final approvedPaymentsFuture = _paymentService.getApprovedPayments();

      final results = await Future.wait([
        totalFuture,
        pendingFuture,
        approvedFuture,
        reviewPaymentsFuture,
        approvedPaymentsFuture,
      ]);

      if (!mounted) return;

      setState(() {
        _totalAmount = results[0] as double;
        _pendingAmount = results[1] as double;
        _approvedAmount = results[2] as double;
        _reviewPayments = results[3] as List<PaymentModel>;
        _approvedPayments = results[4] as List<PaymentModel>;

        // Sort by date descending (newest first)
        _reviewPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
        _approvedPayments.sort(
          (a, b) => b.paymentDate.compareTo(a.paymentDate),
        );

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payment data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payment data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Purple gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A5AF8),
                  Color(0xFF9B5DE5),
                  Color(0xFF5D45BC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF7A5AF8),
                              ),
                            )
                            : Column(
                              children: [
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: _loadPaymentData,
                                    color: const Color(0xFF7A5AF8),
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        children: [
                                          _buildPaymentSummary(),
                                          _buildTabButtons(),
                                          _buildPaymentsList(),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Fixed button at bottom
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      20,
                                    ),
                                    child: _buildSubmitButton(),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Do your Payments here.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Image.asset(
                  'lib/assets/payment.png',
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 50,
                    );
                  },
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllPayments(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt, color: Colors.white, size: 18),
                label: const Text(
                  'View All',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Payments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Period 1 Jan ${DateTime.now().year} - 31 Dec ${DateTime.now().year}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total',
                'Rs.${_totalAmount.toStringAsFixed(2)}',
                const Color(0xFF7A5AF8),
              ),
              _buildSummaryItem(
                'Review',
                'Rs.${_pendingAmount.toStringAsFixed(2)}',
                const Color(0xFFFF9500),
              ),
              _buildSummaryItem(
                'Approved',
                'Rs.${_approvedAmount.toStringAsFixed(2)}',
                const Color(0xFF00D9A5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Review', Icons.arrow_forward)),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabButton('Approved', Icons.check_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon) {
    final isSelected = _selectedTab == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A5AF8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    final payments =
        _selectedTab == 'Review' ? _reviewPayments : _approvedPayments;

    if (payments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No ${_selectedTab.toLowerCase()} payments',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            payments.map((payment) {
              final paymentMap = payment.toDisplayMap();
              return InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentDetail(
                            payment: paymentMap,
                            status: _selectedTab,
                          ),
                    ),
                  );
                  // Refresh if there were any changes
                  if (result == true) {
                    _loadPaymentData();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF7A5AF8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            paymentMap['date'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                paymentMap['type'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (paymentMap['description'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  paymentMap['description'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Payment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs.${paymentMap['amount'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => _submitType(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A5AF8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Submit Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _submitType() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MembershipFee(),
                  ),
                );
                // Refresh if payment was submitted successfully
                if (result == true) {
                  _loadPaymentData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A5AF8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Membership Fee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Donation()),
                );
                // Refresh if donation was submitted successfully
                if (result == true) {
                  _loadPaymentData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A5AF8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Donation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
