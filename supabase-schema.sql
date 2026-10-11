-- Skema awal Supabase untuk CBT sekolah.
-- Tinjau dan sesuaikan sebelum dipakai ujian sungguhan.
-- Penting: autentikasi proktor harus memakai Supabase Auth + role/izin server-side.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null check (role in ('proctor','student')),
  created_at timestamptz not null default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete set null,
  full_name text not null,
  username text not null unique,
  class_name text not null,
  school_name text not null default '',
  is_active boolean not null default true,
  integrity_strikes integer not null default 0,
  permanently_blocked boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text not null,
  duration_minutes integer not null default 30 check (duration_minutes between 1 and 300),
  exam_date date,
  is_published boolean not null default false,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.exam_questions (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  question_order integer not null,
  question_text text not null,
  options jsonb not null default '[]'::jsonb,
  -- Jangan pernah izinkan siswa membaca correct_answer melalui kebijakan SELECT.
  correct_answer text not null,
  points numeric not null default 1,
  unique (exam_id, question_order)
);

create table if not exists public.exam_tokens (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  token_hash text not null,
  is_active boolean not null default true,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.exam_attempts (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id),
  student_id uuid not null references public.students(id),
  status text not null default 'in_progress' check (status in ('in_progress','submitted','graded')),
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  score numeric,
  unique (exam_id, student_id)
);

create table if not exists public.exam_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.exam_attempts(id) on delete cascade,
  question_id uuid not null references public.exam_questions(id),
  answer text,
  updated_at timestamptz not null default now(),
  unique (attempt_id, question_id)
);

create table if not exists public.proctor_settings (
  id uuid primary key default gen_random_uuid(),
  proctor_id uuid not null unique references auth.users(id) on delete cascade,
  school_name text not null default '',
  profile_photo_url text,
  updated_at timestamptz not null default now()
);

-- Aktifkan RLS. Kebijakan produksi harus ditambahkan dengan aturan per role.
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.exams enable row level security;
alter table public.exam_questions enable row level security;
alter table public.exam_tokens enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.exam_answers enable row level security;
alter table public.proctor_settings enable row level security;

-- Default deny: tanpa policy, akses API ke tabel ini ditolak oleh RLS.
-- Jangan membuat policy SELECT umum untuk exam_questions karena correct_answer harus dirahasiakan.
-- Untuk ujian sungguhan, buat RPC/Edge Function server-side untuk validasi token,
-- mulai/submit ujian, dan penilaian tanpa mengirim correct_answer ke browser siswa.
