import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseEntity {
  String id;
  dynamic createdAt;

  Map<String, dynamic> toJson() => {
        'createdAt': FieldValue.serverTimestamp(),
      };
}
