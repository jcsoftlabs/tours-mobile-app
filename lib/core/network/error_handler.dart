import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ErrorHandler {
  /// Convertit une exception en message utilisateur-friendly
  /// en masquant les informations sensibles comme les URLs
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    if (error is DioException) {
      return _handleDioError(error, context: context);
    } else if (error is SocketException) {
      return _getNetworkErrorMessage();
    } else if (error is HttpException) {
      return _getNetworkErrorMessage();
    } else if (error is FormatException) {
      return 'Erreur de format des données';
    } else {
      return 'Une erreur inattendue s\'est produite';
    }
  }

  static String _handleDioError(DioException error, {String? context}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La connexion a pris trop de temps. Veuillez réessayer.';
      
      case DioExceptionType.connectionError:
        return _getNetworkErrorMessage();
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response, context: context);
      
      case DioExceptionType.cancel:
        return 'La requête a été annulée';
      
      case DioExceptionType.unknown:
        // Vérifier si c'est une erreur réseau
        if (error.error is SocketException || 
            error.error is HttpException ||
            error.message?.contains('SocketException') == true ||
            error.message?.contains('Failed host lookup') == true) {
          return _getNetworkErrorMessage();
        }
        return 'Une erreur de connexion s\'est produite';
      
      default:
        return 'Une erreur de connexion s\'est produite';
    }
  }

  static String _handleBadResponse(Response? response, {String? context}) {
    if (response == null) {
      return 'Erreur de communication avec le serveur';
    }

    final statusCode = response.statusCode ?? 0;
    
    // Tenter d'extraire un message d'erreur du serveur
    String? serverMessage;
    if (response.data is Map) {
      serverMessage = response.data['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Données invalides';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Vous n\'avez pas les permissions nécessaires';
      case 404:
        if (context != null) {
          return '$context introuvable';
        }
        return 'Ressource introuvable';
      case 409:
        return serverMessage ?? 'Cette donnée existe déjà';
      case 422:
        return serverMessage ?? 'Données invalides';
      case 429:
        return 'Trop de tentatives. Veuillez patienter.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Le serveur rencontre des difficultés. Veuillez réessayer plus tard.';
      default:
        if (statusCode >= 500) {
          return 'Erreur serveur. Veuillez réessayer plus tard.';
        }
        return serverMessage ?? 'Une erreur s\'est produite';
    }
  }

  static String _getNetworkErrorMessage() {
    return 'Impossible de se connecter à Internet. Vérifiez votre connexion et réessayez.';
  }

  /// Vérifie si une erreur est une erreur réseau
  static bool isNetworkError(dynamic error) {
    if (error is SocketException || error is HttpException) {
      return true;
    }
    
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
             error.type == DioExceptionType.connectionTimeout ||
             error.error is SocketException ||
             error.error is HttpException ||
             error.message?.contains('SocketException') == true ||
             error.message?.contains('Failed host lookup') == true;
    }
    
    return false;
  }

  /// Log l'erreur pour le débogage (ne doit jamais être affiché à l'utilisateur)
  static void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    // En développement seulement, on peut log plus de détails
    if (kDebugMode) {
      debugPrint('=== Error Log ===');
      if (context != null) {
        debugPrint('Context: $context');
      }
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      debugPrint('=================');
    }
  }
}
