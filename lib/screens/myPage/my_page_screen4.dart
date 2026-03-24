import 'package:flutter/material.dart';

import 'my_page_edit_screen.dart';

class MyPageScreen4 extends StatelessWidget {
  const MyPageScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyPageEditScreen(type: MyPageEditType.name);
  }
}
