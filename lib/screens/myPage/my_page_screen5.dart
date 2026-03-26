import 'package:flutter/material.dart';

import 'my_page_edit_screen.dart';

class MyPageScreen5 extends StatelessWidget {
  const MyPageScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyPageEditScreen(type: MyPageEditType.phone);
  }
}
