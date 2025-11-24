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

**Secret名**: `RENOVATE_TOKEN`
**説明**: GitHub Personal Access Token (Fine-grained)
**必要な権限**:

- Contents: Read/Write
- Pull requests: Read/Write
- Metadata: Read-only

### 実行スケジュール

- **自動実行**: 毎週月曜日 9:00 AM JST
- **設定ファイル**: `.github/renovate.json5`
- **ワークフロー**: `.github/workflows/renovate.yml`

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
