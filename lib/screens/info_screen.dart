import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appYear = DateTime.now().year;
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
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';
                    return Text(
                      'Phiên bản $version',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).secondaryText,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPLX Việt Nam cung cấp bộ đề thi lý thuyết chính xác nhất, bám sát đề thi chính thức mới nhất do Bộ Công An ban hành',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Luôn cập nhật kịp thời khi có thay đổi từ Bộ Công An.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hỗ trợ nhiều loại bằng lái, mẹo thi, sa hình, và nhiều tính năng hữu ích khác.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryText,
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Điều khoản sử dụng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl('https://tonynguyen1799.github.io/dlquiz/terms.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Chính sách riêng tư', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl('https://tonynguyen1799.github.io/dlquiz/privacy.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Hỗ trợ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl('https://tonynguyen1799.github.io/dlquiz/support.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Báo lỗi / Góp ý', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl('https://tonynguyen1799.github.io/dlquiz/feedback.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Text(
                  '© GPLX Việt Nam $appYear',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).secondaryText),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 4),
                // Text(
                //   'Ứng dụng do cá nhân phát triển, không phải ứng dụng chính thức của Bộ Công An hay cơ quan nhà nước.',
                //   style: TextStyle(fontSize: 12, color: Theme.of(context).secondaryText),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
} 