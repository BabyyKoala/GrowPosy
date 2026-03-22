import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isAgree = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;
  bool isConfirmHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isAgree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap setujui syarat & ketentuan"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    // 🔥 CEK APAKAH USER SUDAH ADA
    final isExist = await SessionService.login(
      emailController.text,
      passwordController.text,
    );

    if (isExist) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun sudah terdaftar"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔥 SIMPAN USER
    await SessionService.saveUser(
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registrasi berhasil, silakan login"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  const Icon(Icons.person_add, size: 80, color: Colors.white),

                  const SizedBox(height: 10),

                  const Text(
                    "Buat Akun",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nama
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Nama Lengkap",
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nama wajib diisi";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email wajib diisi";
                              }
                              if (!value.contains("@")) {
                                return "Format email tidak valid";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: isPasswordHidden,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordHidden = !isPasswordHidden;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password wajib diisi";
                              }
                              if (value.length < 6) {
                                return "Minimal 6 karakter";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Confirm Password
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: isConfirmHidden,
                            decoration: InputDecoration(
                              labelText: "Konfirmasi Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isConfirmHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isConfirmHidden = !isConfirmHidden;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Konfirmasi password wajib diisi";
                              }
                              if (value != passwordController.text) {
                                return "Password tidak sama";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Checkbox(
                                value: isAgree,
                                onChanged: (value) {
                                  setState(() {
                                    isAgree = value!;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  "Saya setuju dengan syarat & ketentuan",
                                ),
                              ),
                            ],
                          ),

                          // Button Register
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleRegister,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Daftar",
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sudah punya akun? Login",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
