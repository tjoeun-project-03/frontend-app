import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/shipper/tracking_vm.dart';
import '../../../models/shipper/tracking_model.dart';

class ShipperHistoryTrackingView extends ConsumerWidget {
  const ShipperHistoryTrackingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel 상태 감시
    final state = ref.watch(trackingProvider);
    final viewModel = ref.read(trackingProvider.notifier);

    // 1. 철저한 가드 로직: 데이터가 없거나 로딩 중이면 다른 위젯을 아예 생성하지 않음
    if (state.isLoading || state.data == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1A2B88))),
      );
    }

    final data = state.data!;

    // 상수 컬러 정의 (런타임 Null 에러 방지)
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color jimlineNavyLight = Color(0xFFD1D5E7);
    const Color borderGrey = Color(0xFFEEEEEE);
    const Color bgGrey = Color(0xFFF5F5F5);
    const Color textGrey = Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: Colors.white,
      // 2. SingleChildScrollView 사용: ListView보다 레이아웃 계산 오류(hasSize)에 훨씬 강함
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 상태 요약 박스 ---
            SizedBox(
              height: 80,
              child: Row(
                children: [
                  _buildSummaryBox("대기", data.summary["waiting"] ?? "0", jimlineNavy, jimlineNavyLight),
                  const SizedBox(width: 8),
                  _buildSummaryBox("배송중", data.summary["ing"] ?? "0", jimlineNavy, jimlineNavyLight),
                  const SizedBox(width: 8),
                  _buildSummaryBox("완료", data.summary["done"] ?? "0", jimlineNavy, jimlineNavyLight),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 탭 메뉴 ---
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: jimlineNavy, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  _buildTabItem("전체", state.selectedTabIndex == 0, () => viewModel.changeTab(0)),
                  _buildTabItem("배송중", state.selectedTabIndex == 1, () => viewModel.changeTab(1)),
                  _buildTabItem("완료", state.selectedTabIndex == 2, () => viewModel.changeTab(2)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 탭별 콘텐츠 (전체(0) 또는 배송중(1)일 때) ---
            if (state.selectedTabIndex == 0 || state.selectedTabIndex == 1) ...[
              _buildMainCard(data, jimlineNavy, borderGrey, bgGrey, textGrey),
              const SizedBox(height: 24),
              _buildTimelineSection(data.timelines, jimlineNavy, borderGrey, textGrey),
            ] else ...[
              // 완료(2) 탭일 때
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Text("완료된 운송 내역이 없습니다.", style: TextStyle(color: textGrey, fontSize: 14)),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  // --- UI Helper Functions ---

  Widget _buildSummaryBox(String title, String count, Color color, Color borderColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
            Text(count, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A2B88) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(TrackingModel data, Color color, Color bGrey, Color bgGrey, Color tGrey) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgGrey,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Icon(Icons.map_outlined, color: Color(0xFF9E9E9E), size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("배송중", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(data.route ?? "", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEEEEEE),
                      child: Icon(Icons.person, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.driverName ?? "기사 정보 없음", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(data.carInfo ?? "", style: TextStyle(fontSize: 11, color: tGrey)),
                        ],
                      ),
                    ),
                    // ✅ 해결: ElevatedButton의 무한 너비 에러(infinite width)를 방지하기 위해 SizedBox로 크기 제한
                    SizedBox(
                      height: 32,
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text("위치 보기", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(List<TimelineItemData> timelines, Color color, Color lineColor, Color tGrey) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("운송현황", style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 20),
          // ✅ 루프를 돌려 타임라인 생성
          for (int i = 0; i < timelines.length; i++)
            _buildTimelineItem(
              timelines[i].title ?? "",
              timelines[i].time ?? "",
              timelines[i].isDone,
              color,
              lineColor,
              tGrey,
              isLast: i == timelines.length - 1,
              isCurrent: timelines[i].isCurrent,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isDone, Color color, Color lineColor, Color tGrey, {bool isLast = false, bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 해결: IntrinsicHeight 에러(Missing size)를 피하기 위해 고정 높이 Column 사용
        Column(
          children: [
            Icon(
              isCurrent ? Icons.local_shipping : (isDone ? Icons.check_circle : Icons.radio_button_unchecked),
              size: 20,
              color: isDone ? color : tGrey,
            ),
            if (!isLast) Container(width: 2, height: 40, color: lineColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : tGrey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(fontSize: 12, color: tGrey)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}