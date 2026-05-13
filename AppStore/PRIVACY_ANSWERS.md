# App Privacy 回答メモ

## 結論

現在の実装では、App Store ConnectのApp Privacyは「Data Not Collected」で回答します。

理由:

- 開発者サーバーへ音声、文字起こし、会話ログを送信しない
- 広告SDK、解析SDK、トラッキングSDKを入れていない
- 会話ログは端末内のUserDefaultsに保存する
- OpenAI API、ElevenLabs、課金APIを使っていない

## App Store Connectでの回答

### Data Collection

No, we do not collect data from this app.

### Tracking

No, this app does not track users.

### Third-Party Advertising

No.

### Developer's Advertising or Marketing

No.

### Analytics

No.

### Product Personalization

No.

### App Functionality

No developer-collected data.

## 注意

Apple Speech frameworkは、音声認識の処理でユーザーの音声をAppleのサーバーへ送る場合があります。これは開発者が収集するデータではありませんが、ユーザー向けのプライバシーポリシーには明記します。

今後、Gemma以外の外部AI API、広告、分析、クラッシュ解析、アカウント機能、サーバー保存を追加した場合は、App Privacyの回答を見直してください。

