import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/screen/HomeScreen.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: AppTheme.lightTheme, // Apply your custom theme
      home: const LoginPage(),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate, 
      ],
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


 

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  late ApiService apiService = ApiService();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

   @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      final response = await apiService.login(_emailController.text,_passwordController.text);

      if (response != null) {
         final accessToken = response.access;
      final refreshToken = response.refresh;
        final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);



        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: AppColors.primary,
            duration: Duration(milliseconds: 1),
          ),
        );

        Navigator.push(context,
          MaterialPageRoute(builder:(context) => const HomeScreen()));
        print("Login successful: ${response}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Login failed");
      }

      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: AppColors.background, // Use background color from theme
      body: Stack(
        children: [
          // Background pattern (replace with your actual image or custom painter if needed)
          // Positioned.fill(
          //   child: Image.network(
          //     'https://i.imgur.com/e2d4G0w.png', // Replace with your image asset or a custom painter
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Log in to your account',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email and password to access your account',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Email or Username',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'email', // Placeholder text
                          hintText: '',
                          
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'password', // Placeholder text
                          hintText: '',
                          obscureText: _obscureText,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Log in',
                          onPressed: _handleLogin,
                        //  onPressed: (){
                        //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
                        //  },
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),
                      
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}