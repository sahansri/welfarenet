import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/navigation.dart';
import 'package:welfarenet_mobile/pages/forgot_password/forgot_password.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => LoginSheetState();
}

class LoginSheetState extends State<LoginSheet> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      final savedEmail = prefs.getString('saved_email') ?? '';

      setState(() {
        _emailController.text = savedEmail;
        isChecked = rememberMe;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 3) {
      return 'Password must be at least 3 characters';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check internet connectivity first
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No internet connection. Please check your network.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Save or clear credentials based on Remember Me checkbox
    final prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', email);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');
    }

    final result = await _authService.login(email, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      // Close the login sheet and navigate to dashboard
      Navigator.of(context).pop(); // Close bottom sheet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    } else {
      // Show error alert dialog
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Login Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              content: Text(
                result['message'] ?? 'Login failed. Please try again.',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A5AF8),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textStyles = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.spacing(24)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.spacing(24)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: responsive.spacing(40),
                  height: responsive.spacing(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(responsive.spacing(2)),
                  ),
                ),
              ),
              SizedBox(height: responsive.spacing(24)),
              Center(
                child: Column(
                  children: [
                    Text(
                      'WelfareNet',
                      style: textStyles.headline1.copyWith(
                        color: const Color(0xFF7A5AF8),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      'Community Management System',
                      style: textStyles.body2.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(2)),
                    Text(
                      'Pathum Uyana Welfare Society',
                      style: textStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.spacing(32)),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Sign In',
                      style: textStyles.headline2.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      'Sign in to your account',
                      style: textStyles.subtitle2.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.spacing(32)),
              Text(
                'Email',
                style: textStyles.subtitle2.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              SizedBox(height: responsive.spacing(20)),
              Text(
                'Password',
                style: textStyles.subtitle2.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                validator: _validatePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              SizedBox(height: responsive.spacing(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: responsive.spacing(24),
                        width: responsive.spacing(24),
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                          activeColor: const Color(0xFF7A5AF8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsive.spacing(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.spacing(8)),
                      Text(
                        'Remember me',
                        style: textStyles.body2.copyWith(
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ForgotPassword(),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: textStyles.body2.copyWith(
                        color: const Color(0xFF7A5AF8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(24)),
              Container(
                width: double.infinity,
                height: responsive.spacing(54),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close login sheet
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const RegistrationSheet(),
                        );
                      },
                      child: const Text(
                        "Register Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF7A5AF8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationSheet extends StatefulWidget {
  const RegistrationSheet({super.key});

  @override
  State<RegistrationSheet> createState() => _RegistrationSheetState();
}

class _RegistrationSheetState extends State<RegistrationSheet> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();

  PlatformFile? _proofDocument;
  bool isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _houseNoController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? _validateContactNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validateHouseNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'House number is required';
    }
    return null;
  }

  Future<void> _pickProofDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true, // Ensure bytes are loaded
      );

      if (result != null && result.files.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _proofDocument = result.files.first;
        });
        print(
          '📁 File picked: ${_proofDocument!.name}, Size: ${_proofDocument!.size} bytes, Has bytes: ${_proofDocument!.bytes != null}, Has path: ${_proofDocument!.path != null}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRegistration() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_proofDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a proof document'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final fullName = _fullNameController.text.trim();
    final address = _addressController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final email = _emailController.text.trim();
    final houseNo = _houseNoController.text.trim();

    // Check internet connectivity
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No internet connection. Please check your network.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    print(
      '📤 Submitting registration: $fullName, $address, $contactNumber, $email, $houseNo,$_proofDocument',
    );
    final result = await _authService.register(
      fullName: fullName,
      address: address,
      contactNumber: contactNumber,
      email: email,
      houseNo: houseNo,
      proofDocument: _proofDocument!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Registration Successful',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Your registration has been submitted successfully. Please wait for admin approval. You will receive your login credentials via email.',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                    Navigator.pop(context); // Close registration sheet
                    // Show login sheet again
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LoginSheet(),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A5AF8),
                    ),
                  ),
                ),
              ],
            ),
      );
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Registration Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              content: Text(
                result['message'] ??
                    'Failed to submit registration. Please try again.',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A5AF8),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Register for membership',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                validator: _validateFullName,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Address
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                validator: _validateAddress,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // House Number
              const Text(
                'House Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _houseNoController,
                validator: _validateHouseNo,
                decoration: InputDecoration(
                  hintText: 'Enter your house number',
                  prefixIcon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Contact Number
              const Text(
                'Contact Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                validator: _validateContactNumber,
                decoration: InputDecoration(
                  hintText: 'Enter your contact number',
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7A5AF8),
                      width: 2,
                    ),
                  ),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Proof Document
              const Text(
                'Proof Document',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickProofDocument,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _proofDocument != null
                              ? const Color(0xFF7A5AF8)
                              : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _proofDocument != null
                            ? Icons.check_circle
                            : Icons.upload_file_outlined,
                        color:
                            _proofDocument != null
                                ? const Color(0xFF7A5AF8)
                                : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _proofDocument != null
                              ? _proofDocument!.name
                              : 'Upload ID or Utility Bill (PDF, JPG, PNG)',
                          style: TextStyle(
                            color:
                                _proofDocument != null
                                    ? const Color(0xFF111827)
                                    : const Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF7A5AF8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text(
                          'I agree to the ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showTermsAndConditions,
                          child: const Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7A5AF8),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Register Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to Login
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close registration sheet
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LoginSheet(),
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A5AF8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: Color(0xFF7A5AF8),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pathum Uyana Welfare Society Membership Terms',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '1. Membership Eligibility',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Membership is open to all residents of Pathum Uyana who provide valid proof of residence. Each household is entitled to one membership.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '2. Member Responsibilities',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\u2022 Pay membership fees and other dues on time\n'
                            '\u2022 Attend community meetings and participate in activities\n'
                            '\u2022 Respect community rules and regulations\n'
                            '\u2022 Maintain accurate contact information with the society\n'
                            '\u2022 Support community welfare initiatives',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '3. Payment Terms',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Members agree to pay monthly membership fees and any additional charges as determined by the welfare society. All payments are non-refundable except in cases approved by the committee.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '4. Privacy and Data Usage',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Personal information provided will be used solely for welfare society purposes. We will not share your data with third parties without your consent, except as required by law.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '5. Code of Conduct',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Members must maintain respectful behavior towards other members and the community. Any form of harassment, discrimination, or disruptive behavior may result in membership suspension or termination.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '6. Membership Termination',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The welfare society reserves the right to terminate membership for non-payment of fees, violation of terms, or behavior detrimental to the community. Members may also voluntarily terminate membership with written notice.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '7. Amendments',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'These terms and conditions may be amended by the welfare society committee with proper notification to all members. Continued membership after amendments constitutes acceptance of new terms.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'By accepting these terms, you acknowledge that you have read, understood, and agree to be bound by all conditions outlined above.',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _acceptedTerms = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5AF8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept Terms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
