document.addEventListener('DOMContentLoaded', () => {
	const header = document.querySelector('.site-header');
	const btn = document.querySelector('.hamburger');
	if (header && btn) {
		btn.addEventListener('click', () => {
			const expanded = btn.getAttribute('aria-expanded') === 'true';
			btn.setAttribute('aria-expanded', String(!expanded));
			header.classList.toggle('nav-open');
		});
	}
});

