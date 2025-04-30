import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailController.text.trim());
    
    if (success && mounted) {
      setState(() {
        _resetSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send password reset email. Please check your email address.')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _resetSent 
              ? _buildResetSentMessage() 
              : _buildResetForm(authProvider),
        ),
      ),
    );
  }
  
  Widget _buildResetSentMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        const Text(
          'Reset Email Sent',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please check your email for instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
  
  Widget _buildResetForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          const Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter the email address associated with your account, and we\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: authProvider.isLoading
                ? const CircularProgressIndicator()
                : const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
