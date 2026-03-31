import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    required this.locationName,
    required this.onTap,
    super.key,
  });

  final String locationName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(locationName),
      trailing: TextButton(
        onPressed: onTap,
        child: const Text('Enter Location'),
      ),
    );
  }
}
