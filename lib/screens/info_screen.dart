import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin', style: TextStyle(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarBackground,
        foregroundColor: Theme.of(context).appBarText,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'GPLX Việt Nam',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ứng dụng ôn luyện thi giấy phép lái xe Việt Nam. Hỗ trợ nhiều loại bằng lái, mẹo thi, sa hình, và nhiều tính năng hữu ích khác.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                Divider(),
                const SizedBox(height: 8),
                Text(
                  'Phát triển bởi: Tony Nguyen',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).secondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: tony.nguyen1799@gmail.com',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).secondaryText),
                ),
                const SizedBox(height: 16),
                Divider(),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Điều khoản sử dụng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final url = Uri.parse('https://gplx.vn/terms');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Chính sách riêng tư', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final url = Uri.parse('https://gplx.vn/privacy');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Liên hệ hỗ trợ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final email = Uri(
                      scheme: 'mailto',
                      path: 'support@gplx.vn',
                      query: 'subject=Hỗ trợ GPLX Việt Nam',
                    );
                    if (await canLaunchUrl(email)) {
                      await launchUrl(email);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Báo lỗi / Gửi góp ý', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final email = Uri(
                      scheme: 'mailto',
                      path: 'support@gplx.vn',
                      query: 'subject=Góp ý/Báo lỗi GPLX Việt Nam',
                    );
                    if (await canLaunchUrl(email)) {
                      await launchUrl(email);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 