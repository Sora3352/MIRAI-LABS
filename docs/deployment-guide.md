# MIRAI-LABS デプロイメントガイド

## 概要
このドキュメントは、MIRAI-LABSシステムの本番環境へのデプロイメント手順を詳細に説明します。

## 前提条件

### システム要件
- **OS**: Ubuntu 20.04 LTS以上 または CentOS 8以上
- **CPU**: 2コア以上
- **メモリ**: 4GB以上
- **ストレージ**: 50GB以上の空き容量
- **ネットワーク**: インターネット接続必須

### 必要なソフトウェア
- Apache 2.4以上 または Nginx 1.18以上
- PHP 8.0以上
- MySQL 8.0以上
- Composer (PHP パッケージマネージャー)
- Git
- SSL証明書

## 1. サーバー環境準備

### 1.1 パッケージ更新
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 1.2 Apache & PHP インストール
```bash
# Ubuntu/Debian
sudo apt install apache2 php8.1 php8.1-mysql php8.1-curl php8.1-json \
                 php8.1-zip php8.1-mbstring php8.1-xml php8.1-gd \
                 libapache2-mod-php8.1 -y

# CentOS/RHEL
sudo yum install httpd php php-mysql php-curl php-json php-zip \
                 php-mbstring php-xml php-gd -y
```

### 1.3 MySQL インストール
```bash
# Ubuntu/Debian
sudo apt install mysql-server -y

# CentOS/RHEL
sudo yum install mysql-server -y

# MySQL セキュリティ設定
sudo mysql_secure_installation
```

### 1.4 Composer インストール
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

## 2. アプリケーションデプロイ

### 2.1 リポジトリクローン
```bash
# Webルートディレクトリに移動
cd /var/www

# リポジトリクローン
sudo git clone https://github.com/Sora3352/MIRAI-LABS.git
sudo chown -R www-data:www-data MIRAI-LABS
sudo chmod -R 755 MIRAI-LABS
```

### 2.2 設定ファイル作成
```bash
cd /var/www/MIRAI-LABS

# 環境設定ファイル作成
sudo cp .env.example .env
sudo nano .env
```

**.env ファイルの設定例**
```bash
# データベース設定
DB_HOST=localhost
DB_NAME=mirai_labs
DB_USER=mirai_user
DB_PASS=secure_password

# アプリケーション設定
APP_ENV=production
APP_DEBUG=false
APP_URL=https://mirai-labs.org

# JWT設定
JWT_SECRET=your_jwt_secret_key_here

# メール設定
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=noreply@mirai-labs.org
MAIL_PASSWORD=your_mail_password
MAIL_FROM=noreply@mirai-labs.org

# ファイルアップロード設定
UPLOAD_MAX_SIZE=10485760
UPLOAD_PATH=/var/www/MIRAI-LABS/uploads
```

### 2.3 ディレクトリ権限設定
```bash
# アップロードディレクトリ作成
sudo mkdir -p uploads logs cache
sudo chown -R www-data:www-data uploads logs cache
sudo chmod -R 755 uploads logs cache

# 設定ファイル権限
sudo chmod 600 .env
```

## 3. データベース設定

### 3.1 データベース作成
```bash
# MySQLに接続
sudo mysql -u root -p

# データベースとユーザー作成
CREATE DATABASE mirai_labs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mirai_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON mirai_labs.* TO 'mirai_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3.2 スキーマ作成
```bash
# スキーマファイル実行
mysql -u mirai_user -p mirai_labs < docs/database-schema.sql
```

## 4. Webサーバー設定

### 4.1 Apache Virtual Host設定
```bash
sudo nano /etc/apache2/sites-available/mirai-labs.conf
```

```apache
<VirtualHost *:80>
    ServerName mirai-labs.org
    ServerAlias www.mirai-labs.org
    DocumentRoot /var/www/MIRAI-LABS/src
    
    <Directory /var/www/MIRAI-LABS/src>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/mirai-labs_error.log
    CustomLog ${APACHE_LOG_DIR}/mirai-labs_access.log combined
    
    # HTTPSにリダイレクト
    RewriteEngine on
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName mirai-labs.org
    ServerAlias www.mirai-labs.org
    DocumentRoot /var/www/MIRAI-LABS/src
    
    SSLEngine on
    SSLCertificateFile /path/to/your/certificate.crt
    SSLCertificateKeyFile /path/to/your/private.key
    SSLCertificateChainFile /path/to/your/ca-bundle.crt
    
    <Directory /var/www/MIRAI-LABS/src>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/mirai-labs_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/mirai-labs_ssl_access.log combined
</VirtualHost>
```

### 4.2 Apache モジュール有効化とサイト設定
```bash
# 必要なモジュール有効化
sudo a2enmod rewrite ssl headers

# サイト有効化
sudo a2ensite mirai-labs
sudo a2dissite 000-default

# Apache再起動
sudo systemctl restart apache2
```

### 4.3 .htaccess設定
```bash
sudo nano /var/www/MIRAI-LABS/src/.htaccess
```

```apache
RewriteEngine On

# HTTPSリダイレクト
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]

# セキュリティヘッダー
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

# ファイルアクセス制限
<Files ".env">
    Order allow,deny
    Deny from all
</Files>

<Files "*.sql">
    Order allow,deny
    Deny from all
</Files>

# ディレクトリインデックス無効化
Options -Indexes

# URL Rewriting (Clean URLs)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^api/(.*)$ api/index.php [QSA,L]
RewriteRule ^(.*)$ index.php [QSA,L]
```

## 5. SSL証明書設定

### 5.1 Let's Encrypt使用の場合
```bash
# Certbot インストール
sudo apt install certbot python3-certbot-apache -y

# 証明書取得
sudo certbot --apache -d mirai-labs.org -d www.mirai-labs.org

# 自動更新設定
sudo crontab -e
# 以下を追加
0 12 * * * /usr/bin/certbot renew --quiet
```

## 6. セキュリティ設定

### 6.1 ファイアウォール設定
```bash
# UFW インストール・設定
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Apache Full'
sudo ufw status
```

### 6.2 PHP セキュリティ設定
```bash
sudo nano /etc/php/8.1/apache2/php.ini
```

```ini
# セキュリティ設定
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log

# ファイルアップロード設定
file_uploads = On
upload_max_filesize = 10M
post_max_size = 10M
max_file_uploads = 5

# セッション設定
session.cookie_secure = 1
session.cookie_httponly = 1
session.use_strict_mode = 1
```

## 7. バックアップ設定

### 7.1 データベースバックアップスクリプト
```bash
sudo nano /usr/local/bin/backup-mirai-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backup/mirai-labs"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="mirai_labs"
DB_USER="mirai_user"
DB_PASS="secure_password"

mkdir -p $BACKUP_DIR

# データベースバックアップ
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# ファイルバックアップ
tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz /var/www/MIRAI-LABS/uploads

# 古いバックアップ削除（30日以上）
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
sudo chmod +x /usr/local/bin/backup-mirai-db.sh

# Cron設定（毎日2時にバックアップ）
sudo crontab -e
0 2 * * * /usr/local/bin/backup-mirai-db.sh >> /var/log/backup.log 2>&1
```

## 8. 監視・ログ設定

### 8.1 ログローテーション設定
```bash
sudo nano /etc/logrotate.d/mirai-labs
```

```
/var/www/MIRAI-LABS/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    notifempty
    create 644 www-data www-data
    postrotate
        /bin/systemctl reload apache2 > /dev/null 2>&1 || true
    endscript
}
```

### 8.2 システム監視スクリプト
```bash
sudo nano /usr/local/bin/monitor-mirai.sh
```

```bash
#!/bin/bash
LOG_FILE="/var/log/mirai-monitor.log"
ALERT_EMAIL="admin@mirai-labs.org"

# ディスク使用量チェック
DISK_USAGE=$(df /var/www | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "$(date): WARNING - Disk usage: $DISK_USAGE%" >> $LOG_FILE
    echo "Disk usage warning: $DISK_USAGE%" | mail -s "MIRAI-LABS Disk Alert" $ALERT_EMAIL
fi

# MySQL接続チェック
if ! mysqladmin ping -h localhost > /dev/null 2>&1; then
    echo "$(date): ERROR - MySQL is not responding" >> $LOG_FILE
    echo "MySQL service is down" | mail -s "MIRAI-LABS MySQL Alert" $ALERT_EMAIL
fi

# Apache接続チェック
if ! curl -f http://localhost > /dev/null 2>&1; then
    echo "$(date): ERROR - Apache is not responding" >> $LOG_FILE
    echo "Apache service is down" | mail -s "MIRAI-LABS Apache Alert" $ALERT_EMAIL
fi
```

## 9. パフォーマンス最適化

### 9.1 OPcache設定
```bash
sudo nano /etc/php/8.1/apache2/conf.d/99-opcache.ini
```

```ini
; OPcache設定
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.save_comments=1
opcache.enable_file_override=1
```

### 9.2 MySQL最適化
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
# 性能設定
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
query_cache_type = 1
query_cache_size = 64M
max_connections = 200
```

## 10. デプロイメント完了確認

### 10.1 チェックリスト
- [ ] Webサイトアクセス確認 (https://mirai-labs.org)
- [ ] SSL証明書確認
- [ ] データベース接続確認
- [ ] ログイン機能確認
- [ ] ファイルアップロード確認
- [ ] エラーログ確認
- [ ] バックアップテスト
- [ ] メール送信テスト

### 10.2 トラブルシューティング

#### よくある問題と解決方法

**1. 500 Internal Server Error**
```bash
# エラーログ確認
sudo tail -f /var/log/apache2/mirai-labs_error.log

# PHP エラーログ確認
sudo tail -f /var/log/php_errors.log
```

**2. データベース接続エラー**
```bash
# MySQL接続テスト
mysql -u mirai_user -p mirai_labs

# .env ファイル確認
cat /var/www/MIRAI-LABS/.env
```

**3. ファイルアップロードエラー**
```bash
# ディレクトリ権限確認
ls -la /var/www/MIRAI-LABS/uploads

# PHP設定確認
php -i | grep upload
```

## 11. 本番運用開始

### 11.1 運用開始前の最終チェック
1. セキュリティスキャン実行
2. 負荷テスト実行
3. バックアップ・復旧テスト
4. 監視アラート確認
5. ドキュメント更新

### 11.2 運用体制
- **システム管理者**: サーバー管理、監視
- **開発チーム**: アプリケーション保守、機能追加
- **セキュリティ担当**: セキュリティ監視、脆弱性対応

---

**文書バージョン**: 1.0  
**最終更新**: 2024年12月  
**作成者**: MIRAI-LABS開発チーム