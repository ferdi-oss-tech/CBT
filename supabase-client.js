/*
 * Konfigurasi Supabase untuk Ruang Ujian CBT.
 * Isi SUPABASE_URL dan SUPABASE_ANON_KEY dari Project Settings > API.
 * Hanya gunakan publishable/anon key di frontend. JANGAN masukkan service_role key.
 * Catatan: file app.js hasil pemisahan masih memakai localStorage; mengisi konfigurasi
 * ini saja belum memindahkan data aplikasi ke Supabase. Ikuti README dan skema SQL.
 */
const SUPABASE_URL = "https://jdcnjdypqzhiszzyyzlb.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_TDl2FMj8KHMvV8FU6tyVbg_SRRaXT-_";

window.supabaseClient = null;
if (
  window.supabase?.createClient &&
  !SUPABASE_URL.includes("YOUR_PROJECT_ID") &&
  !SUPABASE_ANON_KEY.includes("YOUR_SUPABASE")
) {
  window.supabaseClient = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY,
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    },
  );
} else {
  console.warn(
    "Supabase belum dikonfigurasi. Aplikasi lama masih berjalan dengan localStorage.",
  );
}
