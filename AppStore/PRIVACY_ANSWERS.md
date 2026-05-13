# App Privacy 回答メモ

## 結論

現在の実装では、Google Mobile Ads SDKでバナー広告を表示します。App Store ConnectのApp Privacyは、広告SDKの利用を前提に回答してください。

アプリ独自のサーバーへは送信しません。

- 開発者サーバーへ音声、文字起こし、会話ログを送信しない
- 会話ログは端末内のUserDefaultsに保存する
- OpenAI API、ElevenLabs、課金APIを使っていない
- 広告表示にはGoogle Mobile Ads SDKを使う

## App Store Connectでの回答

### Data Collection

Yes, this app uses a third-party advertising SDK.

### Tracking

Yes, if App Tracking Transparency permission is granted, Google Mobile Ads may use data for advertising and measurement.

### Third-Party Advertising

Yes.

### Developer's Advertising or Marketing

No.

### Analytics

No developer-owned analytics SDK is used. Google Mobile Ads may perform ad measurement.

### Product Personalization

No.

### App Functionality

No developer-collected data.

## 代表的なデータ種別

Google Mobile Ads SDKの利用に合わせて、App Store Connectでは次の項目を確認してください。

- Identifiers
- Usage Data
- Diagnostics

実際の回答は、App Store ConnectのGoogle Mobile Ads SDKに関する最新表示と、AdMob側の設定に合わせてください。

## 注意

Apple Speech frameworkは、音声認識の処理でユーザーの音声をAppleのサーバーへ送る場合があります。これは開発者が収集するデータではありませんが、ユーザー向けのプライバシーポリシーには明記します。

今後、Gemma以外の外部AI API、分析、クラッシュ解析、アカウント機能、サーバー保存を追加した場合は、App Privacyの回答を見直してください。
