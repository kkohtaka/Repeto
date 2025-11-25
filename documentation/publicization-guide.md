# リポジトリ公開ガイド

このドキュメントは、Repetoリポジトリをプライベートからパブリックに変更するための手順とチェックリストです。

## 監査日

2025-11-25

## 監査結果サマリー

✅ **リポジトリは公開可能な状態です**

重大なセキュリティリスクは検出されませんでした。以下の対応を完了しました。

## 完了した準備作業

### 1. ライセンスの設定

- [x] MITライセンスファイル (`LICENSE`) を作成
- [x] README.mdにライセンス情報を追加
- [x] コントリビューションガイドラインをREADMEに追加

### 2. Git設定の更新

- [x] GitメールアドレスをGitHubのnoreplyアドレスに変更
  - 変更前: `kkohtaka@gmail.com`
  - 変更後: `234269+kkohtaka@users.noreply.github.com`

### 3. セキュリティ確認

- [x] ハードコードされたシークレットなし
- [x] 機密ファイルが`.gitignore`で適切に除外されている
- [x] コミット履歴に機密情報なし
- [x] GitHub Secretsが適切に設定されている

## 公開可能な情報

以下の情報はコードに含まれていますが、公開しても問題ありません:

- Bundle ID: `org.kkohtaka.Repeto`
- Development Team ID: `JU42S5KYL6`
- Provisioning Profile名: `Repeto App Store`

## GitHub Secretsの確認

以下のSecretsが設定されており、リポジトリ公開後も保護されます:

| Secret名 | 用途 | 状態 |
| ------- | ---- | ---- |
| `APPLE_CERTIFICATE_BASE64` | Distribution証明書 | ✅ 保護 |
| `APPLE_CERTIFICATE_PASSWORD` | 証明書パスワード | ✅ 保護 |
| `APPLE_PROVISION_PROFILE_BASE64` | Provisioning Profile | ✅ 保護 |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect APIキー | ✅ 保護 |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | ✅ 保護 |
| `APP_STORE_CONNECT_KEY_ID` | Key ID | ✅ 保護 |
| `RENOVATE_TOKEN` | Renovate Bot用トークン | ✅ 保護 |

## リポジトリ公開手順

### ステップ1: 変更のコミットとプッシュ

```bash
# 変更をコミット
git add LICENSE README.md documentation/publicization-guide.md
git commit -m "docs: Add MIT license and publicization documentation"

# ブランチにプッシュ
git push -u origin claude/audit-public-repo-01SNrVbHqZhsRdW9Vu7Ho6uH
```

### ステップ2: プルリクエストの作成とマージ

1. GitHubでプルリクエストを作成
2. CIが成功することを確認
3. mainブランチにマージ

### ステップ3: リポジトリをPublicに変更

1. GitHubリポジトリページへ移動
2. **Settings** タブをクリック
3. 下部の **Danger Zone** セクションへスクロール
4. **Change repository visibility** をクリック
5. **Make public** を選択
6. 確認ダイアログでリポジトリ名 `kkohtaka/Repeto` を入力
7. **I understand, make this repository public** をクリック

### ステップ4: 公開後の確認

公開後、以下を確認してください:

- [ ] GitHub Actionsが正常に動作している
- [ ] Secretsが保護されたまま (Settings → Secrets and variables → Actions)
- [ ] Renovate Botが正常に動作している
- [ ] READMEが正しく表示されている
- [ ] プライバシーポリシーURL (GitHub Pages) がアクセス可能
  - <https://kkohtaka.github.io/Repeto/privacy.html>

## 公開のメリット

### GitHub Actionsの無料枠拡大

- **変更前 (Private)**: 2,000分/月
- **変更後 (Public)**: 無制限 (macOSランナーも含む)

### その他のメリット

- コミュニティからのフィードバック
- オープンソースプロジェクトとしての可視性向上
- 他の開発者との協力機会

## 注意事項

### 今後の開発で注意すること

1. **機密情報の追加禁止**
   - API キー、パスワード、証明書をコミットしない
   - 機密情報は必ずGitHub Secretsを使用

2. **`.gitignore`の維持**
   - 機密ファイルパターンを削除しない
   - 新しい機密ファイルタイプが追加された場合は`.gitignore`を更新

3. **プルリクエストのレビュー**
   - 外部からのPRには機密情報が含まれていないか確認
   - GitHub Actionsワークフローの変更には特に注意

## トラブルシューティング

### GitHub Actionsが失敗する場合

1. Secretsが正しく設定されているか確認
2. ワークフローファイルに構文エラーがないか確認
3. 外部からのPRの場合、Secretsはフォークリポジトリでは利用できません

### Renovate Botが動作しない場合

1. `RENOVATE_TOKEN`が有効か確認
2. トークンの権限 (Contents, Pull requests) を確認
3. `.github/renovate.json5`の設定を確認

## 参考資料

- [GitHubドキュメント - リポジトリの可視性の設定](https://docs.github.com/ja/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility)
- [GitHub Actions - 使用制限](https://docs.github.com/ja/billing/managing-billing-for-github-actions/about-billing-for-github-actions)
- [MITライセンス](https://opensource.org/license/mit)
