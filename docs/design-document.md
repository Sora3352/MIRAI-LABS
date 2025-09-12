# MIRAI-LABS システム設計書

## 1. プロジェクト概要

### 1.1 プロジェクト名
MIRAI-LABS (未来研究所) Webアプリケーション

### 1.2 目的
研究室メンバーの管理、研究プロジェクトの追跡、リソース管理を行うWebベースの管理システムを提供する。

### 1.3 対象ユーザー
- 研究室管理者
- 研究員
- 学生研究者
- 外部協力者

## 2. システムアーキテクチャ

### 2.1 全体構成
```
[クライアント] ←→ [Webサーバー(Apache/Nginx)] ←→ [PHPアプリケーション] ←→ [データベース(MySQL)]
```

### 2.2 技術スタック
- **フロントエンド**: HTML5, CSS3, JavaScript
- **バックエンド**: PHP 8.x
- **データベース**: MySQL 8.x
- **Webサーバー**: Apache/Nginx
- **バージョン管理**: Git

### 2.3 ディレクトリ構造
```
MIRAI-LABS/
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
└── docs/                 # ドキュメント
    └── design-document.md # この設計書
```

## 3. データベース設計

### 3.1 ER図概要
主要エンティティ:
- Users (ユーザー)
- Projects (プロジェクト)
- Research_Papers (研究論文)
- Lab_Resources (研究室リソース)

### 3.2 テーブル設計

#### 3.2.1 Users テーブル
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'researcher', 'student', 'guest') DEFAULT 'student',
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

#### 3.2.2 Projects テーブル
```sql
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    leader_id INT,
    start_date DATE,
    end_date DATE,
    status ENUM('planning', 'active', 'completed', 'suspended') DEFAULT 'planning',
    budget DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leader_id) REFERENCES users(user_id)
);
```

#### 3.2.3 Research_Papers テーブル
```sql
CREATE TABLE research_papers (
    paper_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(300) NOT NULL,
    abstract TEXT,
    authors TEXT, -- JSON形式で複数著者を保存
    publication_date DATE,
    journal VARCHAR(150),
    status ENUM('draft', 'submitted', 'published') DEFAULT 'draft',
    project_id INT,
    file_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
```

## 4. ユーザーインターフェース設計

### 4.1 画面一覧
1. **ログイン画面** (`/src/start/login.php`)
2. **新規登録画面** (`/src/start/New registration.php`)
3. **ダッシュボード** (`/src/index.php`)
4. **プロジェクト管理画面**
5. **研究論文管理画面**
6. **ユーザー管理画面**
7. **リソース管理画面**

### 4.2 UI/UXガイドライン
- **レスポンシブデザイン**: モバイル、タブレット、デスクトップ対応
- **アクセシビリティ**: WCAG 2.1 AA準拠
- **カラーパレット**: 研究室らしい落ち着いた配色
  - プライマリ: #2C3E50 (ダークブルー)
  - セカンダリ: #3498DB (ブルー)
  - アクセント: #E74C3C (レッド)
  - 背景: #ECF0F1 (ライトグレー)

### 4.3 ナビゲーション構造
```
ヘッダー
├── ロゴ/ホーム
├── ダッシュボード
├── プロジェクト
├── 研究論文
├── リソース
├── 設定
└── ログアウト
```

## 5. 機能要件

### 5.1 認証・認可機能
- ユーザー登録・ログイン
- パスワードリセット
- セッション管理
- 役割ベースアクセス制御 (RBAC)

### 5.2 プロジェクト管理機能
- プロジェクト作成・編集・削除
- メンバー割り当て
- 進捗追跡
- 予算管理

### 5.3 研究論文管理機能
- 論文登録・編集
- ファイルアップロード
- 検索・フィルタリング
- ステータス管理

### 5.4 リソース管理機能
- 機器予約システム
- 在庫管理
- 使用履歴追跡

## 6. 非機能要件

### 6.1 性能要件
- 応答時間: 3秒以内
- 同時接続ユーザー数: 100人
- データベース応答時間: 1秒以内

### 6.2 セキュリティ要件
- パスワード暗号化 (bcrypt)
- SQLインジェクション対策
- XSS対策
- CSRF対策
- HTTPS通信必須

### 6.3 可用性要件
- 稼働率: 99.5%以上
- 定期バックアップ
- 障害復旧時間: 4時間以内

## 7. 開発ガイドライン

### 7.1 コーディング規約
- PSR-12準拠のPHPコーディングスタイル
- 適切なコメント記述
- 関数・変数名は英語で記述
- データベース接続にはPDOを使用

### 7.2 セキュリティガイドライン
```php
// パスワードハッシュ化の例
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// プリペアドステートメントの使用
$stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
```

### 7.3 エラーハンドリング
- try-catch文の適切な使用
- ログ出力の実装
- ユーザーフレンドリーなエラーメッセージ

## 8. テスト計画

### 8.1 テスト種別
- **単体テスト**: PHPUnit使用
- **統合テスト**: データベース連携テスト
- **セキュリティテスト**: 脆弱性検査
- **ユーザビリティテスト**: UI/UX確認

### 8.2 テスト環境
- 開発環境: localhost
- ステージング環境: テスト用サーバー
- 本番環境: プロダクションサーバー

## 9. デプロイメント

### 9.1 デプロイメント手順
1. コードレビュー
2. テスト実行
3. ステージング環境デプロイ
4. 受け入れテスト
5. 本番環境デプロイ
6. 動作確認

### 9.2 サーバー要件
- PHP 8.0以上
- MySQL 8.0以上
- Apache 2.4以上 または Nginx 1.18以上
- SSL証明書

## 10. 保守・運用

### 10.1 バックアップ計画
- データベース: 日次バックアップ
- ファイル: 週次バックアップ
- バックアップ保持期間: 3ヶ月

### 10.2 監視項目
- サーバーリソース使用率
- アプリケーションエラー率
- レスポンス時間
- ユーザーアクセス数

### 10.3 更新計画
- セキュリティパッチ: 即座に適用
- 機能追加: 月次リリース
- 大規模改修: 四半期リリース

## 11. 今後の拡張予定

### 11.1 Phase 2 機能
- RESTful API実装
- モバイルアプリ対応
- 多言語対応

### 11.2 Phase 3 機能
- 機械学習統合
- データ分析ダッシュボード
- 外部システム連携

---

**文書作成日**: 2024年12月  
**作成者**: MIRAI-LABS開発チーム  
**バージョン**: 1.0  
**承認者**: プロジェクトマネージャー