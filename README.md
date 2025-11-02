# Repeto

繰り返しタスクのリマインダーアプリケーション

## 概要

Repetoは、掃除や買い物などの定期的に繰り返すタスクを管理し、設定したインターバル経過後に自動的にリマインドするアプリケーションです。

### 主な機能

- タスクの登録（名前、インターバル設定）
- インターバル経過後の自動リマインド通知
- タスクタップで完了マーク → 次回リマインドの自動スケジュール
- タスクの一覧表示・編集・削除
- iCloudによるデバイス間同期

## ドキュメント

- [開発プランドキュメント](docs/development-plan.md) - プロジェクトの開発計画、フェーズ、技術スタック
- [デザインドキュメント](docs/design.md) - アーキテクチャ、データモデル、UI/UX設計
- [CI/CDセットアップガイド](docs/cicd-setup.md) - GitHub Actionsによる自動ビルド・TestFlight配信

## 開発状況

現在、iOS版の開発準備中です。

### Phase 1: プロジェクト基盤構築（進行中）
- [x] ドキュメント作成
- [ ] .gitignore設定
- [ ] Xcodeプロジェクト作成
- [ ] データモデル設計

## 技術スタック

- **プラットフォーム**: iOS 16.0+
- **言語**: Swift 5.9+
- **UIフレームワーク**: SwiftUI
- **データ永続化**: Core Data + CloudKit
- **同期**: NSPersistentCloudKitContainer
- **通知**: UserNotifications framework

## 開発環境要件

- **Xcode**: 26.0以降
- **macOS**: Sequoia 15.0以降

## ライセンス

TBD
