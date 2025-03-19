import 'package:flutter/material.dart';

class GroupPhotoWithAddButton extends StatelessWidget {
  const GroupPhotoWithAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.group,
            size: 40,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 130,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add photo functionality is simulated'),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
