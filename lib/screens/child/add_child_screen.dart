import 'package:flutter/material.dart';
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
  final ageController = TextEditingController();

  // 🔥 Default value 'L' atau 'P' sesuai logika UI di Home
  String selectedGender = 'L';
  bool isLoading = false;

  final firestore = FirestoreService();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA SIMPAN DATA
  // ==========================
  void save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Membersihkan input umur: mencegah desimal menyebabkan parsing gagal (menjadi 0)
      String cleanAgeString = ageController.text.trim().replaceAll(',', '.');
      // Jika user ketik 12.5, kita ambil '12' saja
      int parsedAge = int.tryParse(cleanAgeString.split('.')[0]) ?? 0;

      await firestore.addChild(
        name: nameController.text.trim(),
        age: parsedAge,
        gender: selectedGender,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data anak berhasil ditambahkan!"),
          backgroundColor: AppColor.primaryGreen,
        ),
      );

      Navigator.pop(context); // Kembali ke Home Ibu
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan data: $e"),
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
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Anak",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 HEADER & ILUSTRASI
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 64,
                      color: AppColor.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text("Profil Buah Hati", style: AppTextStyle.heading1),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Lengkapi data di bawah ini untuk mulai memantau grafik KMS si kecil secara digital.",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyText,
                  ),
                ),
                const SizedBox(height: 40),

                // 🔥 INPUT NAMA
                const Text("Nama Lengkap Anak", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: nameController,
                  hintText: "Contoh: Budi Santoso",
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return "Nama anak wajib diisi";
                    if (value.length < 2) return "Nama terlalu pendek";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🔥 INPUT UMUR (BULAN)
                const Text(
                  "Umur Saat Ini (Bulan)",
                  style: AppTextStyle.inputLabel,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: ageController,
                  hintText: "Contoh: 12",
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Umur wajib diisi";
                    // Antisipasi ketidaksengajaan input koma/titik
                    String cleanVal = value.replaceAll(',', '.').split('.')[0];
                    if (int.tryParse(cleanVal) == null)
                      return "Masukkan angka yang valid";
                    if (int.parse(cleanVal) > 60)
                      return "Posyandu maksimal melayani usia 60 bulan";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🔥 INPUT JENIS KELAMIN
                const Text("Jenis Kelamin", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColor.textGrey,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      selectedGender == 'L' ? Icons.face : Icons.face_3,
                      color: AppColor.textGrey,
                    ),
                    filled: true,
                    fillColor: AppColor.bgWhite,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                  ],
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),

                const SizedBox(height: 50),

                // 🔥 TOMBOL SIMPAN
                CustomButton(
                  text: "Simpan Data Anak",
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
}
