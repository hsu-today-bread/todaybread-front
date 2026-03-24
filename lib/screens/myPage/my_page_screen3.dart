import 'package:flutter/material.dart';

import 'my_page_edit_screen.dart';

class MyPageScreen3 extends StatelessWidget {
  const MyPageScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyPageEditScreen(type: MyPageEditType.nickname);
  }
}
