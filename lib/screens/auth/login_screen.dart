import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'register_screen.dart';
import '../../languages/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterPressed;
  
  const LoginScreen({Key? key, this.onRegisterPressed}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Navigate to dashboard on success
      if (mounted) {
        // Replace with your dashboard route
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      final localizations = AppLocalizations.of(context)!;
      String message = localizations.errorOccurred;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = localizations.invalidEmailPassword;
      } else if (e.code == 'too-many-requests') {
        message = localizations.tooManyAttempts;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorOccurred)),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFED1C24).withOpacity(0.05), // RapidKL Red
              const Color(0xFF003DA5).withOpacity(0.05), // RapidKL Blue
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // RapidKL Logo Section
                  Hero(
                    tag: 'rapidkl_logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.primaryColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.train,
                        size: 45,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // RapidKL Branding with Red/Blue colors
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rapid',
                          style: GoogleFonts.roboto(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor, // Red
                            letterSpacing: -1,
                          ),
                        ),
                        TextSpan(
                          text: 'KL',
                          style: GoogleFonts.roboto(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF003DA5), // Official RapidKL Blue
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.smartLockerSystem,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.primaryColor, // Red
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3182CE), // Blue
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Form Card - RapidKL Style
                  SizedBox(
                    width: size.width > 400 ? 400 : double.infinity,
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                localizations.welcomeBack,
                                style: GoogleFonts.roboto(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.accessLockerSystem,
                                style: GoogleFonts.roboto(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              
                              // Email Field - RapidKL Style
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: localizations.email,
                                  hintText: localizations.enterEmail,
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: theme.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
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
                              
                              // Password Field - RapidKL Style
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: localizations.password,
                                  hintText: 'Enter your ${localizations.password.toLowerCase()}',
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
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
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
                              const SizedBox(height: 12),
                              
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(localizations.forgotPasswordSoon),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    localizations.forgotPassword,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Login Button with Red/Blue gradient
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor, // Red
                                      const Color(0xFF3182CE), // Blue
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
                                  onPressed: _isLoading ? null : _login,
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
                                          localizations.login,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey[300])),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey[300])),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Register Link
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    localizations.dontHaveAccount,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: widget.onRegisterPressed ?? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      localizations.register,
                                      style: GoogleFonts.poppins(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
