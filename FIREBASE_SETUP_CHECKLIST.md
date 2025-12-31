# Firebase App Distribution セットアップチェックリスト

このチェックリストに従って、Firebase App Distributionをセットアップしてください。
完了したら、このファイルは削除してかまいません。

## 📝 事前準備

- [ ] Googleアカウント（Firebaseアクセス用）
- [ ] Apple Developer Program登録（有料）
- [ ] テスト対象のiOSデバイス（UDID取得用）

---

## ステップ1: Firebaseプロジェクト作成

### 1-1. プロジェクト作成

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. **プロジェクトを追加** をクリック
3. プロジェクト名: `Repeto` （任意）
4. Google Analytics: 不要なら無効化
5. **プロジェクトを作成** をクリック

**完了したらチェック:** [ ]

### 1-2. iOSアプリの追加

1. Firebase Console → プロジェクト概要
2. **iOSアプリを追加** (⊕アイコン) をクリック
3. **Apple バンドルID**: `org.kkohtaka.Repeto`
4. **アプリのニックネーム**: `Repeto`
5. **App Store ID**: 空欄でOK
6. **アプリを登録** をクリック
7. GoogleService-Info.plist のダウンロードは**スキップ**（不要）

**完了したらチェック:** [ ]

### 1-3. Firebase App ID の取得

1. Firebase Console → **⚙️ プロジェクトの設定**
2. **マイアプリ** セクションでiOSアプリを確認
3. **Firebase App ID** をコピー
   - 形式: `1:123456789012:ios:abcdef123456789`
4. メモ帳などに保存（後でGitHub Secretsに設定）

**Firebase App ID:** `_______________________`

**完了したらチェック:** [ ]

---

## ステップ2: サービスアカウント作成

### 2-1. Google Cloud Consoleへ移動

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 上部のプロジェクト選択で、Firebaseと同じプロジェクトを選択

**完了したらチェック:** [ ]

### 2-2. サービスアカウント作成

1. 左メニュー → **IAMと管理** → **サービスアカウント**
2. **サービスアカウントを作成** をクリック
3. **サービスアカウント名**: `github-actions-firebase`
4. **サービスアカウントID**: 自動生成される
5. **説明**: `GitHub Actions用のFirebase App Distribution配信`
6. **作成して続行** をクリック

**完了したらチェック:** [ ]

### 2-3. 役割の付与

1. **役割を選択** ドロップダウンをクリック
2. `Firebase App Distribution Admin` を検索して選択
3. **続行** → **完了** をクリック

**完了したらチェック:** [ ]

### 2-4. JSON秘密鍵の生成

1. サービスアカウント一覧で作成したアカウントをクリック
2. **キー** タブをクリック
3. **鍵を追加** → **新しい鍵を作成**
4. **JSON** を選択
5. **作成** をクリック
6. JSONファイルが自動ダウンロードされる
7. **安全な場所に保存**（リポジトリにコミットしない！）

**ファイル保存場所:** `_______________________`

**完了したらチェック:** [ ]

---

## ステップ3: Apple Ad Hoc証明書の作成

### 3-1. Certificate Signing Request (CSR) の作成

**macOSで実施:**

1. **キーチェーンアクセス** アプリを起動
2. メニュー → **キーチェーンアクセス** → **証明書アシスタント** → **認証局に証明書を要求**
3. メールアドレス: Apple Developer登録メールアドレス
4. 通称: `Repeto Ad Hoc`
5. **ディスクに保存** を選択
6. **鍵ペア情報を指定** にチェック
7. **続ける** をクリック
8. ファイルを保存: `CertificateSigningRequest.certSigningRequest`

**完了したらチェック:** [ ]

### 3-2. Apple Developer Portalで証明書作成

1. [Apple Developer Portal](https://developer.apple.com/account/) にログイン
2. **Certificates, Identifiers & Profiles** に移動
3. **Certificates** → **+** (新規作成) をクリック
4. **Apple Distribution** を選択
5. **Continue** をクリック
6. 作成したCSRファイルをアップロード
7. **Continue** をクリック
8. 証明書(.cer)をダウンロード

**完了したらチェック:** [ ]

### 3-3. 証明書を.p12形式に変換

**macOSで実施:**

1. ダウンロードした.cerファイルをダブルクリック（キーチェーンに追加）
2. **キーチェーンアクセス** アプリを開く
3. **ログイン** キーチェーン → **自分の証明書** カテゴリ
4. 追加された証明書を探す（`Apple Distribution: あなたの名前`）
5. 証明書を右クリック → **"..." を書き出す**
6. ファイル形式: **個人情報交換 (.p12)**
7. ファイル名: `repeto-adhoc.p12`
8. **保存** をクリック
9. **パスワードを設定**（重要: 覚えておく）
10. キーチェーンのパスワードを入力（macOSログインパスワード）

**p12パスワード:** `_______________________` (安全に記録)

**完了したらチェック:** [ ]

### 3-4. 証明書をBase64エンコード

**ターミナルで実施:**

```bash
cd /path/to/certificate/directory
base64 -i repeto-adhoc.p12 -o repeto-adhoc-base64.txt
```

または

```bash
cat repeto-adhoc.p12 | base64 > repeto-adhoc-base64.txt
```

生成された `repeto-adhoc-base64.txt` の内容をコピー（改行含む全体）

**完了したらチェック:** [ ]

---

## ステップ4: Ad Hoc Provisioning Profile の作成

### 4-1. テストデバイスのUDID取得

#### 方法1: Finderで取得 (macOS Catalina以降)

1. iPhoneをMacに接続
2. Finderを開く
3. サイドバーのデバイスをクリック
4. デバイス名の下の情報をクリック（複数回クリックでUDID表示）
5. UDIDを右クリック → コピー

#### 方法2: Xcodeで取得

1. Xcode → **Window** → **Devices and Simulators**
2. 接続したデバイスを選択
3. **Identifier** の値をコピー

**デバイスUDID:** `_______________________`

**完了したらチェック:** [ ]

### 4-2. Apple Developer Portalにデバイス登録

1. Apple Developer Portal → **Devices** → **+** (新規登録)
2. **Platform**: iOS
3. **Device Name**: `iPhone - Your Name` (任意)
4. **Device ID (UDID)**: 取得したUDIDを貼り付け
5. **Continue** → **Register** をクリック

**完了したらチェック:** [ ]

### 4-3. Ad Hoc Provisioning Profile 作成

1. Apple Developer Portal → **Profiles** → **+** (新規作成)
2. **Distribution** セクション → **Ad Hoc** を選択
3. **Continue** をクリック
4. **App ID**: `org.kkohtaka.Repeto` を選択
5. **Continue** をクリック
6. 先ほど作成した **Distribution証明書** を選択
7. **Continue** をクリック
8. 登録した **デバイス** を選択（全選択でOK）
9. **Continue** をクリック
10. **Provisioning Profile Name**: `Repeto Ad Hoc`
11. **Generate** をクリック
12. プロファイル(.mobileprovision)をダウンロード

**完了したらチェック:** [ ]

### 4-4. Provisioning ProfileをBase64エンコード

**ターミナルで実施:**

```bash
cd /path/to/profile/directory
base64 -i Repeto_Ad_Hoc.mobileprovision -o repeto-adhoc-profile-base64.txt
```

または

```bash
cat Repeto_Ad_Hoc.mobileprovision | base64 > repeto-adhoc-profile-base64.txt
```

生成された `repeto-adhoc-profile-base64.txt` の内容をコピー（改行含む全体）

**完了したらチェック:** [ ]

---

## ステップ5: GitHub Secretsの設定

### 5-1. GitHubリポジトリのSecretsページへ移動

1. リポジトリURL: `https://github.com/kkohtaka/Repeto`
2. **Settings** タブをクリック
3. 左メニュー → **Secrets and variables** → **Actions**
4. **New repository secret** をクリック

**完了したらチェック:** [ ]

### 5-2. 以下の5つのSecretsを追加

各Secretを以下の手順で追加:

#### Secret 1: FIREBASE_APP_ID

- **Name**: `FIREBASE_APP_ID`
- **Secret**: ステップ1-3で取得したFirebase App ID
- **New secret** をクリック

**完了したらチェック:** [ ]

#### Secret 2: FIREBASE_SERVICE_ACCOUNT_JSON

- **Name**: `FIREBASE_SERVICE_ACCOUNT_JSON`
- **Secret**: ステップ2-4でダウンロードしたJSONファイルの**全内容**
  - テキストエディタでJSONファイルを開いてコピー
  - Base64エンコード不要（JSON形式のまま）
- **New secret** をクリック

**完了したらチェック:** [ ]

#### Secret 3: APPLE_ADHOC_CERTIFICATE_BASE64

- **Name**: `APPLE_ADHOC_CERTIFICATE_BASE64`
- **Secret**: ステップ3-4で生成したBase64文字列
  - `repeto-adhoc-base64.txt` の内容を全てコピー（改行含む）
- **New secret** をクリック

**完了したらチェック:** [ ]

#### Secret 4: APPLE_ADHOC_CERTIFICATE_PASSWORD

- **Name**: `APPLE_ADHOC_CERTIFICATE_PASSWORD`
- **Secret**: ステップ3-3で設定したp12証明書のパスワード
- **New secret** をクリック

**完了したらチェック:** [ ]

#### Secret 5: APPLE_ADHOC_PROVISION_PROFILE_BASE64

- **Name**: `APPLE_ADHOC_PROVISION_PROFILE_BASE64`
- **Secret**: ステップ4-4で生成したBase64文字列
  - `repeto-adhoc-profile-base64.txt` の内容を全てコピー（改行含む）
- **New secret** をクリック

**完了したらチェック:** [ ]

---

## ステップ6: Firebase App Distributionのテスターグループ作成

### 6-1. テスターグループ作成

1. Firebase Console → **App Distribution**
2. **テスター & グループ** タブをクリック
3. **グループを追加** をクリック
4. **グループ名**: `internal-testers`
5. **テスターを追加**:
   - テスターのメールアドレスを入力（カンマ区切りで複数可）
   - 各テスターはGoogleアカウントが必要
6. **グループを作成** をクリック

**完了したらチェック:** [ ]

---

## ステップ7: 動作確認

### 7-1. PRでテスト

1. GitHubでPRを確認: `https://github.com/kkohtaka/Repeto/pulls`
2. PRに `firebase-preview` ラベルが付いていることを確認
3. GitHub Actions → ワークフロー実行を確認
4. ビルドが成功することを確認

**完了したらチェック:** [ ]

### 7-2. Firebase Consoleで確認

1. Firebase Console → **App Distribution** → **リリース**
2. 新しいビルドが表示されることを確認
3. テスターがメールを受信したことを確認

**完了したらチェック:** [ ]

---

## セットアップ完了

すべてのチェックボックスにチェックが入ったら、セットアップ完了です。

### 後片付け

以下のファイルは**削除**してください（セキュリティ上重要）:

```bash
rm repeto-adhoc.p12
rm repeto-adhoc-base64.txt
rm repeto-adhoc-profile-base64.txt
rm Repeto_Ad_Hoc.mobileprovision
rm CertificateSigningRequest.certSigningRequest
rm <サービスアカウントJSON>.json
```

このチェックリストファイルも削除してかまいません:

```bash
rm FIREBASE_SETUP_CHECKLIST.md
```

---

## トラブルシューティング

問題が発生した場合は `documentation/cicd-setup.md` のトラブルシューティングセクションを参照してください。
