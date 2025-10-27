<?php
$assetPath = '../../asset/';
require_once __DIR__ . '/../partials/header.php';

$q = isset($_GET['q']) ? trim((string)$_GET['q']) : '';
?>

  <h1>検索結果</h1>
  <?php if ($q === ''): ?>
    <p>検索ワードを入力してください。</p>
  <?php else: ?>
    <p>「<?= htmlspecialchars($q, ENT_QUOTES, 'UTF-8'); ?>」の検索結果（ダミー）。DB実装後に結果を表示します。</p>
  <?php endif; ?>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
