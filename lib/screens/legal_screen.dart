import 'package:flutter/material.dart';

enum LegalType { terms, privacy }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});
  final LegalType type;

  static const _termsJa = '''
最終更新日：2026年4月18日

本利用規約（以下「本規約」）は、ミラー占い（以下「本アプリ」）の利用条件を定めるものです。

■ サービス内容
本アプリは、カメラを使用したミラー機能および占いコンテンツを提供します。占い結果はエンターテインメント目的であり、正確性を保証するものではありません。

■ 毎日プラン（サブスクリプション）
・料金：App Storeに表示される価格（月額）
・更新：各期間終了の24時間前に自動更新されます
・解約：App Store のサブスクリプション設定からいつでも解約できます
・解約しない限り、自動更新されます

■ 禁止事項
・本アプリのリバースエンジニアリング
・違法または不正な目的での使用
・他のユーザーへの迷惑行為

■ 免責事項
本アプリの占い結果は娯楽目的のものであり、利用者の行動に起因するいかなる損害についても責任を負いません。

■ 規約の変更
本規約は予告なく変更される場合があります。変更後も本アプリを継続して利用された場合、変更に同意したものとみなします。

■ お問い合わせ
minoapp.vegas.rel@gmail.com
''';

  static const _privacyJa = '''
最終更新日：2026年4月18日

本プライバシーポリシーは、ミラー占い（以下「本アプリ」）における個人情報の取り扱いについて説明します。

■ 収集する情報
本アプリは以下の情報を収集します：
・端末内に保存される占い履歴（サーバーへの送信なし）
・サブスクリプション購入情報（Apple経由）
・カメラ映像（端末内でのみ使用、外部送信なし）

■ 情報の利用目的
収集した情報は以下の目的にのみ使用します：
・アプリ機能の提供（占い・ミラー機能）
・サブスクリプション管理

■ 第三者への提供
個人情報を第三者に販売・提供・開示することはありません。
Apple Inc. のサービスを通じた購入情報はAppleのプライバシーポリシーに従います。

■ データの保存
占いデータ・設定情報はお使いの端末内にのみ保存されます。

■ カメラ使用について
カメラはミラー機能にのみ使用します。撮影した映像は保存・外部送信されません。

■ お子様のプライバシー
本アプリは13歳未満のお子様から意図的に個人情報を収集しません。

■ ポリシーの変更
本ポリシーは予告なく更新される場合があります。

■ お問い合わせ
minoapp.vegas.rel@gmail.com
''';

  static const _termsEn = '''
Last updated: April 18, 2026

These Terms of Service govern your use of Mirror Fortune (the "App").

■ Service Description
The App provides a camera-based mirror feature and fortune-telling content. Fortune results are for entertainment purposes only and accuracy is not guaranteed.

■ Daily Plan (Subscription)
• Price: as shown in the App Store
• Renewal: automatically renews 24 hours before the end of each period
• Cancellation: cancel anytime via App Store subscription settings
• Charges will continue until cancelled

■ Prohibited Uses
• Reverse engineering the App
• Using the App for illegal purposes
• Harassing other users

■ Disclaimer
Fortune results are for entertainment only. We are not liable for any actions taken based on the App's content.

■ Changes to Terms
These terms may be updated without notice. Continued use of the App after changes constitutes acceptance.

■ Contact
minoapp.vegas.rel@gmail.com
''';

  static const _privacyEn = '''
Last updated: April 18, 2026

This Privacy Policy explains how Mirror Fortune (the "App") handles your information.

■ Information We Collect
• Fortune history stored locally on your device (not sent to servers)
• Subscription purchase information (via Apple)
• Camera feed (used only on-device, never transmitted externally)

■ How We Use Information
Information is used solely to:
• Provide app features (fortune telling & mirror)
• Manage subscriptions

■ Third-Party Sharing
We do not sell, share, or disclose personal information to third parties.
Purchase information through Apple is governed by Apple's Privacy Policy.

■ Data Storage
Fortune data and settings are stored only on your device.

■ Camera Usage
The camera is used only for the mirror feature. No footage is saved or transmitted.

■ Children's Privacy
We do not knowingly collect personal information from children under 13.

■ Policy Changes
This policy may be updated without notice.

■ Contact
minoapp.vegas.rel@gmail.com
''';

  @override
  Widget build(BuildContext context) {
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final isTerms = type == LegalType.terms;

    final title = isTerms
        ? (isJa ? '利用規約' : 'Terms of Service')
        : (isJa ? 'プライバシーポリシー' : 'Privacy Policy');

    final content = isTerms
        ? (isJa ? _termsJa : _termsEn)
        : (isJa ? _privacyJa : _privacyEn);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D3A1A),
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            height: 1.8,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}
