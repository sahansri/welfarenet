import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/services/profile_service.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/pages/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
          ),
        ),
        child: SafeArea(
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
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSectionTitle('Account Settings'),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: 'Manage your email address',
                        onTap: () {
                          // TODO: Navigate to email settings
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.person_off_outlined,
                        title: 'Deactivate Account',
                        subtitle: 'Temporarily deactivate your account',
                        onTap: () => _showDeactivateAccountDialog(context),
                      ),
                      // const SizedBox(height: 24),
                      // _buildSectionTitle('Notifications'),
                      // const SizedBox(height: 12),
                      // _buildSwitchCard(
                      //   icon: Icons.notifications_outlined,
                      //   title: 'Push Notifications',
                      //   subtitle: 'Receive push notifications',
                      //   value: _pushNotifications,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _pushNotifications = value;
                      //     });
                      //   },
                      // ),
                      // const SizedBox(height: 12),
                      // _buildSwitchCard(
                      //   icon: Icons.email_outlined,
                      //   title: 'Email Notifications',
                      //   subtitle: 'Receive email updates',
                      //   value: _emailNotifications,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _emailNotifications = value;
                      //     });
                      //   },
                      // ),
                      // const SizedBox(height: 24),
                      // _buildSectionTitle('Preferences'),
                      // const SizedBox(height: 12),
                      // _buildSettingsCard(
                      //   icon: Icons.language,
                      //   title: 'Language',
                      //   subtitle: 'English',
                      //   onTap: () {
                      //     // TODO: Navigate to language settings
                      //   },
                      // ),
                      // const SizedBox(height: 12),
                      // _buildSettingsCard(
                      //   icon: Icons.color_lens_outlined,
                      //   title: 'Theme',
                      //   subtitle: 'Light mode',
                      //   onTap: () {
                      //     // TODO: Navigate to theme settings
                      //   },
                      // ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Support'),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help or contact us',
                        onTap: () {
                          _showHelpAndSupportDialog(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and info',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {
                          _showPrivacyPolicyDialog(context);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final responsive = context.responsive;
    final textStyles = context.textStyles;

    return Padding(
      padding: responsive.pagePadding,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: responsive.iconSize(24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Settings',
              style: textStyles.headline2.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final textStyles = context.textStyles;

    return Padding(
      padding: EdgeInsets.only(left: context.responsive.spacing(4)),
      child: Text(
        title,
        style: textStyles.subtitle1.copyWith(color: const Color(0xFF333333)),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final responsive = context.responsive;
    final textStyles = context.textStyles;
    final iconContainerSize = responsive.iconSize(48);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(8),
        ),
        leading: Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF7A5AF8),
            size: responsive.iconSize(24),
          ),
        ),
        title: Text(
          title,
          style: textStyles.subtitle2.copyWith(color: const Color(0xFF333333)),
        ),
        subtitle: Text(
          subtitle,
          style: textStyles.body2.copyWith(color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: const Color(0xFF7A5AF8),
          size: responsive.iconSize(24),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final responsive = context.responsive;
    final textStyles = context.textStyles;
    final iconContainerSize = responsive.iconSize(48);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(8),
        ),
        leading: Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF7A5AF8),
            size: responsive.iconSize(24),
          ),
        ),
        title: Text(
          title,
          style: textStyles.subtitle2.copyWith(color: const Color(0xFF333333)),
        ),
        subtitle: Text(
          subtitle,
          style: textStyles.body2.copyWith(color: Colors.grey[600]),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF7A5AF8),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool _currentPasswordVisible = false;
    bool _newPasswordVisible = false;
    bool _confirmPasswordVisible = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils(context).cardBorderRadius,
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: const Color(0xFF7A5AF8),
                        size: ResponsiveUtils(context).iconSize(24),
                      ),
                      SizedBox(width: ResponsiveUtils(context).spacing(8)),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: AppTextStyles(context).headline3,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          obscureText: !_currentPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF7A5AF8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _currentPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentPasswordVisible =
                                      !_currentPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF7A5AF8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController,
                          obscureText: !_newPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(
                              Icons.lock_reset,
                              color: Color(0xFF7A5AF8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _newPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _newPasswordVisible = !_newPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF7A5AF8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF7A5AF8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF7A5AF8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5AF8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (currentPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter current password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (newPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter new password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (newPasswordController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password must be at least 6 characters',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Call the API
                        final result = await _profileService.changePassword(
                          oldPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        if (mounted) {
                          // Close dialog first
                          Navigator.pop(context);

                          // Then show success or error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Password change failed',
                              ),
                              backgroundColor:
                                  result['success'] == true
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final responsive = ResponsiveUtils(context);
    final textStyles = AppTextStyles(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF7A5AF8),
                  size: responsive.iconSize(24),
                ),
                SizedBox(width: responsive.spacing(8)),
                Expanded(
                  child: Text('About WelfareNet', style: textStyles.headline3),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version 1.0.0', style: textStyles.subtitle2),
                SizedBox(height: responsive.spacing(16)),
                Text(
                  'WelfareNet is a community management platform designed to help members stay connected and manage their welfare activities.',
                  style: textStyles.body2.copyWith(color: Colors.grey[700]),
                ),
                SizedBox(height: responsive.spacing(16)),
                Text(
                  '© 2026 WelfareNet. All rights reserved.',
                  style: textStyles.caption.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelpAndSupportDialog(BuildContext context) {
    final responsive = ResponsiveUtils(context);
    final textStyles = AppTextStyles(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.cardBorderRadius),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: const Color(0xFF7A5AF8),
                  size: responsive.iconSize(24),
                ),
                SizedBox(width: responsive.spacing(8)),
                Expanded(
                  child: Text('Help & Support', style: textStyles.headline3),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How can we help you?', style: textStyles.subtitle2),
                  SizedBox(height: responsive.spacing(20)),
                  _buildHelpOption(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'welfarenet123@gmail.com',
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'welfarenet123@gmail.com',
                        query: 'subject=Support Request',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open email client'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildHelpOption(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Phone Support',
                    subtitle: '+94 (70) 447-0620 or +94 (72) 529-4720',
                    onTap: () async {
                      Navigator.pop(context);
                      // Show dialog to select which number to call
                      if (context.mounted) {
                        final phoneNumber = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text('Select Phone Number'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.phone,
                                        color: Color(0xFF7A5AF8),
                                      ),
                                      title: const Text('+94 70 447 0620'),
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            '+94704470620',
                                          ),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.phone,
                                        color: Color(0xFF7A5AF8),
                                      ),
                                      title: const Text('+94 72 529 4720'),
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            '+94725294720',
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                        );

                        if (phoneNumber != null && context.mounted) {
                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open phone dialer'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildHelpOption(
                    context,
                    icon: Icons.question_answer_outlined,
                    title: 'FAQ',
                    subtitle: 'Common questions and answers',
                    onTap: () {
                      Navigator.pop(context);
                      _showFAQDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildHelpOption(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: 'Report a Bug',
                    subtitle: 'Help us improve the app',
                    onTap: () {
                      Navigator.pop(context);
                      _showReportBugDialog(context);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: textStyles.body2.copyWith(
                    color: const Color(0xFF7A5AF8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHelpOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final responsive = ResponsiveUtils(context);
    final textStyles = AppTextStyles(context);
    final iconContainerSize = responsive.iconSize(40);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.spacing(12)),
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(12)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
        ),
        child: Row(
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(10)),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7A5AF8),
                size: responsive.iconSize(20),
              ),
            ),
            SizedBox(width: responsive.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(2)),
                  Text(
                    subtitle,
                    style: textStyles.caption.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: responsive.iconSize(20),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.question_answer_outlined, color: Color(0xFF7A5AF8)),
                SizedBox(width: 8),
                Text('Frequently Asked Questions'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFAQItem(
                    question: 'How do I reset my password?',
                    answer:
                        'Go to Settings > Change Password to update your password.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I make a payment?',
                    answer:
                        'Navigate to the Payments section and select your payment type (membership or donation).',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I view events?',
                    answer:
                        'Check the Events section on the dashboard to see upcoming and past events.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'Where can I see my loyalty points?',
                    answer:
                        'Your loyalty points and rewards are available in the Loyalty Rewards section.',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  void _showReportBugDialog(BuildContext context) {
    final TextEditingController bugDescriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.bug_report_outlined, color: Color(0xFF7A5AF8)),
                SizedBox(width: 8),
                Text('Report a Bug'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help us improve by reporting any issues you encounter.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bugDescriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Describe the issue',
                      hintText: 'What went wrong? When did it happen?',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF7A5AF8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (bugDescriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please describe the issue'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // TODO: Send bug report to backend
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bug report submitted. Thank you!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.privacy_tip_outlined, color: Color(0xFF7A5AF8)),
                SizedBox(width: 8),
                Text('Privacy Policy'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last updated: February 13, 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPrivacySection(
                    title: '1. Information We Collect',
                    content:
                        'We collect information you provide directly to us, including your name, email address, contact number, house number, and address when you register for an account. We also collect payment information when you make membership or donation payments.',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '2. How We Use Your Information',
                    content:
                        'We use the information we collect to:\n• Provide, maintain, and improve our services\n• Process your transactions and send related information\n• Send you technical notices and support messages\n• Communicate with you about events, announcements, and community updates\n• Monitor and analyze usage patterns',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '3. Information Sharing',
                    content:
                        'We do not sell or rent your personal information to third parties. We may share your information only in the following circumstances:\n• With your consent\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• With service providers who assist in our operations',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '4. Data Security',
                    content:
                        'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet is 100% secure.',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '5. Your Rights',
                    content:
                        'You have the right to:\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Deactivate your account at any time',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '6. Data Retention',
                    content:
                        'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy. When you deactivate your account, your data will be retained according to legal requirements.',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '7. Children\'s Privacy',
                    content:
                        'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us.',
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    title: '8. Changes to This Policy',
                    content:
                        'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF7A5AF8).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.contact_support_outlined,
                              color: Color(0xFF7A5AF8),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A5AF8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If you have questions about this Privacy Policy, please contact us at welfarenet123@gmail.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  void _showDeactivateAccountDialog(BuildContext context) {
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();

    final List<String> deactivationReasons = [
      'Taking a break from the platform',
      'Privacy concerns',
      'Change the residence',
      'Other',
    ];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.person_off_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Deactivate Account'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We\'re sorry to see you go. Your account will be temporarily deactivated.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please tell us why:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...deactivationReasons.map((reason) {
                          return RadioListTile<String>(
                            title: Text(
                              reason,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: reason,
                            groupValue: selectedReason,
                            activeColor: const Color(0xFF7A5AF8),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          );
                        }).toList(),
                        if (selectedReason == 'Other') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: otherReasonController,
                            maxLines: 3,
                            maxLength: 200,
                            decoration: InputDecoration(
                              labelText: 'Please specify',
                              hintText: 'Tell us more...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7A5AF8),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You can reactivate your account anytime by contacting the society.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[900],
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (selectedReason == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a reason'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (selectedReason == 'Other' &&
                            otherReasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please specify your reason'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final reasonToSend =
                            selectedReason == 'Other'
                                ? otherReasonController.text.trim()
                                : selectedReason!;

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        try {
                          final result = await _authService.deactivateAccount(
                            reasonToSend,
                          );

                          if (!mounted) return;

                          // Close loading dialog
                          Navigator.of(context).pop();
                          // Close deactivate dialog
                          Navigator.of(context).pop();

                          if (result['success'] == true) {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Account deactivated successfully',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Navigate to login page after a short delay
                            await Future.delayed(const Duration(seconds: 1));
                            if (!mounted) return;

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginSheet(),
                              ),
                              (route) => false,
                            );
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Failed to deactivate account',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;

                          // Close loading dialog if still open
                          //Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Deactivate',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }
}
