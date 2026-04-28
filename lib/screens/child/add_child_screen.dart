import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 WAJIB: Untuk mengetahui Ibu mana yang login
import '../../services/firestore_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  DateTime? selectedDate;
  int calculatedAge = 0;

  String selectedGender = 'L';
  bool isLoading = false;

  final firestore = FirestoreService();

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA PILIH TANGGAL
  // ==========================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018), // Batas balita
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColor.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        final days = DateTime.now().difference(picked).inDays;
        calculatedAge = (days / 30.44).floor();
      });
    }
  }

  // ==========================
  // ⚙️ LOGIKA SIMPAN DATA (UPGRADED)
  // ==========================
  void save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tanggal lahir wajib diisi!"),
          backgroundColor: AppColor.errorRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔥 1. Dapatkan ID Ibu yang sedang menggunakan aplikasi
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null)
        throw Exception("Sesi login tidak valid. Silakan login ulang.");

      // Bersihkan koma menjadi titik untuk desimal
      double? birthWeight = double.tryParse(
        weightController.text.trim().replaceAll(',', '.'),
      );
      double? birthHeight = double.tryParse(
        heightController.text.trim().replaceAll(',', '.'),
      );

      // 🔥 2. Kirim data lengkap ke Firestore (Pastikan fungsi addChild di Service diperbarui juga)
      await firestore.addChild(
        userId: currentUser.uid, // Sangat Penting!
        name: nameController.text.trim(),
        birthDate: selectedDate!, // Kirim objek tanggalnya langsung
        age: calculatedAge, // Usia statis saat didaftarkan
        gender: selectedGender,
        birthWeight: birthWeight,
        birthHeight: birthHeight,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil buah hati berhasil dibuat! 🎉"),
          backgroundColor: AppColor.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
          backgroundColor: AppColor.errorRed,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================
  // 🎨 TAMPILAN UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        title: const Text("Tambah Data Anak"),
      ), // Styling AppBar otomatis ikut AppTheme global
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER FOTO AVATAR
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.primaryGreen.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: selectedGender == 'L'
                              ? Colors.blue[50]
                              : Colors.pink[50],
                          child: Icon(
                            selectedGender == 'L' ? Icons.face : Icons.face_3,
                            size: 50,
                            color: selectedGender == 'L'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // SECTION 1: IDENTITAS UTAMA
                const Text("Informasi Dasar", style: AppTextStyle.heading3),
                const Divider(),
                const SizedBox(height: 12),

                const Text("Nama Lengkap", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: nameController,
                  hintText: "Contoh: Budi Santoso",
                  prefixIcon: Icons.person_outline,
                  textCapitalization:
                      TextCapitalization.words, // Otomatis Huruf Kapital
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return "Nama wajib diisi";
                    if (value.length < 2) return "Nama terlalu pendek";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // JENIS KELAMIN
                const Text("Jenis Kelamin", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        "L",
                        "Laki-laki",
                        Icons.male_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderCard(
                        "P",
                        "Perempuan",
                        Icons.female_rounded,
                        Colors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // DATE PICKER TANGGAL LAHIR
                const Text("Tanggal Lahir", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedDate == null
                            ? AppColor.borderGrey
                            : AppColor.primaryGreen,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: selectedDate == null
                              ? AppColor.textGrey
                              : AppColor.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? "Pilih Tanggal Lahir"
                              : DateFormat(
                                  'dd MMMM yyyy',
                                ).format(selectedDate!),
                          style: TextStyle(
                            color: selectedDate == null
                                ? AppColor.textGrey
                                : AppColor.textBlack,
                            fontWeight: selectedDate == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (selectedDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$calculatedAge Bulan",
                              style: const TextStyle(
                                color: AppColor.primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // SECTION 2: DATA KELAHIRAN
                const Text(
                  "Data Lahir (Awal KMS)",
                  style: AppTextStyle.heading3,
                ),
                const Divider(),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Berat Lahir",
                            style: AppTextStyle.inputLabel,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: weightController,
                            hintText: "Misal: 3.2",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                "kg",
                                style: TextStyle(color: AppColor.textGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Panjang Lahir",
                            style: AppTextStyle.inputLabel,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: heightController,
                            hintText: "Misal: 50",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                "cm",
                                style: TextStyle(color: AppColor.textGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "*Data berat dan panjang lahir penting untuk titik awal grafik pertumbuhan balita.",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 50),

                // TOMBOL SIMPAN
                CustomButton(
                  text: "Simpan Profil Anak",
                  onPressed: save,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    bool isSelected = selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColor.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColor.textGrey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : AppColor.textGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
