import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';

void main() {
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
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent),
        ),
        hintStyle: TextStyle(color: mutedText),
        labelStyle: TextStyle(color: secondaryText),
      ),

      // 🗨️ Chips
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        labelStyle: TextStyle(color: textColor),
        selectedColor: accent.withOpacity(0.2),
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
      home: const InstagramDemoPage(),
    );
  }
}

class InstagramDemoPage extends StatelessWidget {
  const InstagramDemoPage({super.key});

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Follow User'),
            content: const Text('Do you want to follow this person?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are now following!')),
                  );
                },
                child: const Text('Follow'),
              ),
            ],
          ),
    );
  }

  void _showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message sent successfully!')));
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Share Post', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Iconic.link),
                  title: const Text('Copy link'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Iconic.paper_plane),
                  title: const Text('Send to...'),
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => const AlertDialog(
            title: Text('Learn More'),
            content: Text(
              'Instagram connects people through photos, videos, and stories. This demo mimics its UI feel using Flutter!',
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Instagram UI Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Welcome to Instagram!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showDialog(context),
              child: const Text('Follow'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => _showSnackbar(context),
              child: const Text('Message'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _showBottomSheet(context),
              child: const Text('Share'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _showInfoDialog(context),
              child: const Text('Learn more'),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This is a sample card',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'Comment')),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Flutter')),
                Chip(label: Text('Dart')),
                Chip(label: Text('Instagram')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
