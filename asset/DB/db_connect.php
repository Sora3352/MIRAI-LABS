<?php
declare(strict_types=1);

/**
 * DB接続ハンドラを返します（シングルトン）。
 * 環境変数が設定されていればそれを優先し、未設定時は既定値（添付の情報）を使用します。
 *
 * 優先される環境変数:
 * - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS
 */
function db(): PDO
{
	static $pdo = null;
	if ($pdo instanceof PDO) {
		return $pdo;
	}

	$host = getenv('DB_HOST') ?: 'mysql326.phy.lolipop.lan';
	$port = getenv('DB_PORT') ?: '3306';
	$name = getenv('DB_NAME') ?: 'LAA1607503-mirailabs';
	$user = getenv('DB_USER') ?: 'LAA1607503';
	$pass = getenv('DB_PASS') ?: 'MIRAI12345';

	$dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $host, $port, $name);

	$options = [
		PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,            // 例外でエラーを受け取る
		PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // 連想配列で取得
		PDO::ATTR_EMULATE_PREPARES => false,                    // ネイティブのプリペアドを使用
	];

	try {
		$pdo = new PDO($dsn, $user, $pass, $options);
		// 文字セットを明示（互換性のため）。
		$pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
	} catch (PDOException $e) {
		// 本番では詳細を表示しない。ログにのみ出力。
		error_log('[DB] Connection failed: ' . $e->getMessage());
		http_response_code(500);
		throw $e; // 呼び出し側でハンドリング可能にする
	}

	return $pdo;
}

/*
使用例:

require_once __DIR__ . '/db_connect.php';
$pdo = db();

// 例: ユーザー一覧取得
//$stmt = $pdo->query('SELECT * FROM users');
//$rows = $stmt->fetchAll();
*/
?>

