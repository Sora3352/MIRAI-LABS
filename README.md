# MIRAI-LABS (未来研究所)

研究室メンバーの管理、研究プロジェクトの追跡、リソース管理を行うWebベースの管理システム

## 概要

MIRAI-LABSは、研究室の効率的な運営をサポートするWebアプリケーションです。研究者、学生、管理者が協力してプロジェクトを進行し、研究成果を管理できるプラットフォームを提供します。

## 主要機能

- **ユーザー管理**: 研究室メンバーの登録・認証・権限管理
- **プロジェクト管理**: 研究プロジェクトの作成・追跡・進捗管理
- **論文管理**: 研究論文の登録・ステータス管理・ファイル管理
- **リソース管理**: 研究機器・設備の予約・利用状況管理
- **ダッシュボード**: 全体の進捗と統計情報の可視化

## 技術スタック

- **フロントエンド**: HTML5, CSS3, JavaScript
- **バックエンド**: PHP 8.x
- **データベース**: MySQL 8.x
- **Webサーバー**: Apache/Nginx

## ディレクトリ構造

```
MIRAI-LABS/
├── README.md               # このファイル
├── src/                    # PHPソースコード
│   ├── index.php          # メインページ
│   └── start/             # 認証関連
│       ├── login.php      # ログイン
│       └── New registration.php  # 新規登録
├── asset/                 # 静的リソース
│   ├── css/              # スタイルシート
│   ├── js/               # JavaScript
│   └── DB/               # データベース関連
│       └── db_connect.php # DB接続設定
├── img/                  # 画像ファイル
└── docs/                 # 設計ドキュメント
    ├── design-document.md     # システム設計書
    ├── database-schema.sql    # データベーススキーマ
    ├── api-specification.md   # API仕様書
    └── deployment-guide.md    # デプロイメントガイド
```

## ドキュメント

### 📋 [システム設計書](docs/design-document.md)
システム全体のアーキテクチャ、機能要件、非機能要件、開発ガイドラインなどを詳細に記載

### 🗄️ [データベース設計](docs/database-schema.sql)
完全なデータベーススキーマ、テーブル定義、インデックス、トリガー設定

### 🔌 [API仕様書](docs/api-specification.md)
RESTful APIの詳細仕様、エンドポイント、リクエスト/レスポンス形式

### 🚀 [デプロイメントガイド](docs/deployment-guide.md)
本番環境へのデプロイ手順、サーバー設定、セキュリティ設定の詳細

## クイックスタート

### 前提条件
- PHP 8.0以上
- MySQL 8.0以上
- Apache/Nginx
- Composer

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/Sora3352/MIRAI-LABS.git
   cd MIRAI-LABS
   ```

2. **データベース設定**
   ```bash
   # データベース作成
   mysql -u root -p -e "CREATE DATABASE mirai_labs;"
   
   # スキーマ実行
   mysql -u root -p mirai_labs < docs/database-schema.sql
   ```

3. **環境設定**
   ```bash
   # 設定ファイル作成
   cp .env.example .env
   
   # 設定を編集
   nano .env
   ```

4. **Webサーバー設定**
   - Apache/Nginxの設定を行う
   - ドキュメントルートを `src/` ディレクトリに設定
   - 詳細は[デプロイメントガイド](docs/deployment-guide.md)を参照

5. **アクセス確認**
   - ブラウザで `http://localhost` にアクセス
   - ログイン画面が表示されることを確認

## 開発ガイドライン

### コーディング規約
- PSR-12準拠のPHPコーディングスタイル
- 適切なコメント記述
- セキュリティベストプラクティスの遵守

### セキュリティ
- パスワードハッシュ化 (bcrypt)
- SQLインジェクション対策 (プリペアドステートメント)
- XSS/CSRF対策
- HTTPS通信必須

## 貢献方法

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを作成

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は `LICENSE` ファイルを参照してください。

## サポート・お問い合わせ

- **Issue**: バグレポートや機能リクエストは [GitHub Issues](https://github.com/Sora3352/MIRAI-LABS/issues) でお知らせください
- **Email**: 技術的な質問は dev@mirai-labs.org までお問い合わせください

## 開発チーム

- **プロジェクトリーダー**: [@Sora3352](https://github.com/Sora3352)
- **開発メンバー**: 
  - [@kisei0307](https://github.com/kisei0307)
  - [@migeruamorin21](https://github.com/migeruamorin21)
  - [@JufukuRyuto](https://github.com/JufukuRyuto)
  - [@kanta224](https://github.com/kanta224)
  - [@874872348572387465yummy](https://github.com/874872348572387465yummy)

---

**MIRAI-LABS** - 未来の研究を、今から始めよう 🚀