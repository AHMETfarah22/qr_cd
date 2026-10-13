import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/premium_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late ConfettiController _confettiController;
  int _selectedPlanIndex = 1; // Default to Yearly (Best Value)
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Aylık',
      'price': '₺49.99',
      'period': '/ ay',
      'description': 'Esnek plan, istediğin an iptal et',
      'tag': null,
    },
    {
      'title': 'Yıllık',
      'price': '₺24.99',
      'period': '/ ay',
      'description': '₺299.99 yıllık ödenir\n%50 tasarruf et! 🚀',
      'tag': 'EN POPÜLER',
    },
    {
      'title': 'Ömür Boyu',
      'price': '₺599.99',
      'period': ' tek sefer',
      'description': 'Sonsuza kadar senin, tek ödeme',
      'tag': 'EN İYİ DEĞER',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    setState(() => _isProcessing = true);
    
    // Simulate store purchase delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    await premiumService.setPremium(true);
    if (!mounted) return;

    setState(() => _isProcessing = false);
    _confettiController.play();
    
    // Show beautiful success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.process,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            '🎉 TScan Premium Aktif!',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Artık usta özelliklerin tamamına sınırsız erişimin var. Harika odaklanmalar dileriz!',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close Paywall
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Harika!', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = Provider.of<PremiumService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    Colors.deepPurple.shade900.withValues(alpha: 0.3),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'PREMIUM',
                        style: GoogleFonts.poppins(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer to balance Close button
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        
                        // Header Icon & Title
                        const Icon(Icons.stars_rounded, size: 64, color: AppColors.accent),
                        const SizedBox(height: 16),
                        Text(
                          'TScan Usta Ol',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Odaklanma deneyimini akıllı AI asistanı ile zirveye taşı',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Benefits List
                        _buildBenefitItem(Icons.psychology_rounded, 'AI Okuma Süre Tahmini', 'PDF metnini analiz edip en uygun çalışma süresini çıkarır.'),
                        _buildBenefitItem(Icons.quiz_rounded, 'AI Quiz & Sınav Sistemi', 'Çalışma bitiminde metinden otomatik 5 soruluk test üretir.'),
                        _buildBenefitItem(Icons.playlist_add_check_rounded, 'Yanlış Cevap Analizi', 'Sınavda yanlış yaptığın konuları tespit edip sana özel çalışma koçu notları sunar.'),
                        _buildBenefitItem(Icons.library_books_rounded, 'Sınırsız PDF Çalışma', 'Günlük limit olmadan dilediğin ders notu ve kitabı yükle.'),
                        _buildBenefitItem(Icons.music_note_rounded, 'Tüm Ortam Sesleri', 'Yağmur, orman, kafe gibi tüm rahatlatıcı zihin müziklerine eriş.'),
                        _buildBenefitItem(Icons.ad_units_rounded, 'Reklamsız Deneyim', 'Tamamen bölünmeden, saf odaklanma gücünü hisset.'),
                        
                        const SizedBox(height: 32),
                        
                        // Plan Cards
                        ...List.generate(3, (index) => _buildPlanCard(index)),
                        
                        const SizedBox(height: 24),
                        
                        // Buy Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing || premiumService.isPremium ? null : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                  )
                                : Text(
                                    premiumService.isPremium ? 'Zaten Premium Üyesin! ⭐' : 'Şimdi Abone Ol',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Footer terms
                        Text(
                          'İstediğin an Play Store ayarlarından aboneliğini iptal edebilirsin. Satın alma işlemi kullanım şartlarına tabidir.',
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.process.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.accent.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Radio button
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppColors.accent : AppColors.textSecondary, width: 2),
                  ),
                  child: Center(
                    child: isSelected
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['title'],
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan['description'],
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['price'],
                      style: GoogleFonts.poppins(color: isSelected ? AppColors.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      plan['period'],
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            
            // Badge / Tag
            if (plan['tag'] != null)
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                  child: Text(
                    plan['tag'],
                    style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
