import 'package:flutter/material.dart';


class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 72,
    this.borderRadius = 18,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    // Jalur gambar logo yang dapat ditaruh user
    const assetPath = 'assets/images/app_logo.png';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF137FEC).withOpacity(0.35),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: size * 0.15,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback elegan jika user belum menempelkan file app_logo.png
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF137FEC),
                    Color(0xFF38EF7D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.account_tree_rounded,
                      color: Colors.white,
                      size: size * 0.52,
                    ),
                    Positioned(
                      right: size * 0.15,
                      top: size * 0.18,
                      child: Container(
                        width: size * 0.18,
                        height: size * 0.18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: size * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
