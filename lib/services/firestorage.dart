import 'package:cloud_firestore/cloud_firestore.dart';

class Firestorage {
  final String path;

  Firestorage(this.path);

  Future<DocumentSnapshot> insert({Map<String, dynamic> data}) async {
    final docRef = Firestore.instance.collection(path).document();
    await docRef.setData(data);
    return docRef.get(source: Source.cache);
  }

  Future<DocumentSnapshot> insertSubDocument({
    String docId,
    String subCollection,
    String id,
    Map<String, dynamic> data,
  }) async {
    final colRef = Firestore.instance
        .collection(path)
        .document(docId)
        .collection(subCollection);

    DocumentReference docRef;
    if (id != null) {
      docRef = colRef.document(id);
      docRef.setData(data);
    } else {
      docRef = await colRef.add(data);
    }
    return await docRef.get(source: Source.cache);
  }

  Future<List<DocumentSnapshot>> insertSubCollection({
    String docId,
    String subCollection,
    List<Map<String, dynamic>> data,
  }) async {
    List<DocumentSnapshot> result = [];
    List<DocumentReference> refs = [];
    final colRef = Firestore.instance
        .collection(path)
        .document(docId)
        .collection(subCollection);
    final batch = Firestore.instance.batch();

    for (var item in data) {
      final docRef = colRef.document();
      batch.setData(docRef, item);
      refs.add(docRef);
    }
    await batch.commit();
    for (var ref in refs) {
      result.add(await ref.get(source: Source.cache));
    }
    return result;
  }

  Future update({String docId, Map<String, dynamic> data}) async {
    final docRef = Firestore.instance.collection(path).document(docId);
    return docRef.updateData(data);
  }

  Future updateSubDoc(
      {String parentId,
      String subCollection,
      String documentId,
      Map<String, dynamic> data}) async {
    final docRef = Firestore.instance
        .collection(path)
        .document(parentId)
        .collection(subCollection)
        .document(documentId);
    await docRef.updateData(data);
  }

  Future delete({String docId}) async {
    final docRef = Firestore.instance.collection(path).document(docId);
    return docRef.delete();
  }

  Future deleteSubDocument({
    String parentId,
    String subCollection,
    String docId,
  }) {
    final colRef = Firestore.instance
        .collection(path)
        .document(parentId)
        .collection(subCollection);
    return colRef.document(docId).delete();
  }

  Stream<DocumentSnapshot> getDocumentById({String documentId}) {
    return Firestore.instance.collection(path).document(documentId).snapshots();
  }

  Stream<QuerySnapshot> getSubCollection(String docId, String subCollection) =>
      Firestore.instance
          .collection(path)
          .document(docId)
          .collection(subCollection)
          .orderBy("createdAt", descending: true)
          .snapshots();

  Stream<DocumentSnapshot> getSubDocument(String docId, String subDocument) =>
      Firestore.instance
          .collection(path)
          .document('$docId/$subDocument')
          .snapshots();

  Stream<QuerySnapshot> getDocument(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic> arrayContainsAny,
    List<dynamic> whereIn,
    bool isNull,
  }) {
    return Firestore.instance
        .collection(path)
        .where(field,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isLessThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            arrayContains: arrayContains,
            arrayContainsAny: arrayContainsAny,
            whereIn: whereIn)
        .snapshots()
        .take(1);
  }
}
