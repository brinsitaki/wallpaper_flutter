import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class CustomCard extends StatelessWidget {
  final String? phoneNumber;
  final String? email;

  const CustomCard({super.key, this.phoneNumber, this.email});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF590E8F),
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Colors.white.withValues(alpha: 0.3),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 60.0,
          child: ListTile(
            leading: Icon(
              phoneNumber != null ? Icons.phone : Icons.email,
              color: Colors.white,
            ),
            title: Text(
              phoneNumber != null ? phoneNumber! : email!,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: phoneNumber ?? email!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "${phoneNumber != null ? "Phone number" : "Email"} copied to clipboard!"),
            ),
          );
        },
      ),
    );
  }
}
