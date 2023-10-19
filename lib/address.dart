import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart';
import 'dart:convert';

class LocationData {
  final Map<String, List<String>> data;

  LocationData(this.data);

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final data = <String, List<String>>{};
    for (var key in json.keys) {
      data[key] = List<String>.from(json[key]);
    }
    return LocationData(data);
  }
}

class Address {
  String name;
  String phoneNumber;
  String streetAddress;
  String apartment;
  String region;
  String township;
  bool isSelected;

  Address({
    required this.name,
    required this.phoneNumber,
    required this.streetAddress,
    required this.apartment,
    required this.region,
    required this.township,
    this.isSelected = false,
  });
}



class AddressBook extends StatefulWidget {
  const AddressBook({super.key});

  @override
  State<AddressBook> createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  final List<Address> addresses = [];
  LocationData? locationData;

  Future<void> loadLocationData() async {
    final String jsonString = await rootBundle.loadString('json_asset/myanmar-townships.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      locationData = LocationData.fromJson(jsonMap);
    });
  }

  @override
  void initState() {
    super.initState();
    loadLocationData();
    addresses.add(
      Address(
        name: 'John Doe',
        phoneNumber: '123-456-7890',
        streetAddress: '123 Main St',
        apartment: 'Apt 101',
        region: '',
        township: '',
      ),
    );
    addresses.add(
      Address(
        name: 'Jane Smith',
        phoneNumber: '987-654-3210',
        streetAddress: '456 Elm St',
        apartment: 'Suite 202',
        region: '',
        township: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Address Book',
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        for (var i = 0; i < addresses.length; i++) {
                          addresses[i].isSelected = i == index;
                        }
                      });
                    },
                    child: AddressTile(
                      address: addresses[index],
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAddressScreen(
                              address: addresses[index],
                              onAddressUpdate: (updatedAddress) {
                                setState(() {
                                  addresses[index] = updatedAddress;
                                });
                              },
                              cities: locationData?.data.keys.toList() ?? [],
                              cityTownships: locationData?.data ?? {},
                              selectedRegion: addresses[index].region,
                              selectedTownship: addresses[index].township,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        setState(() {
                          addresses.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAddressScreen(
                        onAddressAdded: (newAddress) {
                          setState(() {
                            addresses.add(newAddress);
                          });
                        },
                        cities: locationData?.data.keys.toList() ?? [],
                        cityTownships: locationData?.data ?? {},
                        selectedRegion: '',
                        selectedTownship: '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Address"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressTile({super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: address.isSelected ? Colors.grey : Colors.white,
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: address.isSelected ? Colors.red : Colors.black,
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
          Text('Phone: ${address.phoneNumber}'),
          Text('Street Address: ${address.streetAddress}'),
          Text('Apartment/Unit: ${address.apartment}'),
          Text('Region/State: ${address.region}'),
          Text('Township/City: ${address.township}'),
        ],
      ),
    );
  }
}

class EditAddressScreen extends StatefulWidget {
  final Address address;
  final Function(Address) onAddressUpdate;
  final List<String> cities;
  final Map<String, List<String>> cityTownships;
  String selectedRegion;
  String selectedTownship;

   EditAddressScreen({super.key,
    required this.address,
    required this.onAddressUpdate,
    required this.cities,
    required this.cityTownships,
    required this.selectedRegion,
    required this.selectedTownship,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController streetController;
  late TextEditingController apartmentController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.address.name);
    phoneController = TextEditingController(text: widget.address.phoneNumber);
    streetController = TextEditingController(text: widget.address.streetAddress);
    apartmentController = TextEditingController(text: widget.address.apartment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street Address'),
              ),
              TextField(
                controller: apartmentController,
                decoration: const InputDecoration(labelText: 'Apartment/Unit'),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'State / Region',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width / 1.12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    value: widget.selectedRegion.isNotEmpty ? widget.selectedRegion : null,
                    hint: const Text('Select State/Region'),
                    items: widget.cities.isNotEmpty
                        ? widget.cities.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : [],
                    onChanged: (newValue) {
                      if (newValue.toString() != widget.selectedRegion) {
                        setState(() {
                          widget.selectedRegion = newValue!;
                          widget.selectedTownship = '';
                        });
                      }
                    },
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'City / Township',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width / 1.12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    value: widget.selectedTownship.isNotEmpty ? widget.selectedTownship : null,
                    hint: const Text('Select City/Township'),
                    items: widget.selectedRegion.isNotEmpty && widget.cityTownships.containsKey(widget.selectedRegion)
                        ? widget.cityTownships[widget.selectedRegion]!.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : [],
                    onChanged: (newValue) {
                      if (newValue.toString() != widget.selectedTownship) {
                        setState(() {
                          widget.selectedTownship = newValue!;
                          widget.selectedRegion = '';

                        });
                      }
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedAddress = Address(
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                    streetAddress: streetController.text,
                    apartment: apartmentController.text,
                    region: widget.selectedRegion,
                    township: widget.selectedTownship,
                  );
                  widget.onAddressUpdate(updatedAddress);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  final Function(Address) onAddressAdded;
  final List<String> cities;
  final Map<String, List<String>> cityTownships;
  String selectedRegion;
  String selectedTownship;

    AddAddressScreen({super.key,
    required this.onAddressAdded,
    required this.cities,
    required this.cityTownships,
    required this.selectedRegion,
    required this.selectedTownship,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street Address'),
              ),
              TextField(
                controller: apartmentController,
                decoration: const InputDecoration(labelText: 'Apartment/Unit'),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'State / Region',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width / 1.12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    value: widget.selectedRegion.isNotEmpty ? widget.selectedRegion : null,
                    hint: const Text('Select State/Region'),
                    items: widget.cities.isNotEmpty
                        ? widget.cities.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : [],
                    onChanged: (newValue) {
                      if (newValue.toString() != widget.selectedRegion) {
                        setState(() {
                          widget.selectedRegion = newValue!;
                          widget.selectedTownship = '';
                        });
                      }
                    },
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'City / Township',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width / 1.12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    value: widget.selectedTownship.isNotEmpty ? widget.selectedTownship : null,
                    hint: const Text('Select City/Township'),
                    items: widget.selectedRegion.isNotEmpty && widget.cityTownships.containsKey(widget.selectedRegion)
                        ? widget.cityTownships[widget.selectedRegion]!.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : [],
                    onChanged: (newValue) {
                      if (newValue.toString() != widget.selectedTownship) {
                        setState(() {
                          widget.selectedTownship = newValue!;
                          // widget.selectedRegion = ''; ===> remove this line will fix the problem
                        });
                      }
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newAddress = Address(
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                    streetAddress: streetController.text,
                    apartment: apartmentController.text,
                    region: widget.selectedRegion,
                    township: widget.selectedTownship,
                  );
                  widget.onAddressAdded(newAddress);
                  Navigator.pop(context);
                },
                child: const Text('Add Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

































// class Address {
//   String name;
//   String streetaddress;
//   bool isSelected;
//
//   Address({required this.name, required this.streetaddress, this.isSelected = false});
// }
//
// class AddressBook extends StatefulWidget {
//   @override
//   _AddressBookState createState() => _AddressBookState();
// }
//
// class _AddressBookState extends State<AddressBook> {
//   final List<Address> addresses = [
//     Address(name: 'John Doe', streetaddress: '123 Main St, Yangon, Myanmar'),
//     Address(name: 'Jane Smith', streetaddress: '456 Elm St, Mandalay, Myanmar'),
//     Address(name: 'Robert Johnson', streetaddress: '789 Oak St, Naypyidaw, Myanmar'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Text(
//             'Address Book',
//             style: GoogleFonts.montserrat(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: addresses.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         for (var i = 0; i < addresses.length; i++) {
//                           addresses[i].isSelected = i == index;
//                         }
//                       });
//                     },
//                     child: AddressTile(
//                       address: addresses[index],
//                       onEdit: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditAddressScreen(
//                               address: addresses[index],
//                               onAddressUpdate: (updatedAddress) {
//                                 setState(() {
//                                   addresses[index] = updatedAddress;
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                       onDelete: () {
//                         setState(() {
//                           addresses.removeAt(index);
//                         });
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AddAddressScreen(
//                         onAddressAdded: (newAddress) {
//                           setState(() {
//                             addresses.add(newAddress);
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 },
//                 icon: Icon(Icons.add),
//                 label: Text("Add New Address"),
//               ),
//             ),
//
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: ElevatedButton(
//                 onPressed: () {},
//
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple[200],
//                   minimumSize: Size(250, 45),
//                   side: BorderSide.none,
//                   shape: StadiumBorder(),
//                 ),
//
//                 child: Text(
//                   'Confirm',
//                   style: GoogleFonts.montserrat(
//                     color: Colors.grey[800],
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class AddressTile extends StatelessWidget {
//   final Address address;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   AddressTile({
//     required this.address,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: address.isSelected ? Colors.grey : Colors.white,
//         border: Border.all(color: Colors.black),
//       ),
//       padding: EdgeInsets.all(16.0),
//       margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 address.name,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: address.isSelected ? Colors.red : Colors.black,
//                 ),
//               ),
//               PopupMenuButton(
//                 icon: Icon(Icons.more_vert),
//                 itemBuilder: (context) {
//                   return [
//                     PopupMenuItem(
//                       value: 'edit',
//                       child: Text('Edit'),
//                     ),
//                     PopupMenuItem(
//                       value: 'delete',
//                       child: Text('Delete'),
//                     ),
//                   ];
//                 },
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     onEdit();
//                   } else if (value == 'delete') {
//                     onDelete();
//                   }
//                 },
//               ),
//             ],
//           ),
//           Text(address.streetaddress),
//         ],
//       ),
//     );
//   }
// }
//
// class EditAddressScreen extends StatefulWidget {
//   final Address address;
//   final Function(Address) onAddressUpdate;
//
//   EditAddressScreen({
//     required this.address,
//     required this.onAddressUpdate,
//   });
//
//   @override
//   _EditAddressScreenState createState() => _EditAddressScreenState();
// }
//
// class _EditAddressScreenState extends State<EditAddressScreen> {
//   late TextEditingController nameController;
//   late TextEditingController addressController;
//
//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.address.name);
//     addressController = TextEditingController(text: widget.address.streetaddress);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Address'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Street Address'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final updatedAddress = Address(
//                   name: nameController.text,
//                   streetaddress: addressController.text,
//                   isSelected: widget.address.isSelected,
//                 );
//                 widget.onAddressUpdate(updatedAddress);
//                 Navigator.pop(context);
//               },
//               child: Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class AddAddressScreen extends StatefulWidget {
//   final Function(Address) onAddressAdded;
//
//   AddAddressScreen({
//     required this.onAddressAdded,
//   });
//
//   @override
//   _AddAddressScreenState createState() => _AddAddressScreenState();
// }
//
// class _AddAddressScreenState extends State<AddAddressScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Address'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Street Address'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final newAddress = Address(
//                   name: nameController.text,
//                   streetaddress: addressController.text,
//                 );
//                 widget.onAddressAdded(newAddress);
//                 Navigator.pop(context);
//               },
//               child: Text('Add Address'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





