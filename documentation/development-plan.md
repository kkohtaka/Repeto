# Repeto - 開発プランドキュメント

## プロジェクト概要

### プロジェクト名

Repeto（リピート）

### 概要

繰り返しタスクのリマインダーアプリケーション。掃除、買い物などの定期的に繰り返すタスクを管理し、設定したインターバル経過後に自動的にリマインドする。

### 主な機能

- タスクの登録（名前、インターバル）
- インターバル経過後の自動リマインド通知
- タスクタップで完了マーク → 次回リマインドの自動スケジュール
- タスクの一覧表示・編集・削除
- iCloudによるデバイス間同期

### 対象プラットフォーム

- iOS 16.0+（iPhone/iPad）

---

## 技術スタック

### 開発環境

- **IDE**: Xcode 26.0+
- **macOS**: Sequoia 15.0+
- **言語**: Swift 5.9+
- **最小サポートバージョン**: iOS 16.0+

### フレームワーク

- **UI**: SwiftUI
- **データ永続化**: Core Data + CloudKit
- **通知**: UserNotifications framework
- **同期**: NSPersistentCloudKitContainer
- **アーキテクチャ**: MVVM

### CI/CD

- **GitHub Actions**: 自動ビルド・TestFlight配信
- **実行環境**: macOS 26 runners
- **Xcode**: 26.0.1

---

## 開発フェーズ

### Phase 1: プロジェクト基盤構築

#### 目標

プロジェクトの基本構造とデータモデルの確立

#### 前提条件

- [ ] Apple Developer Program登録（年間$99、数日かかる場合あり）
- [ ] Apple IDの2ファクタ認証設定

#### タスク

- [x] ドキュメント作成
- [x] .gitignore設定（iOS/Xcode用）
- [x] Xcodeプロジェクト作成
- [x] 証明書・プロビジョニングプロファイル取得
  - Distribution Certificate
  - App Store Distribution Profile
- [x] App Store Connect API Key取得（CI/CD用）
- [x] App Store Connectでアプリ登録
- [x] プライバシーポリシー作成・公開（TestFlight配信に必須）
- [x] Export Compliance設定（Info.plist）
- [x] iCloud Capability設定（CloudKit有効化）
- [x] Core Dataスキーマ定義
- [x] Taskエンティティ作成
- [x] NSPersistentCloudKitContainer設定
- [x] GitHub Actions CI/CD構築
  - ビルド自動化
  - TestFlight自動配信
  - 実機で触れる成果物の継続的提供

#### 成果物

- Xcodeプロジェクト
- Core Dataモデル
- iCloud同期設定完了
- CI/CDパイプライン（TestFlight自動配信）
- プライバシーポリシー

---

### Phase 2: コア機能実装

#### 目標

タスク管理の基本機能を完成

#### タスク

- [ ] TaskService実装（CRUD操作）
- [ ] インターバル計算ロジック
- [ ] タスク完了処理
- [ ] データ永続化の実装

#### 成果物

- 完全なタスク管理ロジック
- インターバル計算エンジン

---

### Phase 3: UI実装

#### 目標

ユーザーインターフェースの実装

#### タスク

- [ ] タスク一覧画面
  - リスト表示
  - セクション分け（期限切れ/今日/今後）
  - タスクタップで完了マーク
  - スワイプアクション（削除・編集）
- [ ] タスク作成・編集画面
  - フォーム入力
  - バリデーション

#### 成果物

- 完全なユーザーインターフェース

---

### Phase 4: 通知機能実装

#### 目標

リマインド通知機能の実装

#### タスク

- [ ] NotificationService作成
- [ ] 通知権限リクエスト
- [ ] ローカル通知のスケジューリング
- [ ] タスク作成/更新/削除時の通知管理

#### 成果物

- 完全な通知システム

---

### Phase 5: テスト・改善

#### 目標

品質保証とバグ修正

#### タスク

- [ ] Xcodeスキームのテスト設定（CI/CD用）
- [ ] ユニットテスト（モデルロジック）
- [ ] UIテスト（主要フロー）
- [ ] バグ修正
- [ ] パフォーマンス最適化

#### 成果物

- 安定版アプリ
- テストカバレッジ

---

### Phase 6: リリース準備

#### 目標

App Storeリリースの準備

#### タスク

- [ ] アプリアイコン作成
- [ ] スクリーンショット作成
- [ ] App Store説明文作成
- [ ] プライバシーポリシー更新（正式版）
- [ ] App Store申請

#### 成果物

- App Store公開準備完了

---

## マイルストーン

| マイルストーン | 成果物 |
| ------------ | ------ |
| M1: プロジェクト基盤完成 | Xcodeプロジェクト、データモデル、iCloud同期設定、CI/CDパイプライン、プライバシーポリシー |
| M2: コア機能完成 | タスクCRUD、インターバル計算 |
| M3: UI完成 | 全画面実装完了 |
| M4: 通知機能完成 | リマインド通知機能 |
| M5: テスト完了 | テストカバレッジ達成 |
| M6: リリース | App Store公開 |

---

## 参考資料

### Apple公式ドキュメント

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/documentation/coredata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [NSPersistentCloudKitContainer](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
