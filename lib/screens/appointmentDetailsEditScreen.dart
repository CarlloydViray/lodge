import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class appointmentDetailsEditScreen extends StatefulWidget {
  const appointmentDetailsEditScreen(
      {super.key,
      required this.unitName,
      required this.id,
      required this.subject,
      required this.num,
      required this.phone,
      required this.req,
      required this.checkin,
      required this.checkout,
      required this.timestamp});

  final unitName;
  final id;
  final subject;
  final num;
  final phone;
  final req;
  final checkin;
  final checkout;
  final timestamp;

  @override
  State<appointmentDetailsEditScreen> createState() =>
      _appointmentDetailsEditScreenState();
}

class _appointmentDetailsEditScreenState
    extends State<appointmentDetailsEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final numKey = GlobalKey<FormFieldState<String>>();
  final nameKey = GlobalKey<FormFieldState<String>>();
  TextEditingController idController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController reqController = TextEditingController();
  TextEditingController numContoller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      idController.text = widget.id;
      titleController.text = widget.subject;
      phoneController.text = widget.phone;
      reqController.text = widget.req;
      numContoller.text = widget.num;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: idController,
                      readOnly: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ID',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      key: nameKey,
                      controller: titleController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      key: numKey,
                      controller: numContoller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: const InputDecoration(
                        labelText: 'Number of Guests',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a number of guests.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: reqController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: const InputDecoration(
                        labelText: 'Request',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff820000),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid, proceed with saving
                          DocumentSnapshot<Map<String, dynamic>>
                              appointmentsSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('units')
                                  .doc(widget.unitName)
                                  .get();

                          List<dynamic> appointments =
                              appointmentsSnapshot.data()?['appointments'] ??
                                  [];

                          Map<String, dynamic> updatedData = {
                            'timestamp': widget.timestamp,
                            'startTime': widget.checkin,
                            'endTime': widget.checkout,
                            'subject': titleController.text,
                            'guests': numContoller.text,
                            'phone': phoneController.text,
                            'requests': reqController.text,
                            'id': widget.id
                          };

                          List<Map<String, dynamic>> updatedAppointments =
                              appointments
                                  .map<Map<String, dynamic>>((appointment) {
                            if (appointment is Map<String, dynamic> &&
                                appointment['id'] == widget.id) {
                              return updatedData;
                            } else {
                              return appointment;
                            }
                          }).toList();

                          await FirebaseFirestore.instance
                              .collection('units')
                              .doc(widget.unitName)
                              .update({
                            'appointments': updatedAppointments,
                          });
                          Navigator.pop(context);
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            title: 'Booking Info Updated',
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(date);
  }
}
