import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/pages/auth/auth_screen.dart';
import 'package:instagram_clone/pages/screns/home_screen.dart';
import 'package:instagram_clone/riverpod/user_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.initialize();
  runApp(const InstagramApp());
}

class InstagramApp extends StatelessWidget {
  const InstagramApp({super.key});

  ThemeData _buildBaseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final primary = isDark ? Colors.white : Colors.black;
    final surface = isDark ? Colors.black : Colors.white;
    final background = isDark ? Colors.black : Colors.white;
    final divider = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final accent = Colors.pinkAccent;

    final textColor = primary.withValues(alpha: isDark ? 0.95 : 0.9);
    final secondaryText = isDark ? Colors.white70 : Colors.black87;
    final mutedText = isDark ? Colors.white54 : Colors.black54;

    return base.copyWith(
      scaffoldBackgroundColor: background,

      // 🎨 Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: surface,
        secondary: accent,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surface,
        onSurface: primary,
      ),

      // 🧱 Typography
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),

      // 🧭 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 🧭 Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),

      // 🧮 Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: divider),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),

      // 🪧 Card Theme
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // 💬 Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
        hintStyle: TextStyle(color: mutedText),
        labelStyle: TextStyle(color: secondaryText),
      ),

      // 🗨️ Chips
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        labelStyle: TextStyle(color: textColor),
        selectedColor: accent.withValues(alpha: 0.2),
        secondaryLabelStyle: TextStyle(color: accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // 📢 Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        contentTextStyle: TextStyle(color: textColor),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // 💬 Dialogs
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.inter(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.inter(color: secondaryText, fontSize: 15),
      ),

      // ✴️ Dividers
      dividerColor: divider,

      // 🖱️ Interactions
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: _buildBaseTheme(Brightness.light),
      darkTheme: _buildBaseTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ProviderScope(child: InstagramDemoPage()),
    );
  }
}

class InstagramDemoPage extends ConsumerWidget {
  const InstagramDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user != null) return const HomeScreen();
    return const AuthScreen();
  }
}
