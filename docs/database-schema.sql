-- MIRAI-LABS データベーススキーマ
-- バージョン: 1.0
-- 作成日: 2024年12月

-- データベース作成
CREATE DATABASE IF NOT EXISTS mirai_labs 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE mirai_labs;

-- ユーザーテーブル
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'researcher', 'student', 'guest') DEFAULT 'student',
    department VARCHAR(100),
    profile_image VARCHAR(500),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE
);

-- プロジェクトテーブル
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    leader_id INT,
    start_date DATE,
    end_date DATE,
    status ENUM('planning', 'active', 'completed', 'suspended') DEFAULT 'planning',
    budget DECIMAL(12,2),
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (leader_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_leader (leader_id),
    INDEX idx_dates (start_date, end_date)
);

-- プロジェクトメンバーテーブル（多対多リレーション）
CREATE TABLE project_members (
    project_id INT,
    user_id INT,
    role VARCHAR(50) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, user_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 研究論文テーブル
CREATE TABLE research_papers (
    paper_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(300) NOT NULL,
    abstract TEXT,
    authors JSON, -- JSON形式で複数著者を保存
    keywords TEXT,
    publication_date DATE,
    journal VARCHAR(150),
    volume VARCHAR(20),
    issue VARCHAR(20),
    pages VARCHAR(20),
    doi VARCHAR(100),
    status ENUM('draft', 'submitted', 'under_review', 'accepted', 'published', 'rejected') DEFAULT 'draft',
    project_id INT,
    file_path VARCHAR(500),
    citation_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_publication_date (publication_date),
    INDEX idx_project (project_id)
);

-- 研究室リソーステーブル
CREATE TABLE lab_resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('equipment', 'software', 'space', 'consumable') NOT NULL,
    description TEXT,
    location VARCHAR(100),
    status ENUM('available', 'in_use', 'maintenance', 'broken') DEFAULT 'available',
    purchase_date DATE,
    warranty_expiry DATE,
    cost DECIMAL(10,2),
    responsible_person_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (responsible_person_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_responsible (responsible_person_id)
);

-- リソース予約テーブル
CREATE TABLE resource_reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    resource_id INT NOT NULL,
    user_id INT NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    purpose TEXT,
    status ENUM('pending', 'approved', 'cancelled', 'completed') DEFAULT 'pending',
    approved_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (resource_id) REFERENCES lab_resources(resource_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_resource_datetime (resource_id, start_datetime, end_datetime),
    INDEX idx_user (user_id),
    INDEX idx_status (status)
);

-- セッションテーブル
CREATE TABLE user_sessions (
    session_id VARCHAR(128) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_expires (expires_at)
);

-- 活動ログテーブル
CREATE TABLE activity_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    details JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- 通知テーブル
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created_at (created_at)
);

-- システム設定テーブル
CREATE TABLE system_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT,
    FOREIGN KEY (updated_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 初期データ挿入

-- デフォルト管理者ユーザー
INSERT INTO users (username, email, password_hash, full_name, role, department) VALUES
('admin', 'admin@mirai-labs.org', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'システム管理者', 'admin', 'システム管理');

-- デフォルトシステム設定
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('site_name', 'MIRAI-LABS', 'サイト名'),
('site_description', '未来研究所管理システム', 'サイト説明'),
('max_file_size', '10485760', '最大ファイルサイズ（バイト）'),
('allowed_file_types', 'pdf,doc,docx,txt,jpg,png', '許可されるファイル形式'),
('session_timeout', '3600', 'セッションタイムアウト時間（秒）'),
('backup_frequency', 'daily', 'バックアップ頻度'),
('email_notifications', '1', 'メール通知の有効化'),
('maintenance_mode', '0', 'メンテナンスモード');

-- インデックスとパフォーマンス最適化
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_projects_title ON projects(title);
CREATE INDEX idx_papers_title ON research_papers(title);
CREATE INDEX idx_resources_name ON lab_resources(name);

-- ビューの作成

-- アクティブプロジェクトビュー
CREATE VIEW active_projects AS
SELECT 
    p.project_id,
    p.title,
    p.description,
    u.full_name as leader_name,
    p.start_date,
    p.end_date,
    p.status,
    p.budget,
    COUNT(pm.user_id) as member_count
FROM projects p
LEFT JOIN users u ON p.leader_id = u.user_id
LEFT JOIN project_members pm ON p.project_id = pm.project_id
WHERE p.status = 'active'
GROUP BY p.project_id;

-- ユーザー統計ビュー
CREATE VIEW user_statistics AS
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    u.role,
    COUNT(DISTINCT pm.project_id) as project_count,
    COUNT(DISTINCT rp.paper_id) as paper_count,
    COUNT(DISTINCT rr.reservation_id) as reservation_count
FROM users u
LEFT JOIN project_members pm ON u.user_id = pm.user_id
LEFT JOIN research_papers rp ON JSON_CONTAINS(rp.authors, JSON_QUOTE(u.username))
LEFT JOIN resource_reservations rr ON u.user_id = rr.user_id
WHERE u.is_active = TRUE
GROUP BY u.user_id;

-- トリガーの作成

-- プロジェクト更新時の活動ログ
DELIMITER //
CREATE TRIGGER project_update_log 
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (user_id, action, target_type, target_id, details)
    VALUES (NEW.leader_id, 'project_updated', 'project', NEW.project_id, 
           JSON_OBJECT('old_status', OLD.status, 'new_status', NEW.status));
END//
DELIMITER ;

-- 論文ステータス変更時の通知
DELIMITER //
CREATE TRIGGER paper_status_notification
AFTER UPDATE ON research_papers
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO notifications (user_id, title, message, type)
        SELECT pm.user_id, 
               CONCAT('論文ステータス更新: ', NEW.title),
               CONCAT('ステータスが「', OLD.status, '」から「', NEW.status, '」に変更されました。'),
               'info'
        FROM project_members pm
        WHERE pm.project_id = NEW.project_id;
    END IF;
END//
DELIMITER ;

-- パフォーマンス最適化のためのパーティショニング（大規模データ用）
-- 活動ログを月単位でパーティション分割
-- ALTER TABLE activity_logs PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
--     PARTITION p202401 VALUES LESS THAN (202402),
--     PARTITION p202402 VALUES LESS THAN (202403),
--     -- 以下、必要に応じて追加
-- );

COMMIT;