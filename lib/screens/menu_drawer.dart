import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/iap_provider.dart';

class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final iap = ref.watch(iapProvider);
    final l = AppLocalizations.of(context);

    return Drawer(
      width: 260,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD6E7), Color(0xFFFFF0F8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ヘッダー ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Text(
                  'Simple Mirror',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5D3A1A),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Divider(color: Color(0xFFFFCCDD), thickness: 1, height: 1),
              const SizedBox(height: 8),

              // ── プレミアム ──
              _SectionHeader(title: l.get('menu_premium')),
              if (iap.isPremium)
                _MenuItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFCC00),
                  title: l.get('premium_active_badge'),
                  subtitle: l.get('premium_already'),
                  onTap: () {},
                )
              else
                _MenuItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFCC00),
                  title: iap.isLoading ? l.get('premium_loading') : l.get('premium_subscribe'),
                  subtitle: iap.product != null
                      ? iap.product!.price
                      : l.get('menu_premium_desc'),
                  onTap: iap.isLoading
                      ? () {}
                      : () async {
                          if (iap.product == null) {
                            _showSnackbar(context, l.get('menu_premium_unavailable'));
                            return;
                          }
                          await ref.read(iapProvider.notifier).purchase();
                        },
                ),
              if (!iap.isPremium)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 4),
                  child: GestureDetector(
                    onTap: () => ref.read(iapProvider.notifier).restore(),
                    child: Text(
                      l.get('premium_restore'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9B6DD6),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFFFCCDD), thickness: 1, height: 1),
              const SizedBox(height: 8),

              // ── 言語 ──
              _SectionHeader(title: l.get('menu_language')),
              _LangOption(
                label: l.get('lang_ja'),
                isSelected: locale.languageCode == 'ja',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ja')),
              ),
              _LangOption(
                label: l.get('lang_en'),
                isSelected: locale.languageCode == 'en',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9B6DD6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFAA88AA),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D3A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Color(0xFFAA88AA)),
      ),
      onTap: onTap,
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xFF9B6DD6) : const Color(0xFFCCAACC),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF5D3A1A) : const Color(0xFF9B7777),
        ),
      ),
      onTap: onTap,
    );
  }
}
