import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() =>
      _AddressScreenState();
}

class _AddressScreenState
    extends State<AddressScreen> {
  List<Map<String, dynamic>> addresses = [
    {
      'id': '1',
      'type': 'Home',
      'name': 'Manoj Kumar',
      'phone': '+91 9876543210',
      'address':
          'Hitech City, Hyderabad, Telangana - 500081',
      'default': true,
    },
    {
      'id': '2',
      'type': 'Work',
      'name': 'Manoj Kumar',
      'phone': '+91 9876543210',
      'address':
          'Mindspace IT Park, Hyderabad, Telangana',
      'default': false,
    },
  ];

  Future<void> refreshAddresses() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void setDefaultAddress(int index) {
    setState(() {
      for (var item in addresses) {
        item['default'] = false;
      }

      addresses[index]['default'] = true;
    });
  }

  void deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Address deleted'),
      ),
    );
  }

  void showAddAddressDialog() {
    final nameController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final addressController =
        TextEditingController();

    String selectedType = 'Home';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:
                  const Text('Add Address'),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          nameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Name',
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    TextField(
                      controller:
                          phoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Phone Number',
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'Home',
                          child:
                              Text('Home'),
                        ),
                        DropdownMenuItem(
                          value: 'Work',
                          child:
                              Text('Work'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child:
                              Text('Other'),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setDialogState(
                          () {
                            selectedType =
                                value!;
                          },
                        );
                      },
                    ),

                    const SizedBox(
                        height: 12),

                    TextField(
                      controller:
                          addressController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Address',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context);
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController
                            .text
                            .isEmpty ||
                        phoneController
                            .text
                            .isEmpty ||
                        addressController
                            .text
                            .isEmpty) {
                      return;
                    }

                    setState(() {
                      addresses.add({
                        'id': DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        'type':
                            selectedType,
                        'name':
                            nameController
                                .text,
                        'phone':
                            phoneController
                                .text,
                        'address':
                            addressController
                                .text,
                        'default':
                            false,
                      });
                    });

                    Navigator.pop(
                        context);
                  },
                  child:
                      const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color getTypeColor(
    String type,
  ) {
    switch (type) {
      case 'Home':
        return Colors.green;

      case 'Work':
        return Colors.blue;

      default:
        return Colors.orange;
    }
  }

  IconData getTypeIcon(
    String type,
  ) {
    switch (type) {
      case 'Home':
        return Icons.home;

      case 'Work':
        return Icons.work;

      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Saved Addresses',
        ),
      ),

      body: RefreshIndicator(
        onRefresh:
            refreshAddresses,
        child: addresses.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                itemCount:
                    addresses.length,
                itemBuilder:
                    (context, index) {
                  final address =
                      addresses[index];

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(
                                  8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: getTypeColor(
                                          address[
                                              'type'])
                                      .withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: Icon(
                                  getTypeIcon(
                                    address[
                                        'type'],
                                  ),
                                  color:
                                      getTypeColor(
                                    address[
                                        'type'],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width:
                                      10),

                              Text(
                                address[
                                    'type'],
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      16,
                                ),
                              ),

                              const Spacer(),

                              if (address[
                                      'default'] ==
                                  true)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        10,
                                    vertical:
                                        4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .green
                                        .withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'Default',
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .green,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(
                              height:
                                  12),

                          Text(
                            address['name'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            address[
                                'phone'],
                          ),

                          const SizedBox(
                              height: 8),

                          Text(
                            address[
                                'address'],
                          ),

                          const SizedBox(
                              height:
                                  16),

                          Row(
                            children: [
                              if (address[
                                      'default'] ==
                                  false)
                                TextButton(
                                  onPressed:
                                      () {
                                    setDefaultAddress(
                                      index,
                                    );
                                  },
                                  child:
                                      const Text(
                                    'Set Default',
                                  ),
                                ),

                              const Spacer(),

                              IconButton(
                                onPressed:
                                    () {},
                                icon:
                                    const Icon(
                                  Icons.edit,
                                  color: Colors
                                      .blue,
                                ),
                              ),

                              IconButton(
                                onPressed:
                                    () {
                                  deleteAddress(
                                    index,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color: Colors
                                      .red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            ThemeConfig.primaryColor,
        onPressed:
            showAddAddressDialog,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Add Address',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 150),
        Icon(
          Icons.location_off,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No Addresses Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}