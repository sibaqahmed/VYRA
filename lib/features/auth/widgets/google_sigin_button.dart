import 'package:flutter/material.dart';
class GoogleSiginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSiginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login),
            SizedBox(width: 10,),
            Text(
              "Continue with Google",style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            )
          ],
        ));
  }
}
