import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import '../controllers/theme_controller.dart';

/// Theme Toggle Widget - Switch between Light/Dark/System themes
class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? AppColors.darkCard
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // Light Mode Button
            _buildThemeOption(
              icon: Icons.light_mode_outlined,
              activeIcon: Icons.light_mode,
              label: 'Terang',
              isActive: controller.isLightMode,
              onTap: () => controller.setThemeMode(ThemeMode.light),
            ),

            // System Mode Button
            _buildThemeOption(
              icon: Icons.devices_outlined,
              activeIcon: Icons.devices,
              label: 'Sistem',
              isActive: controller.isSystemMode,
              onTap: () => controller.setThemeMode(ThemeMode.system),
            ),

            // Dark Mode Button
            _buildThemeOption(
              icon: Icons.dark_mode_outlined,
              activeIcon: Icons.dark_mode,
              label: 'Gelap',
              isActive: controller.isDarkMode,
              onTap: () => controller.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (Get.isDarkMode ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Get.isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive
                    ? AppColors.orange
                    : (Get.isDarkMode
                        ? AppColors.darkTextSecondary
                        : Colors.grey.shade600),
              ),
              if (showLabel) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? (Get.isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)
                        : (Get.isDarkMode
                            ? AppColors.darkTextSecondary
                            : Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple theme toggle switch (icon only)
class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            controller.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
            key: ValueKey(controller.isDarkMode),
            size: 24,
            color: AppColors.orange,
          ),
        ),
        onPressed: () => controller.toggleTheme(),
        tooltip: controller.isDarkMode
            ? 'Switch to Light Mode'
            : 'Switch to Dark Mode',
      ),
    );
  }
}
