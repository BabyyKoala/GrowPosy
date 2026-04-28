import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddGrowthScreen extends StatefulWidget {
  final String childId;
  final String userId;
  final String childName;

  const AddGrowthScreen({
    super.key,
    required this.childId,
    required this.userId,
    required this.childName,
  });

  @override
  State<AddGrowthScreen> createState() => _AddGrowthScreenState();
}

class _AddGrowthScreenState extends State<AddGrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  bool isLoading = false;
  final firestore = FirestoreService();

  // 🔥 FITUR BARU: State untuk Dropdown Imunisasi
  String? selectedImunisasi = 'Tidak Ada';

  // Daftar Imunisasi Standar Kemenkes RI & Tambahan Posyandu
  final List<String> daftarImunisasi = [
    'Tidak Ada',
    'Hepatitis B0',
    'BCG',
    'Polio 1',
    'DPT-HB-Hib 1',
    'Polio 2',
    'DPT-HB-Hib 2',
    'Polio 3',
    'DPT-HB-Hib 3',
    'Polio 4',
    'IPV',
    'Campak / MR',
    'Vitamin A (Biru)', // 6-11 Bulan
    'Vitamin A (Merah)', // 12-59 Bulan
  ];

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA SIMPAN & VALIDASI
  // ==========================
  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Mengubah string ke double, antisipasi keyboard format Indo (koma)
      double newWeight = double.parse(
        weightController.text.replaceAll(',', '.'),
      );
      double newHeight = double.parse(
        heightController.text.replaceAll(',', '.'),
      );

      // 🔥 FITUR BARU: VALIDASI TINGGI BADAN ANTI-TURUN
      // Mengambil data pengukuran terakhir anak ini
      final lastData = await firestore.getLastGrowthData(
        widget.userId,
        widget.childId,
      );

      if (lastData != null) {
        final double lastHeight = (lastData['height'] ?? 0).toDouble();

        // Cek jika tinggi yang diinput lebih pendek dari sebelumnya
        if (newHeight < lastHeight) {
          if (!mounted) return;
          setState(() => isLoading = false);

          // Tampilkan Peringatan Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "⚠️ Gagal! Tinggi/Panjang badan tidak boleh turun.\nTinggi sebelumnya: $lastHeight cm.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColor.errorRed,
              duration: const Duration(seconds: 4),
            ),
          );
          return; // Hentikan proses simpan
        }
      }

      // Jika lolos validasi, simpan ke Firebase
      await firestore.addGrowth(
        userId: widget.userId,
        childId: widget.childId,
        weight: newWeight,
        height: newHeight,
        // Menyimpan imunisasi (kosongkan jika memilih 'Tidak Ada')
        imunisasi: selectedImunisasi == 'Tidak Ada' ? '' : selectedImunisasi!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data KMS ${widget.childName} berhasil diperbarui!"),
          backgroundColor: AppColor.primaryGreen,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan: Pastikan input berupa angka."),
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
          icon: const Icon(Icons.close, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Input Data Pertumbuhan",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 KOTAK INFO ANAK
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColor.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColor.primaryGreen,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Mencatat untuk:",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textGrey,
                              ),
                            ),
                            Text(
                              widget.childName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text("Hasil Pengukuran", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text(
                  "Masukkan data terbaru hasil timbang dan ukur hari ini.",
                  style: AppTextStyle.bodyText,
                ),
                const SizedBox(height: 32),

                // 🔥 INPUT BERAT BADAN
                const Text("Berat Badan (kg)", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: weightController,
                  hintText: "Contoh: 12.5",
                  prefixIcon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Berat badan wajib diisi";
                    }
                    final n = double.tryParse(value.replaceAll(',', '.'));
                    if (n == null) return "Gunakan format angka";
                    if (n > 50) return "Angka tidak wajar (>50kg)";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 🔥 INPUT TINGGI BADAN
                const Text(
                  "Tinggi / Panjang Badan (cm)",
                  style: AppTextStyle.inputLabel,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: heightController,
                  hintText: "Contoh: 85.0",
                  prefixIcon: Icons.height_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tinggi badan wajib diisi";
                    }
                    final n = double.tryParse(value.replaceAll(',', '.'));
                    if (n == null) return "Gunakan format angka";
                    if (n > 200) return "Angka tidak wajar";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 🔥 FITUR BARU: INPUT DROPDOWN IMUNISASI
                const Text(
                  "Imunisasi / Pemberian Vitamin",
                  style: AppTextStyle.inputLabel,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedImunisasi,
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColor.textGrey,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.vaccines_outlined,
                      color: AppColor.primaryGreen,
                    ),
                    filled: true,
                    fillColor: AppColor.bgWhite,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColor.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  items: daftarImunisasi.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: item == 'Tidak Ada'
                              ? AppColor.textGrey
                              : AppColor.textBlack,
                          fontWeight: item == 'Tidak Ada'
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedImunisasi = val;
                    });
                  },
                ),

                const SizedBox(height: 48),

                // 🔥 TOMBOL SIMPAN
                CustomButton(
                  text: "Simpan & Sinkronkan",
                  onPressed: _handleSave,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Data akan divalidasi dan langsung ter-update\ndi grafik pertumbuhan anak.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.textGrey,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
