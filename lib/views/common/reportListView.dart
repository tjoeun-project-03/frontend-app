import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/common/report_vm.dart';

class ReportListView extends ConsumerStatefulWidget {
  const ReportListView({super.key});

  @override
  ConsumerState<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends ConsumerState<ReportListView> {
  @override
  void initState() {
    super.initState();
    // 메모: 화면 진입 시 내 신고 내역을 서버에서 가져옵니다.
    Future.microtask(() => ref.read(reportViewModelProvider.notifier).fetchReports());
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportViewModelProvider);
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "내 신고 리스트",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
          : reportState.reports.isEmpty
              ? const Center(
                  child: Text("신고 내역이 없습니다.", style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reportState.reports.length,
                  itemBuilder: (context, index) {
                    final report = reportState.reports[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: report.status == 'PENDING'
                                      ? Colors.orange.withOpacity(0.1)
                                      : report.status == 'REJECTED'
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  report.statusText,
                                  style: TextStyle(
                                    color: report.status == 'PENDING' 
                                        ? Colors.orange 
                                        : report.status == 'REJECTED'
                                            ? Colors.red
                                            : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                report.formattedDate,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "대상 ID: ${report.reportedUserId}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "사유: ${report.reason}",
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report.content,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (report.adminComment != null && report.adminComment!.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              "관리자 답변: ${report.adminComment}",
                              style: const TextStyle(color: jimlineNavy, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
