// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      establishmentId: json['establishmentId'] as String?,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'establishmentId': instance.establishmentId,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.reviewInvitation: 'REVIEW_INVITATION',
  NotificationType.promotion: 'PROMOTION',
  NotificationType.system: 'SYSTEM',
  NotificationType.other: 'OTHER',
};

ReviewStats _$ReviewStatsFromJson(Map<String, dynamic> json) => ReviewStats(
  establishmentId: json['establishmentId'] as String,
  establishmentName: json['establishmentName'] as String,
  totalReviews: (json['totalReviews'] as num).toInt(),
  averageRating: (json['averageRating'] as num).toDouble(),
  ratingDistribution: Map<String, int>.from(json['ratingDistribution'] as Map),
);

Map<String, dynamic> _$ReviewStatsToJson(ReviewStats instance) =>
    <String, dynamic>{
      'establishmentId': instance.establishmentId,
      'establishmentName': instance.establishmentName,
      'totalReviews': instance.totalReviews,
      'averageRating': instance.averageRating,
      'ratingDistribution': instance.ratingDistribution,
    };
