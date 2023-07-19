import 'package:airbnb_scheduler/screens/appointmentDetailsEditScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class appointmentDetailsScreen extends StatefulWidget {
  const appointmentDetailsScreen(
      {super.key, required this.unitName, required this.id});

  final unitName;
  final id;

  @override
  State<appointmentDetailsScreen> createState() =>
      _appointmentDetailsScreenState();
}

class _appointmentDetailsScreenState extends State<appointmentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.unitName)),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('units')
              .doc(widget.unitName)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic>? unitData = snapshot.data!.data();
              if (unitData != null && unitData.containsKey('appointments')) {
                List<dynamic>? appointments = unitData['appointments'];
                if (appointments != null) {
                  List<dynamic> filteredAppointments = appointments
                      .where((appointment) =>
                          appointment is Map<String, dynamic> &&
                          appointment.containsKey('id') &&
                          appointment['id'] == widget.id)
                      .toList();

                  if (filteredAppointments.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (BuildContext context, int index) {
                        dynamic appointmentData = filteredAppointments[index];
                        String title = appointmentData['subject'];
                        String id = appointmentData['id'];
                        String phone = appointmentData['phone'];
                        String req = appointmentData['requests'];
                        Timestamp timestamp = appointmentData['timestamp'];

                        DateTime timestampval = timestamp.toDate();

                        Timestamp? startTime =
                            appointmentData['startTime'] as Timestamp?;
                        Timestamp? endTime =
                            appointmentData['endTime'] as Timestamp?;
                        DateTime startTimeValue =
                            startTime?.toDate() ?? DateTime.now();
                        DateTime endTimeValue =
                            endTime?.toDate() ?? DateTime.now();

                        String dateTextCheckIn =
                            DateFormat('MMMM dd, yyyy').format(startTimeValue);
                        String dateTextCheckOut =
                            DateFormat('MMMM dd, yyyy').format(endTimeValue);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'ID: $id',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Name: $title',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Check-in: $dateTextCheckIn',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Check-out: $dateTextCheckOut',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Phone: $phone',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Request: $req',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 50.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(builder: (context) {
                                          return appointmentDetailsEditScreen(
                                            unitName: widget.unitName,
                                            id: widget.id,
                                            subject: title,
                                            phone: phone,
                                            req: req,
                                            checkin: startTimeValue,
                                            checkout: endTimeValue,
                                            timestamp: timestampval,
                                          );
                                        }),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff820000),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18))),
                                    child: const Text('Edit'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text('No matching appointments found'));
                  }
                }
              }
            }

            return const Center(child: Text('No appointments found'));
          },
        ));
  }
}