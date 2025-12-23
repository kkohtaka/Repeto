# CI/CDセットアップガイド

## 概要

- **CI (継続的インテグレーション)**: mainブランチへのpush/PRで自動ビルド・テスト
- **TestFlight配信**: タグプッシュまたは手動トリガーで自動配信
- **コード品質チェック**: SwiftLintによる自動コードレビュー

---

## CIワークフロー

### SwiftLint

PRおよびmainブランチへのpush時に自動的にSwiftLintが実行されます。

- **実行タイミング**: コードチェックアウト直後
- **設定ファイル**: `.swiftlint.yml`
- **実行モード**: `--strict`（警告もエラーとして扱う）
- **失敗時の動作**: ワークフロー全体が失敗し、PRマージをブロック

### ビルド＆テスト

SwiftLint通過後、自動的にビルドが実行されます。

- **環境**: macOS 26、Xcode 26.0.1
- **ターゲット**: iOS Simulator
- **コード署名**: 無効（CI環境のため）

---

## GitHub Secretsの設定

TestFlight自動配信に必要な秘密情報をGitHub Secretsに登録してください。

| Secret名 | 説明 | 備考 |
| ------- | ---- | ---- |
| `APPLE_CERTIFICATE_BASE64` | Distribution証明書（.p12形式、Base64エンコード） | 年1回更新が必要 |
| `APPLE_CERTIFICATE_PASSWORD` | 証明書のパスワード | - |
| `APPLE_PROVISION_PROFILE_BASE64` | App Store Distribution Profile（Base64エンコード） | 証明書更新時に再作成が必要 |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect APIキー（.p8ファイルの内容） | - |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID | - |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect Key ID | - |

**Bundle ID**: `org.kkohtaka.Repeto`
**Provisioning Profile名**: `Repeto App Store`

---

## 依存関係の自動更新（Renovate）

Renovate Botが以下の依存関係を自動的に管理します：

- **GitHub Actions**: actions/checkout, actions/cache, actions/setup-node, actions/upload-artifact
- **開発ツール**: `.github/tool-versions.env`内のツールバージョン
  - actionlint, markdownlint-cli2, SwiftLint, gh, Node.js, shellcheck

### 必要な設定

RenovateはGitHub Appによる認証を使用します。

#### GitHub Appの権限要件

以下の権限を持つGitHub Appが必要です：

- **Repository permissions**:
  - Contents: Read and write
  - Pull requests: Read and write
  - Workflows: Read and write
  - Metadata: Read-only

#### 必要なGitHub Secrets

| Secret名 | 説明 |
| ------- | ---- |
| `APP_ID` | GitHub AppのアプリケーションID |
| `APP_PRIVATE_KEY` | GitHub Appの秘密鍵（PEM形式） |

### 実行スケジュール

- **自動実行**: 毎週月曜日 9:00 AM JST
- **手動実行**: GitHub Actions → Renovate → Run workflow
- **設定ファイル**: `.github/renovate.json5`
- **ワークフロー**: `.github/workflows/renovate.yml`

### 自動マージ機能

RenovateはCI（linterとテスト）が通過したPRを**自動的にマージ**します：

- **対象**: major、minor、patch すべての更新
- **条件**: すべてのCIチェックが成功
- **マージ方法**: Squash merge

手動でレビューしたい場合は、PRにコメントを追加するか、Dependency Dashboardで無効化できます。

### Dependency Dashboard

Renovateは**Dependency Dashboard** issueを自動作成し、すべての依存関係の更新状況を一覧表示します：

- 保留中の更新
- レート制限の状態
- 問題が発生した更新

### 動作

Renovateは関連する更新を自動的にグループ化してPRを作成します：

1. **GitHub Actions更新**: `chore(ci): Update GitHub Actions` ラベル: `dependencies`, `github-actions`
2. **開発ツール更新**: `chore(tools): Update Development Tools` ラベル: `dependencies`, `tools`

詳細は`CLAUDE.md`の「Dependency Management (Renovate)」セクションを参照してください。

---

## TestFlight配信

### タグプッシュによる自動配信（推奨）

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 手動トリガー

1. GitHubリポジトリ → **Actions**
2. **TestFlight Deployment** → **Run workflow**

---

## ビルド番号とバージョン番号

- **ビルド番号**: GitHub Actionsの実行番号で自動インクリメント（手動指定も可能）
- **バージョン番号**: Xcodeで手動更新（TARGETS → Repeto → General → Version）

---

## TestFlightテスター招待とダウンロード手順

### 開発者側: テスターの招待

1. [App Store Connect](https://appstoreconnect.apple.com/)にログイン
2. **マイApp** → **Repeto**を選択
3. **TestFlight**タブをクリック
4. **内部テスト**または**外部テスト**でテストグループを作成
   - **内部テスト**: App Store Connectユーザー（最大100名）
   - **外部テスト**: 任意のメールアドレス（最大10,000名、Appleレビュー必要）
5. **テスター**セクションで招待したいテスターのメールアドレスを追加
6. テスターに招待メールが自動送信される

### テスター側: アプリのダウンロード

#### ステップ1: TestFlightアプリのインストール

- App Storeから**TestFlight**アプリをインストール（無料）
- リンク: [TestFlight - App Store](https://apps.apple.com/jp/app/testflight/id899247664)

#### ステップ2: 招待の受け入れ

1. 開発者から届いた招待メールを開く
2. **View in TestFlight**または**TestFlightで表示**をタップ
3. TestFlightアプリが開き、招待を受け入れるか確認される
4. **同意する**をタップ

#### ステップ3: アプリのインストール

1. TestFlightアプリ内で**Repeto**が表示される
2. **インストール**ボタンをタップ
3. ダウンロード＆インストールが完了したら**開く**をタップして起動

### アップデート時の手順

新しいビルドがTestFlightに配信されると:

1. TestFlightアプリに通知が届く
2. TestFlightアプリを開く
3. Repetoアプリの横に**アップデート**ボタンが表示される
4. **アップデート**をタップしてインストール
