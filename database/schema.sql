-- ============================================
-- BelajarSMA Database Schema
-- ============================================

-- 1. USERS TABLE (Siswa & Guru)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('siswa', 'guru') NOT NULL,
  avatar_url VARCHAR(500),
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. MATA PELAJARAN TABLE
CREATE TABLE mata_pelajaran (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  icon_url VARCHAR(500),
  warna_hex VARCHAR(7),
  urutan INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. BAB/TOPIK TABLE
CREATE TABLE topik (
  id SERIAL PRIMARY KEY,
  mata_pelajaran_id INT NOT NULL REFERENCES mata_pelajaran(id),
  judul VARCHAR(255) NOT NULL,
  deskripsi TEXT,
  urutan INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. MATERI TABLE
CREATE TABLE materi (
  id SERIAL PRIMARY KEY,
  topik_id INT NOT NULL REFERENCES topik(id),
  judul VARCHAR(255) NOT NULL,
  konten TEXT NOT NULL,
  tipe_konten ENUM('text', 'video', 'mixed') DEFAULT 'text',
  video_url VARCHAR(500),
  guru_id INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. SOAL TABLE
CREATE TABLE soal (
  id SERIAL PRIMARY KEY,
  topik_id INT NOT NULL REFERENCES topik(id),
  pertanyaan TEXT NOT NULL,
  pilihan_a TEXT NOT NULL,
  pilihan_b TEXT NOT NULL,
  pilihan_c TEXT NOT NULL,
  pilihan_d TEXT NOT NULL,
  pilihan_e TEXT,
  jawaban_benar VARCHAR(1) NOT NULL,
  pembahasan TEXT,
  kesulitan ENUM('mudah', 'sedang', 'sulit') DEFAULT 'sedang',
  tipe_soal ENUM('latihan', 'tka_saintek', 'tka_soshum') DEFAULT 'latihan',
  guru_id INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. RONDE SIMULASI TKA
CREATE TABLE ronde_tka (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  tipe_soal VARCHAR(50) NOT NULL,
  jumlah_soal INT DEFAULT 20,
  durasi_menit INT DEFAULT 180,
  urutan INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. SOAL RONDE TKA (Mapping Soal ke Ronde)
CREATE TABLE ronde_tka_soal (
  id SERIAL PRIMARY KEY,
  ronde_tka_id INT NOT NULL REFERENCES ronde_tka(id),
  soal_id INT NOT NULL REFERENCES soal(id),
  urutan INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. LATIHAN SOAL (Progress Siswa pada Latihan)
CREATE TABLE latihan_soal (
  id SERIAL PRIMARY KEY,
  siswa_id INT NOT NULL REFERENCES users(id),
  topik_id INT NOT NULL REFERENCES topik(id),
  soal_id INT NOT NULL REFERENCES soal(id),
  jawaban_siswa VARCHAR(1),
  adalah_benar BOOLEAN,
  waktu_pengerjaan INT,
  started_at TIMESTAMP,
  completed_at TIMESTAMP
);

-- 9. HASIL LATIHAN (Summary per Topik)
CREATE TABLE hasil_latihan (
  id SERIAL PRIMARY KEY,
  siswa_id INT NOT NULL REFERENCES users(id),
  topik_id INT NOT NULL REFERENCES topik(id),
  total_soal INT,
  soal_benar INT,
  soal_salah INT,
  skor_persen DECIMAL(5,2),
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. SIMULASI TKA (Sesi Ujian Siswa)
CREATE TABLE simulasi_tka (
  id SERIAL PRIMARY KEY,
  siswa_id INT NOT NULL REFERENCES users(id),
  ronde_tka_id INT NOT NULL REFERENCES ronde_tka(id),
  status ENUM('draft', 'ongoing', 'completed') DEFAULT 'draft',
  total_soal INT,
  soal_dijawab INT,
  soal_benar INT,
  skor_akhir INT,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. JAWABAN SIMULASI TKA
CREATE TABLE jawaban_simulasi_tka (
  id SERIAL PRIMARY KEY,
  simulasi_tka_id INT NOT NULL REFERENCES simulasi_tka(id),
  soal_id INT NOT NULL REFERENCES soal(id),
  jawaban_siswa VARCHAR(1),
  adalah_benar BOOLEAN,
  waktu_pengerjaan INT,
  urutan INT,
  answered_at TIMESTAMP
);

-- 12. PROGRESS BELAJAR SISWA
CREATE TABLE progress_siswa (
  id SERIAL PRIMARY KEY,
  siswa_id INT NOT NULL REFERENCES users(id),
  mata_pelajaran_id INT NOT NULL REFERENCES mata_pelajaran(id),
  topik_selesai INT DEFAULT 0,
  topik_total INT,
  persen_complete DECIMAL(5,2) DEFAULT 0,
  last_accessed TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. RIWAYAT AKTIVITAS
CREATE TABLE aktivitas_siswa (
  id SERIAL PRIMARY KEY,
  siswa_id INT NOT NULL REFERENCES users(id),
  tipe_aktivitas VARCHAR(50) NOT NULL,
  deskripsi TEXT,
  related_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INDEX untuk performa
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_topik_mata_pelajaran ON topik(mata_pelajaran_id);
CREATE INDEX idx_materi_topik ON materi(topik_id);
CREATE INDEX idx_soal_topik ON soal(topik_id);
CREATE INDEX idx_latihan_siswa ON latihan_soal(siswa_id);
CREATE INDEX idx_hasil_latihan_siswa ON hasil_latihan(siswa_id);
CREATE INDEX idx_simulasi_siswa ON simulasi_tka(siswa_id);
CREATE INDEX idx_progress_siswa ON progress_siswa(siswa_id);
CREATE INDEX idx_aktivitas_siswa ON aktivitas_siswa(siswa_id);
