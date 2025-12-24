# Firebase App Distribution セットアップガイド

## 概要

このドキュメントでは、PR段階でのプレビュービルド配信のために、Firebase App Distributionをセットアップする手順を説明します。

---

## 前提条件

- Googleアカウント
- Apple Developer Program登録
- Firebase Consoleへのアクセス権限
- Google Cloud Consoleへのアクセス権限

---

## セットアップ手順

### 1. Firebaseプロジェクトの作成

#### 1-1. Firebase Consoleでプロジェクト作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. **プロジェクトを追加**をクリック
3. プロジェクト名を入力（例: `Repeto`）
4. Google Analyticsは任意（不要なら無効化）
5. **プロジェクトを作成**をクリック

#### 1-2. iOSアプリの追加

1. プロジェクト概要ページで**iOSアプリを追加**をクリック
2. **Apple バンドルID**: `org.kkohtaka.Repeto`
3. **アプリのニックネーム**: `Repeto` (任意)
4. **App Store ID**: (空欄でOK)
5. **アプリを登録**をクリック
6. GoogleService-Info.plistのダウンロードは**スキップ**（App Distributionのみ使用）

#### 1-3. Firebase App IDの取得

1. Firebase Console → **プロジェクトの設定** ⚙️
2. **マイアプリ**セクションでiOSアプリを確認
3. **Firebase App ID**をコピー（形式: `1:123456789:ios:abcdef123456`）
4. このIDを後で使用するためメモ

---

### 2. サービスアカウントの作成

#### 2-1. Google Cloud Consoleでサービスアカウント作成

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 上部のプロジェクト選択で、Firebaseプロジェクトと同じプロジェクトを選択
3. **IAMと管理** → **サービスアカウント**に移動
4. **サービスアカウントを作成**をクリック

#### 2-2. サービスアカウント詳細の入力

1. **サービスアカウント名**: `github-actions-firebase-distribution`
2. **サービスアカウントID**: 自動生成される（例: `github-actions-firebase-distribution@...`）
3. **説明**: `GitHub Actions用のFirebase App Distribution配信アカウント`
4. **作成して続行**をクリック

#### 2-3. 役割の付与

1. **役割を選択**ドロップダウンをクリック
2. `Firebase App Distribution Admin`を検索して選択
3. **続行**をクリック
4. **完了**をクリック

#### 2-4. JSON秘密鍵の生成

1. サービスアカウント一覧で、作成したアカウントをクリック
2. **キー**タブをクリック
3. **鍵を追加** → **新しい鍵を作成**
4. **JSON**を選択
5. **作成**をクリック
6. JSONファイルが自動ダウンロードされる
7. このファイルを**安全な場所**に保存（リポジトリにコミットしない！）

---

### 3. Apple Ad Hoc証明書とプロファイルの作成

#### 3-1. Ad Hoc Distribution証明書の作成

1. [Apple Developer Portal](https://developer.apple.com/account/)にアクセス
2. **Certificates, Identifiers & Profiles**に移動
3. **Certificates** → **+**（新規作成）をクリック
4. **Apple Distribution**を選択（Ad Hoc用）
5. **Continue**をクリック
6. CSR（証明書署名要求）をアップロード
   - macOSの**キーチェーンアクセス**アプリで作成
   - **キーチェーンアクセス** → **証明書アシスタント** → **認証局に証明書を要求**
7. 証明書をダウンロード（.cer形式）

#### 3-2. 証明書をp12形式に変換

```bash
# .cerファイルをダブルクリックしてキーチェーンに追加
# キーチェーンアクセスアプリで:
# 1. 追加した証明書を右クリック → "書き出す"
# 2. ファイル形式: "個人情報交換 (.p12)"
# 3. パスワードを設定（後で使用）
# 4. ファイルを保存（例: repeto-adhoc.p12）
```

#### 3-3. 証明書をBase64エンコード

```bash
# macOS/Linuxの場合
base64 -i repeto-adhoc.p12 -o repeto-adhoc-base64.txt

# または
cat repeto-adhoc.p12 | base64 > repeto-adhoc-base64.txt
```

生成されたBase64文字列を後で使用するためコピー

#### 3-4. Ad Hoc Provisioning Profileの作成

1. Apple Developer Portal → **Profiles** → **+**（新規作成）
2. **Ad Hoc**を選択
3. **Continue**をクリック
4. **App ID**: `org.kkohtaka.Repeto`を選択
5. **Continue**をクリック
6. 作成した**Distribution証明書**を選択
7. **Continue**をクリック
8. **テスト対象のデバイス**を選択
   - 少なくとも1台のデバイスを登録する必要がある
   - デバイスUDIDは、デバイスを接続してFinderまたはXcodeから確認
9. **Continue**をクリック
10. **Provisioning Profile Name**: `Repeto Ad Hoc`
11. **Generate**をクリック
12. プロファイルをダウンロード（.mobileprovision形式）

#### 3-5. Provisioning ProfileをBase64エンコード

```bash
# macOS/Linuxの場合
base64 -i Repeto_Ad_Hoc.mobileprovision -o repeto-adhoc-profile-base64.txt

# または
cat Repeto_Ad_Hoc.mobileprovision | base64 > repeto-adhoc-profile-base64.txt
```

生成されたBase64文字列を後で使用するためコピー

---

### 4. GitHub Secretsの設定

#### 4-1. GitHubリポジトリのSecretsページにアクセス

1. GitHubリポジトリ: `https://github.com/kkohtaka/Repeto`
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret**をクリック

#### 4-2. 以下のSecretsを追加

| Secret名 | 値 | 取得元 |
| ------- | --- | ------ |
| `FIREBASE_APP_ID` | Firebase App ID | セクション1-3 |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | JSONファイルの**全内容** | セクション2-4（ファイルをテキストエディタで開いてコピー） |
| `APPLE_ADHOC_CERTIFICATE_BASE64` | Base64エンコードされた証明書 | セクション3-3 |
| `APPLE_ADHOC_CERTIFICATE_PASSWORD` | p12証明書のパスワード | セクション3-2で設定したパスワード |
| `APPLE_ADHOC_PROVISION_PROFILE_BASE64` | Base64エンコードされたプロファイル | セクション3-5 |

**注意事項:**

- Base64文字列を貼り付ける際は、改行を含めて**全体をコピー**
- `FIREBASE_SERVICE_ACCOUNT_JSON`はJSONファイルの内容をそのままコピー（Base64エンコード不要）
- これらの値は絶対にリポジトリにコミットしない

---

### 5. Firebase App Distributionのテスターグループ作成

#### 5-1. テスターグループの作成

1. Firebase Console → **App Distribution**
2. **テスター & グループ**タブをクリック
3. **グループを追加**をクリック
4. **グループ名**: `internal-testers`
5. **テスターを追加**:
   - テスターのメールアドレスを入力（カンマ区切りで複数可）
   - 各テスターはGoogleアカウントが必要
6. **グループを作成**をクリック

#### 5-2. テスターへの案内

新しいテスターには以下の手順を案内してください:

**iOS 16以降の場合:**

1. デバイスのUDIDを開発者に共有
   - Finderでデバイスを接続 → デバイス情報をクリック → UDIDをコピー
   - または、Xcodeの**Window** → **Devices and Simulators**から確認
2. 開発者がUDIDをApple Developer Portalに登録
3. 開発者がProvisioning Profileを更新
4. テスターはメールで招待を受け取る
5. iOS設定で**Developer Mode**を有効化:
   - **設定** → **プライバシーとセキュリティ** → **Developer Mode** → **オン**
   - デバイスを再起動
6. メール内のリンクからアプリをダウンロード

---

## セットアップ完了の確認

すべてのセットアップが完了したら:

1. GitHubリポジトリで新しいPRを作成
2. PRに`firebase-preview`ラベルを追加
3. GitHub Actionsが実行されることを確認
4. Firebase Consoleで配信されたビルドを確認
5. テスターがアプリをダウンロードできることを確認

---

## トラブルシューティング

### ビルドが失敗する

**証明書エラー:**

- Base64エンコードが正しいか確認
- 証明書の有効期限を確認
- 証明書のパスワードが正しいか確認

**プロファイルエラー:**

- プロファイルに含まれるApp IDが`org.kkohtaka.Repeto`と一致するか確認
- プロファイルが**Ad Hoc**タイプであることを確認
- プロファイルに使用する証明書が含まれているか確認

### Firebaseへのアップロードが失敗する

**認証エラー:**

- `FIREBASE_SERVICE_ACCOUNT_JSON`の内容が正しいか確認
- サービスアカウントに`Firebase App Distribution Admin`役割があるか確認
- `FIREBASE_APP_ID`が正しいか確認

### テスターがアプリをダウンロードできない

**デバイスが登録されていない:**

- テスターのデバイスUDIDがProvisioning Profileに含まれているか確認
- Provisioning Profileを更新した場合、新しいビルドを配信する必要がある

**iOS 16+でDeveloper Modeが無効:**

- テスターにDeveloper Modeを有効化するよう案内

**プロファイルのインストールエラー:**

- テスターに再度ダウンロードリンクから試すよう案内
- Safariブラウザを使用するよう案内（他のブラウザでは動作しない場合がある）

---

## デバイスUDIDの追加手順（テスター追加時）

新しいテスターを追加する場合:

1. テスターからデバイスUDIDを取得
2. Apple Developer Portal → **Devices** → **+**（新規登録）
3. デバイス名とUDIDを入力
4. **Profiles** → `Repeto Ad Hoc`を選択 → **Edit**
5. 新しいデバイスを選択に追加
6. **Generate**をクリック
7. 更新されたプロファイルをダウンロード
8. Base64エンコードして`APPLE_ADHOC_PROVISION_PROFILE_BASE64`を更新
9. 新しいビルドを配信（プロファイル更新が反映される）

---

## セキュリティのベストプラクティス

- ✅ GitHub Secretsのみを使用（環境変数に直接記述しない）
- ✅ JSON秘密鍵ファイルをリポジトリにコミットしない
- ✅ `.gitignore`に以下を追加:

  ```gitignore
  # Firebase
  **/GoogleService-Info.plist
  **/google-services.json
  *firebase-service-account*.json

  # Apple Certificates
  *.p12
  *.cer
  *.mobileprovision
  *-base64.txt
  ```

- ✅ 定期的にサービスアカウントの鍵をローテーション
- ✅ 使用していない証明書やプロファイルは削除

---

## 参考リソース

- [Firebase App Distribution ドキュメント](https://firebase.google.com/docs/app-distribution)
- [サービスアカウントでの認証](https://firebase.google.com/docs/app-distribution/authenticate-service-account)
- [Apple Developer - Distribution](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
