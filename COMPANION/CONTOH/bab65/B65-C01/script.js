// script.js: Logika Keranjang & Filter Toko Kriya
let count = 0;
const badge = document.querySelector('.badge-keranjang');
const buyButtons = document.querySelectorAll('.btn-tambah-keranjang');

buyButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    count++;
    badge.textContent = count;
    btn.textContent = '✓ Ditambahkan!';
    btn.style.backgroundColor = '#15803d';
    setTimeout(() => {
      btn.textContent = 'Tambah ke Keranjang';
      btn.style.backgroundColor = '#1c1917';
    }, 1200);
  });
});
