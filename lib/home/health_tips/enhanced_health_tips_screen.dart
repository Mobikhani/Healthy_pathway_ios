import '../../services/unlimited_health_tips_service.dart';

class EnhancedHealthTipsScreen extends StatefulWidget {
  // ... (existing code)
}

class _EnhancedHealthTipsScreenState extends State<EnhancedHealthTipsScreen> {
  // ... (existing code)

  Future<void> _generateNewTip() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final newTip = await UnlimitedHealthTipsService.generateHealthTip(selectedCategory);
      if (mounted) {
        setState(() {
          currentTip = newTip;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentTip = 'Stay healthy and happy!';
          isLoading = false;
        });
      }
    }
  }

  // ... (rest of the existing code)
} 