# AIホストと通話

SwiftUI製の音声会話練習MVPです。Apple Speech frameworkで日本語の音声入力を文字起こしし、MockHostAIが短く返答します。返答はAVSpeechSynthesizerで読み上げます。

## 構成

- 課金APIなし
- ElevenLabsなし
- OpenAI APIなし
- Gemma未接続でもMockで動作
- 将来はGemmaProcessorにGoogle AI Edge / MediaPipe LLM Inference APIを接続
- 端末内の日本語音声から高品質な声を自動選択
- ホストタイプごとに読み上げの速さ・高さ・音量を調整
- AdMobバナー広告を上下に表示

## 実行

この環境ではXcodeプロジェクト生成ツールがありません。XcodeGenを使う場合は、`ios/AIHostCall` で次を実行してください。

```sh
xcodegen generate
```

またはXcodeで新規iOS Appを作り、`AIHostCall` フォルダ内のSwiftファイルとAssetsを追加してください。
