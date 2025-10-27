<?php
// トップページ。共通ヘッダー/フッターを読み込み。
$assetPath = '../asset/';
require_once __DIR__ . '/partials/header.php';
?>

	<section class="hero">
		<div>
			<h1>最新の電化製品・家電を、スマートに。</h1>
			<p>今はDB構築中のためダミー表示です。完成後に商品一覧がここに並びます。</p>
		</div>
	</section>

	<section>
		<h2>人気カテゴリー</h2>
		<div class="grid">
			<div class="card"><strong>テレビ</strong><p>4K/有機ELなど</p></div>
			<div class="card"><strong>冷蔵庫</strong><p>省エネモデル</p></div>
			<div class="card"><strong>掃除機</strong><p>スティック/ロボット</p></div>
			<div class="card"><strong>エアコン</strong><p>高効率インバータ</p></div>
		</div>
	</section>

<?php
require_once __DIR__ . '/partials/footer.php';
?>

