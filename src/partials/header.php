<?php
// 呼び出し元で $assetPath を指定可能（例: '../asset/' や '../../asset/'）。デフォルトは '../asset/'.
$assetPath = $assetPath ?? '../asset/';
?>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MIRAI LABS EC</title>
  <link rel="stylesheet" href="<?= htmlspecialchars($assetPath, ENT_QUOTES, 'UTF-8'); ?>css/style.css" />
  <script defer src="<?= htmlspecialchars($assetPath, ENT_QUOTES, 'UTF-8'); ?>js/script.js"></script>
</head>
<body>
  <header class="site-header" role="banner">
    <div class="header-inner">
      <a class="logo" href="../index.php">MIRAI LABS</a>

      <form class="search" action="./pages/search.php" method="get" role="search">
        <input type="text" name="q" placeholder="商品名・型番で検索" aria-label="検索" />
        <button type="submit" aria-label="検索">検索</button>
      </form>

      <div class="header-actions">
        <a class="nav-link" href="./pages/categories.php">商品</a>
        <a class="nav-link" href="../src/start/login.php">ログイン</a>
        <a class="nav-link" href="./pages/cart.php">カート</a>
        <button class="hamburger" aria-label="メニュー" aria-controls="global-nav" aria-expanded="false">☰</button>
      </div>
    </div>
    <nav id="global-nav" class="global-nav" role="navigation">
      <a href="../index.php">ホーム</a>
      <a href="./pages/categories.php">家電</a>
      <a href="#">アクセサリ</a>
      <a href="#">サポート</a>
    </nav>
  </header>
  <main class="content" role="main">
