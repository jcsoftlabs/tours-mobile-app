import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Production URL
  static const String productionUrl = 'https://discover-ht-production.up.railway.app';
  
  // Base URLs pour développement local
  static const String baseUrlHttp = 'http://localhost:3000';
  static const String baseUrlHttps = 'https://localhost:3443';
  
  // URLs pour différentes plateformes (développement)
  static const String baseUrlAndroidEmulator = 'http://10.0.2.2:3000';
  static const String baseUrlIOSSimulator = 'http://127.0.0.1:3000';
  
  // Mode de déploiement
  static const bool useProduction = true; // Changer à false pour utiliser le backend local
  
  // Configuration selon la plateforme
  static String get baseUrl {
    // Si mode production, utiliser l'URL de production
    if (useProduction) {
      return productionUrl;
    }
    
    // Sinon, utiliser l'URL locale selon la plateforme
    if (kIsWeb) {
      return baseUrlHttp;
    } else if (Platform.isAndroid) {
      return baseUrlAndroidEmulator;
    } else if (Platform.isIOS) {
      return baseUrlIOSSimulator;
    } else {
      return baseUrlHttp;
    }
  }
  
  // API Endpoints
  static const String apiPath = '/api';
  
  // Authentication
  static const String authRegister = '$apiPath/auth/register';
  static const String authLogin = '$apiPath/auth/login';
  static const String authLogout = '$apiPath/auth/logout';
  static const String authProfile = '$apiPath/auth/me';
  static const String authRequestReset = '$apiPath/auth/request-reset';
  static const String authResetPassword = '$apiPath/auth/reset-password';
  
  // Establishments
  static const String establishments = '$apiPath/establishments';
  static String establishmentById(String id) => '$establishments/$id';
  
  // Sites
  static const String sites = '$apiPath/sites';
  static String siteById(String id) => '$sites/$id';
  
  // Reviews
  static const String reviews = '$apiPath/reviews';
  static String reviewsByEstablishment(String establishmentId) => 
      '$reviews?establishmentId=$establishmentId';
  static String reviewStats(String establishmentId) =>
      '$reviews/establishment/$establishmentId/stats';
  static String reviewById(String id) => '$reviews/$id';
  
  // Notifications
  static const String notifications = '$apiPath/notifications';
  static String notificationById(String id) => '$notifications/$id';
  static const String notificationsUnreadCount = '$notifications/unread/count';
  static const String notificationsMarkAllRead = '$notifications/mark-all-read';
  static String notificationMarkAsRead(String id) => '$notifications/$id/read';
  static const String notificationCreateInvitation = '$notifications/review-invitation';
  
  // Favorites
  static const String favorites = '$apiPath/favorites';
  static String favoriteById(String id) => '$favorites/$id';
  
  // User
  static const String users = '$apiPath/users';
  static String userById(String id) => '$users/$id';
  
  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}