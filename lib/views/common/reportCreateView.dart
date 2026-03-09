import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/common/report_vm.dart';

class ReportCreateView extends ConsumerStatefulWidget {
  final int orderId;
  const ReportCreateView({super.key, required this.orderId});

  @override
  ConsumerState<ReportCreateView> createState() => _ReportCreateViewState();
}

class _ReportCreateViewState extends ConsumerState<ReportCreateView> {
  final _contentController = TextEditingController();
  String _selectedReason = '불친절';
  final List<String> _reasons = ['불친절', '노쇼', '운송거부', '부당요구', '물품파손', '기타'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(reportViewModelProvider.notifier).loadReportInfo(widget.orderId)
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportViewModelProvider);
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("신고 작성", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: reportState.isLoading
          ? const Center(child: CircularProgressIndicator(color: jimlineNavy))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메모: 에러 메시지가 있을 경우 표시
                  if (reportState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        reportState.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // 메모: 오더 정보 표시
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: jimlineNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: jimlineNavy, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          "오더 #${widget.orderId} 관련 신고",
                          style: const TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 메모: 판별된 신고자 및 대상자 정보 섹션
                  const Text("신고 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard("신고자 (나)", reportState.reporterId, jimlineNavy)),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard("신고 대상", reportState.reportedUserId, Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text("신고 사유", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReason,
                        isExpanded: true,
                        items: _reasons.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedReason = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text("상세 내용", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "신고 사유를 구체적으로 입력해 주세요.",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: reportState.reportedUserId.isEmpty ? null : () async {
                        if (_contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("내용을 입력해 주세요.")),
                          );
                          return;
                        }

                        final success = await ref.read(reportViewModelProvider.notifier).createReport(
                          orderId: widget.orderId,
                          reason: _selectedReason,
                          content: _contentController.text,
                        );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("신고가 정상적으로 접수되었습니다.")),
                          );
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jimlineNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "신고 접수하기",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 메모: 정보 표시용 카드 위젯
  Widget _buildInfoCard(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value.isEmpty ? "정보 없음" : value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
