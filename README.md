# Ruang Ujian CBT — pemisahan file dan persiapan Supabase

## Isi folder
- `index.html` — struktur halaman.
- `style.css` — seluruh CSS yang sebelumnya berada di dalam HTML.
- `app.js` — JavaScript aplikasi lama yang sebelumnya berada di dalam HTML.
- `supabase-client.js` — konfigurasi awal Supabase.
- `supabase-schema.sql` — rancangan tabel database awal.

## Penting: status integrasi
File HTML/CSS/JavaScript sudah dipisahkan dari revisi CBT terakhir yang tersedia. Namun `app.js` masih menggunakan `localStorage` untuk state aplikasi. Supabase client dan skema SQL di paket ini adalah persiapan integrasi, **bukan berarti akun, token, soal, dan hasil sudah tersinkronisasi online**. Jangan gunakan untuk ujian sungguhan sampai fungsi aplikasi dimigrasikan ke database dan aturan akses server-side diuji.

## Menyiapkan Supabase
1. Buat project di https://supabase.com/.
2. Buka Project Settings → API, salin Project URL dan publishable/anon key.
3. Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` pada `supabase-client.js`.
4. Buka SQL Editor di Supabase, lalu jalankan `supabase-schema.sql`.
5. Sebelum publikasi, buat kebijakan RLS yang sesuai dan mekanisme server-side untuk memeriksa login/role, token, menyimpan jawaban, submit, dan menilai ujian.

## Keamanan wajib
- Jangan pernah memasukkan `service_role` key ke frontend/GitHub.
- Jangan simpan password siswa sebagai teks biasa di tabel `students`.
- Supabase Auth sebaiknya mengelola identitas; username sekolah dapat dipetakan melalui backend/Edge Function ke identitas Auth.
- Jangan izinkan siswa membaca kolom `correct_answer`.
- RLS diaktifkan dan belum diberi policy luas; akses tabel akan tertolak sampai kebijakan yang tepat dibuat.

## Jalankan lokal
Gunakan server statis lokal (misalnya Live Server di VS Code) atau unggah file frontend ke GitHub Pages. Untuk database online, konfigurasi Supabase dan implementasi kebijakan/function harus diselesaikan terlebih dahulu.
