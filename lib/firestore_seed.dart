import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedTestData() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Add a test user
  final userRef = firestore.collection('Users').doc('test_user_1');
  await userRef.set({
    'name': 'Test User',
    'email': 'test@example.com',
    'lang': 'ar',
    'created_at': FieldValue.serverTimestamp(),
  });

  // 2. Add a test chat
  final chatRef = firestore.collection('Chats').doc('chat_session_1');
  await chatRef.set({
    'user_id': 'test_user_1',
    'timestamp': FieldValue.serverTimestamp(),
    'messages': [
      {
        'sender': 'user',
        'text': 'أنا حاسس بوحدة',
        'emotion': 'sadness',
        'time': Timestamp.now(),
      },
      {
        'sender': 'sara',
        'text': 'أنا هنا علشان أسمعك، تحب تحكيلي أكتر؟',
        'emotion': 'empathetic',
        'time': Timestamp.now(),
      },
    ],
  });

  // 3. Add sample doctors
  final doctors = [
    {
      'name': 'د. إيمان عادل',
      'specialization': 'علاج القلق',
      'city': 'القاهرة',
      'rating': 4.8,
      'contact': '+201234567890',
    },
    {
      'name': 'د. هاني يوسف',
      'specialization': 'اكتئاب نفسي',
      'city': 'الإسكندرية',
      'rating': 4.5,
      'contact': '+201112223344',
    }
  ];

  for (final doc in doctors) {
    await firestore.collection('Doctors').add(doc);
  }

  // 4. Add feedback
  await firestore.collection('Feedback').add({
    'user_id': 'test_user_1',
    'rating': 5,
    'comment': 'التطبيق ممتاز ومفيد جدًا',
    'submitted_at': FieldValue.serverTimestamp(),
  });

  print('✅ Dummy data added successfully!');
}
