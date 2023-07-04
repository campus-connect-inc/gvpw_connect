class User {
  final String name;
  final String rollNo;
  final String email;
  final String department;
  final String phoneNo;
  final String? personalEmail;
  final String? careTakerPhoneNo;
  final String? secondaryPhoneNo;

  User({
    required Map<String, dynamic> userData,
  })  : name = userData['name'] ?? '',
        rollNo = userData['rollNo'] ?? '',
        email = userData['email'] ?? '',
        department = userData['department'] ?? '',
        phoneNo = userData['phoneNo'] ?? '',
        personalEmail = userData['personalEmail'],
        careTakerPhoneNo = userData['careTakerPhoneNo'],
        secondaryPhoneNo = userData['secondaryPhoneNo'];

  List<Survey> get surveys {
    // TODO: Implement fetching filled survey docs from surveys collection
    // You can use Firebase Firestore to fetch the survey data for the user
    // and map it to a list of `Survey` objects.
    // Example:
    // 1. Query the Firestore collection for the user's filled surveys
    // 2. Iterate over the query snapshot and create `Survey` objects
    // 3. Return the list of `Survey` objects
    return [];
  }
}

class Survey {
  // Add properties for survey data, such as title, date, etc.
  // Example:
  // final String title;
  // final DateTime date;

  // Add constructor and any additional methods or properties you need
}
