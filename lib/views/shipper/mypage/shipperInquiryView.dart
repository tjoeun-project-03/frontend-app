import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/shipper/inquiry_vm.dart';
import '../../../widgets/common/bottomNavBar.dart';

class ShipperInquiryView extends ConsumerStatefulWidget {
  const ShipperInquiryView({super.key});

  @override
  ConsumerState<ShipperInquiryView> createState() => _ShipperInquiryViewState();
}

class _ShipperInquiryViewState extends ConsumerState<ShipperInquiryView> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 🚀 페이지 진입 시마다 데이터 새로고침 호출
    Future.microtask(() => 
      ref.read(inquiryViewModelProvider.notifier).fetchInquiries()
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(inquiryViewModelProvider.notifier).fetchInquiries();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color bgGrey = Color(0xFFF8F9FA);
    
    final inquiryState = ref.watch(inquiryViewModelProvider);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "1:1 문의",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: inquiryState.isLoading
          ? const Center(child: CircularProgressIndicator(color: jimlineNavy))
          : inquiryState.inquiries.isEmpty
              ? _buildEmptyState(context, ref)
              : RefreshIndicator(
                  color: jimlineNavy,
                  onRefresh: () => ref.read(inquiryViewModelProvider.notifier).fetchInquiries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: inquiryState.inquiries.length,
                    itemBuilder: (context, index) {
                      final inquiry = inquiryState.inquiries[index];
                      return _buildInquiryCard(context, inquiry);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateInquirySheet(context, ref),
        backgroundColor: jimlineNavy,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("문의하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pop();
          } else {
            context.go('/shipper-home');
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "등록된 문의 내역이 없습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 20),
          // 수정됨: 버튼 너비를 내부 콘텐츠(글자+아이콘)에 딱 맞게 조절
          Row(
            mainAxisSize: MainAxisSize.min, // 내부 컨텐츠 크기만큼만 너비 차지
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCreateInquirySheet(context, ref),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text("첫 문의 등록하기", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2B88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: Size.zero, // Material 버튼의 기본 최소 사이즈 제한 해제
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(BuildContext context, dynamic inquiry) {
    final bool isAnswered = inquiry.isAnswered;

    return GestureDetector(
      onTap: () => _showInquiryDetailSheet(context, inquiry),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAnswered ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inquiry.statusText,
                    style: TextStyle(color: isAnswered ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inquiry.category,
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(inquiry.formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              inquiry.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateInquirySheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedCategory = '계정 문의'; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "문의 작성",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: ['계정 문의', '결제 문의', '오류 신고', '기타']
                              .map((label) => DropdownMenuItem(child: Text(label), value: label))
                              .toList(),
                          onChanged: (value) => selectedCategory = value,
                          decoration: const InputDecoration(
                            labelText: "문의 종류",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null ? '카테고리를 선택해주세요.' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "제목",
                            hintText: "문의 제목을 입력해주세요",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? '제목을 입력해주세요.' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: contentController,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: "문의 내용",
                            hintText: "상세한 문의 내용을 입력해주세요",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? '내용을 입력해주세요.' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("취소", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final success = await ref.read(inquiryViewModelProvider.notifier).addInquiry(
                                titleController.text,
                                contentController.text,
                                selectedCategory!,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(success ? "문의가 성공적으로 등록되었습니다." : "문의 등록에 실패했습니다.")),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A2B88),
                            foregroundColor: Colors.white,
                            fixedSize: const Size.fromHeight(54),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("문의 등록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInquiryDetailSheet(BuildContext context, dynamic inquiry) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "[${inquiry.statusText}]",
                        style: TextStyle(color: inquiry.isAnswered ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "[${inquiry.category}]",
                        style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(inquiry.formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inquiry.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4, color: Color(0xFF222222)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Q. 문의 내용", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jimlineNavy)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12)),
                      child: Text(inquiry.content, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF444444))),
                    ),
                    if (inquiry.isAnswered) ...[
                      const SizedBox(height: 24),
                      const Text("A. 답변 내용", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jimlineNavy)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          inquiry.answer ?? "답변이 존재하지 않습니다.", 
                          style: const TextStyle(fontSize: 15, height: 1.6, color: jimlineNavy),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: jimlineNavy, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("닫기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
