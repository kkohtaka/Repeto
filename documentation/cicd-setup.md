# CI/CDセットアップガイド

## 概要

- **CI (継続的インテグレーション)**: mainブランチへのpush/PRで自動ビルド・テスト
- **TestFlight配信**: タグプッシュまたは手動トリガーで自動配信

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
