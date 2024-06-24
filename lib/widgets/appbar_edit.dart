import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';

class AppBarEdit extends StatefulWidget {
  final String titleName;
  const AppBarEdit({this.titleName = '', super.key});

  @override
  State<AppBarEdit> createState() => _AppBarEditState();
}

class _AppBarEditState extends State<AppBarEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.titleName,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_left,
                semanticLabel: 'Voltar',
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
