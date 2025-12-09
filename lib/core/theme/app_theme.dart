import 'package:flutter/material.dart';

/// Thème inspiré du tourisme haïtien avec des couleurs tropicales
class AppTheme {
  // Palette de couleurs tropicales haïtiennes
  static const Color caribbeanTurquoise = Color(0xFF4D6491); // Bleu primaire moderne
  static const Color coralSunset = Color(0xFFFF6B6B); // Corail coucher de soleil
  static const Color sunshineYellow = Color(0xFFFFD93D); // Jaune soleil tropical
  static const Color tropicalGreen = Color(0xFF2ECC71); // Vert végétation tropicale
  static const Color oceanBlue = Color(0xFF1E88E5); // Bleu océan
  static const Color palmGreen = Color(0xFF27AE60); // Vert palmier
  static const Color sandBeige = Color(0xFFF5E6D3); // Beige sable
  static const Color hibiscusRed = Color(0xFFE74C3C); // Rouge hibiscus
  
  // Couleurs neutres (thème clair)
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color charcoal = Color(0xFF2C3E50);
  
  // Couleurs pour thème sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color lightText = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // Couleurs sémantiques
  static const Color success = tropicalGreen;
  static const Color warning = sunshineYellow;
  static const Color error = hibiscusRed;
  static const Color info = oceanBlue;

  // Espacements et tailles
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  
  // Rayons de bordure
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 999.0;
  
  // Tailles minimum pour accessibilité
  static const double minTouchTarget = 48.0;
  static const double minButtonHeight = 52.0;
  
  // Durées d'animation
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Palette de couleurs principale
      colorScheme: const ColorScheme.light(
        primary: caribbeanTurquoise,
        onPrimary: white,
        primaryContainer: Color(0xFFB2EBF2),
        onPrimaryContainer: charcoal,
        
        secondary: coralSunset,
        onSecondary: white,
        secondaryContainer: Color(0xFFFFCDD2),
        onSecondaryContainer: charcoal,
        
        tertiary: sunshineYellow,
        onTertiary: charcoal,
        tertiaryContainer: Color(0xFFFFF9C4),
        onTertiaryContainer: charcoal,
        
        error: error,
        onError: white,
        errorContainer: Color(0xFFFFCDD2),
        onErrorContainer: charcoal,
        
        surface: white,
        onSurface: charcoal,
        surfaceContainerHighest: lightGray,
        onSurfaceVariant: darkGray,
        
        outline: mediumGray,
        outlineVariant: lightGray,
        
        shadow: Colors.black26,
      ),
      
      // Typographie moderne et lisible
      textTheme: const TextTheme(
        // Titres
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.12,
          color: charcoal,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
          color: charcoal,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
          color: charcoal,
        ),
        
        // En-têtes
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
          color: charcoal,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
          color: charcoal,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
          color: charcoal,
        ),
        
        // Titres
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
          color: charcoal,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          color: charcoal,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: charcoal,
        ),
        
        // Corps de texte
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
          color: charcoal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: charcoal,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: darkGray,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: charcoal,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: charcoal,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: darkGray,
        ),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: caribbeanTurquoise,
        foregroundColor: white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: white,
          size: 24,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: white,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(
            color: lightGray,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: caribbeanTurquoise,
          foregroundColor: white,
          disabledBackgroundColor: mediumGray,
          disabledForegroundColor: darkGray,
          minimumSize: const Size(88, minButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: caribbeanTurquoise,
          minimumSize: const Size(64, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Boutons outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: caribbeanTurquoise,
          side: const BorderSide(
            color: caribbeanTurquoise,
            width: 1.5,
          ),
          minimumSize: const Size(88, minButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: caribbeanTurquoise,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: white,
        selectedItemColor: caribbeanTurquoise,
        unselectedItemColor: darkGray,
        selectedIconTheme: IconThemeData(
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        elevation: 8,
      ),
      
      // Dividers
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 1,
      ),
      
      // Icons
      iconTheme: const IconThemeData(
        color: charcoal,
        size: 24,
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        disabledColor: mediumGray,
        selectedColor: caribbeanTurquoise,
        secondarySelectedColor: coralSunset,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing12,
          vertical: spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Palette de couleurs pour le mode sombre
      colorScheme: const ColorScheme.dark(
        primary: caribbeanTurquoise,
        onPrimary: white,
        primaryContainer: Color(0xFF1A3A52),
        onPrimaryContainer: Color(0xFFB2EBF2),
        
        secondary: coralSunset,
        onSecondary: white,
        secondaryContainer: Color(0xFF4A1F1F),
        onSecondaryContainer: Color(0xFFFFCDD2),
        
        tertiary: sunshineYellow,
        onTertiary: charcoal,
        tertiaryContainer: Color(0xFF4A4520),
        onTertiaryContainer: Color(0xFFFFF9C4),
        
        error: error,
        onError: white,
        errorContainer: Color(0xFF4A1F1F),
        onErrorContainer: Color(0xFFFFCDD2),
        
        surface: darkSurface,
        onSurface: lightText,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: mediumGray,
        
        outline: darkBorder,
        outlineVariant: Color(0xFF2A2A2A),
        
        shadow: Colors.black54,
      ),
      
      // Typographie pour mode sombre
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.12,
          color: lightText,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
          color: lightText,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
          color: lightText,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
          color: lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
          color: lightText,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
          color: lightText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
          color: lightText,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
          color: lightText,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
          color: lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: lightText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: mediumGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: lightText,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: lightText,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: mediumGray,
        ),
      ),
      
      // AppBar pour mode sombre
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: lightText,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightText,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: lightText,
          size: 24,
        ),
      ),
      
      // Cards pour mode sombre
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(
            color: darkBorder,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Boutons élevés pour mode sombre
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: caribbeanTurquoise,
          foregroundColor: white,
          disabledBackgroundColor: Color(0xFF3A3A3A),
          disabledForegroundColor: mediumGray,
          minimumSize: const Size(88, minButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Boutons texte pour mode sombre
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: caribbeanTurquoise,
          minimumSize: const Size(64, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Boutons outlined pour mode sombre
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: caribbeanTurquoise,
          side: const BorderSide(
            color: caribbeanTurquoise,
            width: 1.5,
          ),
          minimumSize: const Size(88, minButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Champs de saisie pour mode sombre
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: caribbeanTurquoise,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
      ),
      
      // Bottom Navigation Bar pour mode sombre
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkSurface,
        selectedItemColor: caribbeanTurquoise,
        unselectedItemColor: mediumGray,
        selectedIconTheme: IconThemeData(
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        elevation: 8,
      ),
      
      // Dividers pour mode sombre
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      
      // Icons pour mode sombre
      iconTheme: const IconThemeData(
        color: lightText,
        size: 24,
      ),
      
      // Chips pour mode sombre
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        disabledColor: Color(0xFF2A2A2A),
        selectedColor: caribbeanTurquoise,
        secondarySelectedColor: coralSunset,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing12,
          vertical: spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}

/// Extension pour accéder facilement aux couleurs personnalisées
extension AppThemeExtension on ThemeData {
  Color get caribbeanTurquoise => AppTheme.caribbeanTurquoise;
  Color get coralSunset => AppTheme.coralSunset;
  Color get sunshineYellow => AppTheme.sunshineYellow;
  Color get tropicalGreen => AppTheme.tropicalGreen;
  Color get oceanBlue => AppTheme.oceanBlue;
  Color get sandBeige => AppTheme.sandBeige;
}
