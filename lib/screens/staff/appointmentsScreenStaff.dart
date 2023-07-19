import 'package:airbnb_scheduler/screens/staff/appointmentDetailsScreenStaff.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class appointmentsScreenStaff extends StatefulWidget {
  const appointmentsScreenStaff({super.key, required this.unitName});

  final unitName;

  @override
  State<appointmentsScreenStaff> createState() =>
      _appointmentsScreenStaffState();
}

class _appointmentsScreenStaffState extends State<appointmentsScreenStaff> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.unitName),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('units')
              .doc(widget.unitName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic>? documentData =
                  snapshot.data?.data() as Map<String, dynamic>?;

              if (documentData != null) {
                List<dynamic>? appointmentsArray =
                    documentData['appointments'] as List<dynamic>?;

                if (appointmentsArray != null) {
                  appointmentsArray.sort((a, b) {
                    Timestamp? startTimeA = a['timestamp'] as Timestamp?;
                    Timestamp? startTimeB = b['timestamp'] as Timestamp?;
                    DateTime? startDateA = startTimeA?.toDate();
                    DateTime? startDateB = startTimeB?.toDate();
                    return startDateB!.compareTo(startDateA!);
                  });

                  return ListView.builder(
                    itemCount: appointmentsArray.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? appointmentMap =
                          appointmentsArray[index] as Map<String, dynamic>?;

                      if (appointmentMap != null) {
                        String? subject = appointmentMap['subject'] as String?;
                        Timestamp? startTime =
                            appointmentMap['startTime'] as Timestamp?;
                        Timestamp? timestamp =
                            appointmentMap['timestamp'] as Timestamp?;

                        DateTime? startDate = startTime?.toDate();
                        DateTime? timestampdate = timestamp?.toDate();

                        String dateTextCheckIn =
                            DateFormat('MMMM dd, yyyy').format(startDate!);
                        String timestampformat =
                            DateFormat('MMMM dd, yyyy hh:mm a')
                                .format(timestampdate!);

                        String? id = appointmentMap['id'] as String?;

                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            elevation: 20,
                            shadowColor: const Color(0xff4E6C50),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) {
                                    return appointmentDetailsScreenStaff(
                                        unitName: widget.unitName, id: id);
                                  }),
                                );
                                print(id);
                              },
                              child: ListTile(
                                title: Text(
                                  subject ?? '',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Booking created at:'),
                                        Text(timestampformat),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Check-in at:'),
                                        Text(
                                          dateTextCheckIn,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return const ListTile(
                        title: Text('Invalid appointment'),
                      );
                    },
                  );
                }
              }
            }

            return const Center(child: Text('No Bookings available'));
          },
        ));
  }
}
