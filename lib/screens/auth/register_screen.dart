import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rfid_locker_system/providers/auth_provider.dart';
import '../../languages/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  
  const RegisterScreen({Key? key, this.onLoginPressed}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _icController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        ic: _icController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please check your email to verify your account.'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (authProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFED1C24).withOpacity(0.05),
              const Color(0xFF003DA5).withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 32,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Back Button and Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Join ',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              TextSpan(
                                text: 'Rapid',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: 'KL',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF003DA5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join Smart Locker System',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Registration Form Card
                  Center(
                    child: SizedBox(
                      width: size.width > 400 ? 400 : double.infinity,
                      child: Card(
                        elevation: 8,
                        shadowColor: theme.primaryColor.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: localizations.fullName,
                                    hintText: localizations.enterFullName,
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: theme.primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations.pleaseEnterFullName;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: localizations.emailAddress,
                                    hintText: localizations.enterEmail,
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: theme.primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations.pleaseEnterEmail;
                                    }
                                    if (!value.contains('@')) {
                                      return localizations.pleaseEnterValidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: localizations.password,
                                    hintText: localizations.createPassword,
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: theme.primaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations.pleaseEnterPassword;
                                    }
                                    if (value.length < 6) {
                                      return localizations.passwordMinLength;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // IC Number
                                TextFormField(
                                  controller: _icController,
                                  decoration: InputDecoration(
                                    labelText: localizations.icNumberOptional,
                                    hintText: localizations.enterIcNumber,
                                    prefixIcon: Icon(
                                      Icons.credit_card,
                                      color: theme.primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 20),
                                
                                // Phone Number
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number (Optional)',
                                    hintText: 'Enter your phone number',
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      color: theme.primaryColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 32),
                                
                                // Register Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryColor,
                                        const Color(0xFF003DA5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SpinKitThreeBounce(
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            'Create Account',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Login Link
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onLoginPressed ?? () {
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}