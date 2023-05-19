// ignore_for_file: avoid_print

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firedart/firedart.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

/// Pastèque-Match Database Importer
/// A Dart script to import a CSV file to the Firestore database
void main(List<String> rawArgs) async {
  print('############ Pastèque-Match Database Builder ############');

  // Check args
  if (rawArgs.length != 3) {
    print('Arguments must be "[email] [password] [input file]"');
    exit(0);
  }
  final authEmail = rawArgs[0];
  final authPassword = rawArgs[1];
  final filePath = rawArgs[2];

  // Ask user to check database status
  print('If you have removed names since last update, you should first completely deleted the "names" collection in the database as the script won\'t remove them.\nDo you want to continue anyway ?');
  var response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') {
    exit(0);
  }

  // Admin authentication
  print('Authentication');
  final firebaseAuth = FirebaseAuth('AIzaSyAsPG2NCnMxGCSTPE9R-2kuHwZYITy9QN4', VolatileStore());
  await firebaseAuth.signIn(authEmail, authPassword);
  final user = await firebaseAuth.getUser();
  print('Logged-in as ${user.email}');

  // Read file
  print('Load file');
  final file = File(filePath);
  if(!await file.exists()) {
    print('File does not exists');
    exit(0);
  }
  final csvRaw = await file.readAsString();
  print('File loaded');

  // Read CSV
  print('Start converting');
  final csvRows = const CsvToListConverter(fieldDelimiter: ';').convert(csvRaw);

  // Convert to dart class
  final names = <Name>[];
  for (final row in csvRows) {
    // Name
    final rawNames = (row[0] as String).split('/');
    final name = rawNames.first.trim();
    final otherNames = rawNames.length >= 2 ? rawNames.skip(1).map((name) => name.trim()).toList(growable: false) : const <String>[];

    // Gender
    final gender = NameGender.values.firstWhereOrNull((value) => value.name == row[1]);
    if (name.isEmpty || gender == null) continue;

    // Build object
    names.add(Name(
      name: name,
      gender: gender,
      otherNames: otherNames,
      stats: NameQuantityStatistics(),    // TODO
    ));
  }
  print('${names.length} elements converted');

  // Ask confirmation
  print('Are you sure you want to overwrite ${names.length} names to the database ?');
  response = stdin.readLineSync();
  if (response != 'y' && response != 'yes') exit(0);

  // Send data to database
  print('Sending data to database');
  Firestore.initialize('pasteque-match');
  final collectionRef = Firestore.instance.collection("names");
  for (final name in names) {
    print('Sending ${name.name}');
    await collectionRef.document(name.id).set(name.toJson());
  }
  print('Data sent');

  // Sign out
  firebaseAuth.signOut();

  // Exit program
  exit(0);
}
