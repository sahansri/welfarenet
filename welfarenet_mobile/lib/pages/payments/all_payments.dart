import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/services/payment_service.dart';
import 'package:welfarenet_mobile/models/payment_model.dart';
import 'package:welfarenet_mobile/pages/payments/payment_detail.dart';

class AllPayments extends StatefulWidget {
  const AllPayments({super.key});

  @override
  State<AllPayments> createState() => _AllPaymentsState();
}

class _AllPaymentsState extends State<AllPayments>
    with SingleTickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  List<PaymentModel> _allPayments = [];
  List<PaymentModel> _membershipPayments = [];
  List<PaymentModel> _donationPayments = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payments = await _paymentService.getAllPaymentDetails();
      setState(() {
        _allPayments = payments.reversed.toList();
        // Filter membership payments
        _membershipPayments =
            payments
                .where((payment) {
                  final type = payment.paymentType.toLowerCase();
                  return type.contains('membership') || type.contains('member');
                })
                .toList()
                .reversed
                .toList();
        // Filter donation payments
        _donationPayments =
            payments
                .where((payment) {
                  final type = payment.paymentType.toLowerCase();
                  return type.contains('donation') || type.contains('donate');
                })
                .toList()
                .reversed
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading all payments: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load payments: $e')));
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
                            : _allPayments.isEmpty
                            ? _buildEmptyState()
                            : _buildPaymentsList(),
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'All Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'View all payment history',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No payments found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'All payment history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF7A5AF8),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF7A5AF8),
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.receipt_long),
                text: 'All (${_allPayments.length})',
              ),
              Tab(
                icon: const Icon(Icons.card_membership),
                text: 'Membership (${_membershipPayments.length})',
              ),
              Tab(
                icon: const Icon(Icons.volunteer_activism),
                text: 'Donation (${_donationPayments.length})',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: _loadAllPayments,
                color: const Color(0xFF7A5AF8),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPaymentTable(
                    'All Payments',
                    _allPayments,
                    Icons.receipt_long,
                    const Color(0xFF7A5AF8),
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: _loadAllPayments,
                color: const Color(0xFF7A5AF8),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPaymentTable(
                    'Membership Payments',
                    _membershipPayments,
                    Icons.card_membership,
                    const Color(0xFF7A5AF8),
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: _loadAllPayments,
                color: const Color(0xFF00D9A5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPaymentTable(
                    'Donation Payments',
                    _donationPayments,
                    Icons.volunteer_activism,
                    const Color(0xFF00D9A5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTable(
    String title,
    List<PaymentModel> payments,
    IconData icon,
    Color color,
  ) {
    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No $title yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final totalAmount = payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rs.${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _HorizontalScrollTable(color: color, payments: payments),
      ],
    );
  }
}

class _HorizontalScrollTable extends StatefulWidget {
  final Color color;
  final List<PaymentModel> payments;

  const _HorizontalScrollTable({required this.color, required this.payments});

  @override
  State<_HorizontalScrollTable> createState() => _HorizontalScrollTableState();
}

class _HorizontalScrollTableState extends State<_HorizontalScrollTable> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                widget.color.withValues(alpha: 0.1),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  widget.payments.map((payment) {
                    final paymentMap = payment.toDisplayMap();
                    Color statusColor;
                    String statusText;

                    switch (paymentMap['status']) {
                      case 'PENDING':
                        statusColor = const Color(0xFFFF9500);
                        statusText = 'Review';
                        break;
                      case 'APPROVED':
                        statusColor = const Color(0xFF00D9A5);
                        statusText = 'Approved';
                        break;
                      case 'REJECTED':
                        statusColor = const Color(0xFFFF3B30);
                        statusText = 'Rejected';
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusText = paymentMap['status'] ?? 'Unknown';
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            paymentMap['date'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  paymentMap['type'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (paymentMap['description'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    paymentMap['description'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            'Rs.${paymentMap['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton.icon(
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text('View'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(80, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentDetail(
                                        payment: paymentMap,
                                        status: statusText,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
