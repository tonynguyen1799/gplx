import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/ui_constants.dart';
import '../constants/app_colors.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appYear = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: NAVIGATION_HEIGHT,
        title: const Text('Thông tin', style: TextStyle(fontSize: APP_BAR_FONT_SIZE, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
        leading: null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: SUB_SECTION_SPACING, horizontal: CONTENT_PADDING),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  Icon(Icons.info_outline, size: 48, color: theme.BLUE_COLOR),
                  const SizedBox(height: CONTENT_PADDING),
                  Text(
                    'GPLX Việt Nam',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: SUB_SECTION_SPACING),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';
                    return Text(
                      'Phiên bản $version',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    );
                  },
                ),
                const SizedBox(height: SECTION_SPACING),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: theme.BLUE_COLOR),
                    const SizedBox(width: SUB_SECTION_SPACING),
                    Expanded(
                      child: Text(
                        'GPLX Việt Nam cung cấp bộ đề thi lý thuyết chính xác nhất, bám sát đề thi chính thức mới nhất do Bộ Công An ban hành',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SECTION_SPACING),
                Text(
                  'Hỗ trợ nhiều loại bằng lái, mẹo thi, sa hình, và nhiều tính năng hữu ích khác.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: theme.BLUE_COLOR),
                  title: Text('Điều khoản sử dụng', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl(context, 'https://tonynguyen1799.github.io/dlquiz/terms.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: theme.BLUE_COLOR),
                  title: Text('Chính sách riêng tư', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl(context, 'https://tonynguyen1799.github.io/dlquiz/privacy.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.support_agent, color: theme.BLUE_COLOR),
                  title: Text('Hỗ trợ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl(context, 'https://tonynguyen1799.github.io/dlquiz/support.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined, color: theme.BLUE_COLOR),
                  title: Text('Báo lỗi / Góp ý', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () => _openUrl(context, 'https://tonynguyen1799.github.io/dlquiz/feedback.html'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: SECTION_SPACING),
                Text(
                  '© GPLX Việt Nam $appYear',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở liên kết. Vui lòng kiểm tra kết nối mạng.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mở liên kết: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
} 