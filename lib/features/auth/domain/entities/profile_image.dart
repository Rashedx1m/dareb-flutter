import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// صورة الملف الشخصي المختارة للرفع.
class ProfileImage extends Equatable {
  const ProfileImage({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  /// الخادم يقبل JPEG وPNG فقط (`users/update-image`).
  static const allowedTypes = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png'};

  /// نوع الملف من امتداده، أو `null` إن لم يكن مقبولاً.
  String? get contentType {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1) return null;
    return allowedTypes[fileName.substring(dot + 1).toLowerCase()];
  }

  @override
  List<Object?> get props => [bytes, fileName];
}
