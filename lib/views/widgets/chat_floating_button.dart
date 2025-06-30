import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class ChatFloatingButton extends StatefulWidget {
  const ChatFloatingButton({super.key});

  @override
  State<ChatFloatingButton> createState() => _ChatFloatingButtonState();
}

class _ChatFloatingButtonState extends State<ChatFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // TODO: سيتم تطوير المحادثة لاحقاً
    _navigateToChat();
  }

  void _navigateToChat() {
    // للمستقبل: الانتقال لصفحة المحادثات
    Get.snackbar(
      'المحادثات',
      'ميزة المحادثة قيد التطوير وستكون متاحة قريباً',
      backgroundColor: AppColors.info,
      colorText: AppColors.textWhite,
      icon: const Icon(Icons.info, color: AppColors.textWhite),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );

    // في المستقبل سيكون:
    // Get.toNamed('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90, // فوق الـ Bottom Navigation Bar
      left: 16, // في الزاوية اليسرى (RTL)
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onTap,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // أيقونة المحادثة
                          const Icon(
                            Icons.chat_bubble_rounded,
                            color: AppColors.textWhite,
                            size: 28,
                          ),

                          // نقطة الإشعار (للمستقبل)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.textWhite,
                                    shape: BoxShape.circle,
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
            ),
          );
        },
      ),
    );
  }
}

// صفحة المحادثات المؤقتة (للمستقبل)
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.gray400,
            ),
            SizedBox(height: 16),
            Text(
              'ميزة المحادثة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'قيد التطوير وستكون متاحة قريباً',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              '💬 محادثة مع الأطباء\n📝 إرسال الملفات والصور\n🔔 إشعارات فورية',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
