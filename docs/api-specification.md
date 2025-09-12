# MIRAI-LABS API仕様書

## 概要
MIRAI-LABSシステムのRESTful API仕様を定義します。

## ベースURL
```
https://api.mirai-labs.org/v1
```

## 認証
- **認証方式**: JWT (JSON Web Token)
- **ヘッダー**: `Authorization: Bearer <token>`

## レスポンス形式
すべてのAPIレスポンスは以下の形式に従います：

```json
{
  "success": true|false,
  "data": {...},
  "message": "メッセージ",
  "errors": [...],
  "pagination": {...}
}
```

## エラーコード
- `200` OK - 成功
- `201` Created - 作成成功
- `400` Bad Request - リクエストエラー
- `401` Unauthorized - 認証エラー
- `403` Forbidden - 権限エラー
- `404` Not Found - リソースが見つからない
- `422` Unprocessable Entity - バリデーションエラー
- `500` Internal Server Error - サーバーエラー

## API エンドポイント

### 認証 (Authentication)

#### POST /auth/login
ユーザーログイン

**リクエスト**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**レスポンス**
```json
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "user_id": 1,
      "username": "john_doe",
      "email": "user@example.com",
      "full_name": "John Doe",
      "role": "researcher"
    }
  }
}
```

#### POST /auth/register
ユーザー登録

**リクエスト**
```json
{
  "username": "john_doe",
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "department": "AI Research"
}
```

#### POST /auth/logout
ログアウト

#### POST /auth/refresh
トークンリフレッシュ

### ユーザー管理 (Users)

#### GET /users
ユーザー一覧取得

**クエリパラメータ**
- `page`: ページ番号 (デフォルト: 1)
- `limit`: 取得件数 (デフォルト: 20)
- `role`: 役割フィルタ
- `department`: 部署フィルタ

**レスポンス**
```json
{
  "success": true,
  "data": [
    {
      "user_id": 1,
      "username": "john_doe",
      "email": "user@example.com",
      "full_name": "John Doe",
      "role": "researcher",
      "department": "AI Research",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 100,
    "items_per_page": 20
  }
}
```

#### GET /users/{id}
特定ユーザー情報取得

#### PUT /users/{id}
ユーザー情報更新

#### DELETE /users/{id}
ユーザー削除

### プロジェクト管理 (Projects)

#### GET /projects
プロジェクト一覧取得

**クエリパラメータ**
- `page`: ページ番号
- `limit`: 取得件数
- `status`: ステータスフィルタ
- `leader_id`: リーダーIDフィルタ

**レスポンス**
```json
{
  "success": true,
  "data": [
    {
      "project_id": 1,
      "title": "AIチャットボット開発",
      "description": "顧客サポート用AIチャットボットの開発",
      "status": "active",
      "leader": {
        "user_id": 1,
        "full_name": "John Doe"
      },
      "start_date": "2024-01-01",
      "end_date": "2024-12-31",
      "budget": 1000000.00,
      "member_count": 5,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /projects
新規プロジェクト作成

**リクエスト**
```json
{
  "title": "新プロジェクト",
  "description": "プロジェクトの説明",
  "leader_id": 1,
  "start_date": "2024-01-01",
  "end_date": "2024-12-31",
  "budget": 1000000.00,
  "priority": "high"
}
```

#### GET /projects/{id}
プロジェクト詳細取得

#### PUT /projects/{id}
プロジェクト更新

#### DELETE /projects/{id}
プロジェクト削除

#### GET /projects/{id}/members
プロジェクトメンバー一覧

#### POST /projects/{id}/members
プロジェクトメンバー追加

**リクエスト**
```json
{
  "user_id": 2,
  "role": "developer"
}
```

#### DELETE /projects/{id}/members/{user_id}
プロジェクトメンバー削除

### 研究論文管理 (Research Papers)

#### GET /papers
論文一覧取得

**クエリパラメータ**
- `page`: ページ番号
- `limit`: 取得件数
- `status`: ステータスフィルタ
- `project_id`: プロジェクトIDフィルタ
- `search`: キーワード検索

**レスポンス**
```json
{
  "success": true,
  "data": [
    {
      "paper_id": 1,
      "title": "機械学習を用いた自然言語処理の研究",
      "abstract": "本研究では...",
      "authors": ["John Doe", "Jane Smith"],
      "status": "published",
      "journal": "AI Research Journal",
      "publication_date": "2024-06-01",
      "doi": "10.1234/ai.2024.001",
      "citation_count": 15,
      "project": {
        "project_id": 1,
        "title": "AIチャットボット開発"
      },
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /papers
新規論文登録

**リクエスト**
```json
{
  "title": "論文タイトル",
  "abstract": "論文の要約",
  "authors": ["Author 1", "Author 2"],
  "keywords": "機械学習, AI, 自然言語処理",
  "project_id": 1,
  "status": "draft"
}
```

#### GET /papers/{id}
論文詳細取得

#### PUT /papers/{id}
論文更新

#### DELETE /papers/{id}
論文削除

#### POST /papers/{id}/upload
論文ファイルアップロード

### リソース管理 (Resources)

#### GET /resources
リソース一覧取得

**クエリパラメータ**
- `type`: リソースタイプフィルタ
- `status`: ステータスフィルタ
- `available_from`: 利用可能開始日時
- `available_to`: 利用可能終了日時

**レスポンス**
```json
{
  "success": true,
  "data": [
    {
      "resource_id": 1,
      "name": "高性能GPU計算機",
      "type": "equipment",
      "description": "深層学習用GPU搭載計算機",
      "location": "研究室A-101",
      "status": "available",
      "responsible_person": {
        "user_id": 1,
        "full_name": "John Doe"
      },
      "cost": 500000.00,
      "purchase_date": "2024-01-01"
    }
  ]
}
```

#### POST /resources
新規リソース登録

#### GET /resources/{id}
リソース詳細取得

#### PUT /resources/{id}
リソース更新

#### DELETE /resources/{id}
リソース削除

#### GET /resources/{id}/reservations
リソース予約一覧

#### POST /resources/{id}/reservations
リソース予約作成

**リクエスト**
```json
{
  "start_datetime": "2024-12-01T09:00:00Z",
  "end_datetime": "2024-12-01T17:00:00Z",
  "purpose": "深層学習モデルの訓練"
}
```

### 予約管理 (Reservations)

#### GET /reservations
予約一覧取得

#### GET /reservations/{id}
予約詳細取得

#### PUT /reservations/{id}
予約更新

#### DELETE /reservations/{id}
予約キャンセル

#### PUT /reservations/{id}/approve
予約承認

### 通知管理 (Notifications)

#### GET /notifications
通知一覧取得

**レスポンス**
```json
{
  "success": true,
  "data": [
    {
      "notification_id": 1,
      "title": "新しいプロジェクトが作成されました",
      "message": "「AIチャットボット開発」プロジェクトにアサインされました。",
      "type": "info",
      "is_read": false,
      "created_at": "2024-12-01T10:00:00Z"
    }
  ]
}
```

#### PUT /notifications/{id}/read
通知を既読にする

#### DELETE /notifications/{id}
通知削除

### ダッシュボード (Dashboard)

#### GET /dashboard/stats
ダッシュボード統計情報

**レスポンス**
```json
{
  "success": true,
  "data": {
    "total_projects": 25,
    "active_projects": 15,
    "total_papers": 48,
    "published_papers": 32,
    "total_resources": 12,
    "available_resources": 8,
    "total_users": 35,
    "recent_activities": [
      {
        "user": "John Doe",
        "action": "プロジェクトを作成",
        "target": "AIチャットボット開発",
        "timestamp": "2024-12-01T10:00:00Z"
      }
    ]
  }
}
```

### ファイル管理 (Files)

#### POST /files/upload
ファイルアップロード

**リクエスト** (multipart/form-data)
- `file`: アップロードファイル
- `type`: ファイルタイプ (paper, project, resource)
- `target_id`: 関連ID

**レスポンス**
```json
{
  "success": true,
  "data": {
    "file_id": "abc123",
    "filename": "research_paper.pdf",
    "file_path": "/uploads/papers/abc123_research_paper.pdf",
    "file_size": 1024000,
    "mime_type": "application/pdf",
    "uploaded_at": "2024-12-01T10:00:00Z"
  }
}
```

#### GET /files/{id}/download
ファイルダウンロード

## Webhooks

### プロジェクト更新通知
```json
{
  "event": "project.updated",
  "data": {
    "project_id": 1,
    "title": "AIチャットボット開発",
    "status": "completed",
    "updated_by": {
      "user_id": 1,
      "full_name": "John Doe"
    },
    "timestamp": "2024-12-01T10:00:00Z"
  }
}
```

### 論文ステータス変更通知
```json
{
  "event": "paper.status_changed",
  "data": {
    "paper_id": 1,
    "title": "機械学習を用いた自然言語処理の研究",
    "old_status": "submitted",
    "new_status": "published",
    "timestamp": "2024-12-01T10:00:00Z"
  }
}
```

## レート制限
- 認証済みユーザー: 1000リクエスト/時間
- 未認証ユーザー: 100リクエスト/時間

## バージョニング
- URLパスによるバージョン管理: `/v1/`, `/v2/`
- 後方互換性を可能な限り維持
- 非推奨APIは6ヶ月前に通知

## セキュリティ
- HTTPS必須
- JWT有効期限: 24時間
- リフレッシュトークン有効期限: 30日
- CORS設定: 許可されたオリジンのみ
- レート制限による攻撃防止

---

**文書バージョン**: 1.0  
**最終更新**: 2024年12月  
**作成者**: MIRAI-LABS開発チーム