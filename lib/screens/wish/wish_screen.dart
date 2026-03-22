import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class WishScreen extends StatefulWidget{
  const WishScreen({super.key});

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> {

  // 키워드 입력창 관리자
  final TextEditingController _keywordController = TextEditingController();
  // 키워드 리스트
  final List<String> _keywords = [];

  @override
  void dispose() {
    // 키워드 입력창 메모리 누수 방지
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              const Text(
                '키워드 관리',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // 입력창 + 추가 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '등록할 키워드를 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBackground,
                              width: 2,
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(padding: const EdgeInsets.only(top: 3),
                    child: ElevatedButton(
                      onPressed: () {
                        // 입력창에 뭔가를 입력했을 때만 추가
                        final text =  _keywordController.text.trim();
                        if (text.isEmpty) return;

                        if(_keywords.length >=5 ){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('키워드는 5개까지 등록 가능합니다.')),
                          );
                          return;
                        }
                        setState(() {
                          _keywords.add(text);  // 리스트에 키워드 추가
                          _keywordController.clear(); // 입력창 비우기
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('키워드 추가'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if(_keywords.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){
                      setState(() {
                        _keywords.clear();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '전체 삭제',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              Wrap(
                  spacing: 8, // 태그 사이 가로 간격
                  runSpacing: 8, // 줄 바뀔 때 세로 간격
                  children: _keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      onDeleted: () {
                        setState(() {
                          _keywords.remove(keyword);
                        });
                      },
                    );
                  }).toList()
              ),
            ],
          ),
        ),
      ),
    );
  }
}