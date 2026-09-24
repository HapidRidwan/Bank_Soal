# Bank Soal API

Backend API untuk aplikasi Bank Soal. API ini memakai Node.js, Express, dan MySQL lokal.

## 1. Siapkan MySQL lokal

Pastikan service MySQL berjalan, lalu jalankan isi `database/schema.sql` menggunakan MySQL Workbench, phpMyAdmin, atau client MySQL.

Jika memakai XAMPP dan `mysql.exe` belum ada di PATH PowerShell:

```powershell
Get-Content database\schema.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root -p
```

Jika memakai Laragon:

```powershell
Get-Content database\schema.sql | & 'C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe' -u root -p
```

Sesuaikan lokasi `mysql.exe` dengan instalasi lokal. Password default XAMPP biasanya kosong, sedangkan Laragon biasanya `root`.

## 2. Konfigurasi API

Salin `.env.example` menjadi `.env`, lalu isi secret JWT dan kredensial MySQL.

```powershell
Copy-Item .env.example .env
npm install
npm run dev
```

API berjalan di `http://localhost:3000`. Cek koneksi database di `http://localhost:3000/health`.

### Membuat akun admin

Daftarkan akun melalui aplikasi terlebih dahulu, lalu ubah role akun tersebut di MySQL:

```sql
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
```

Schema juga menyediakan dua akun demo:

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@banksoal.test` | `Admin123!` |
| User | `user@banksoal.test` | `User123!` |

Jalankan `database/schema.sql` setelah database dibuat agar akun demo tersedia. Login admin akan diarahkan ke dashboard admin, sedangkan login user akan diarahkan ke dashboard user.

Saat akun admin login, aplikasi mobile akan mengarahkannya ke dashboard admin.

Untuk Android emulator, alamat API host bukan `localhost`, melainkan `10.0.2.2:3000`. Untuk device fisik, gunakan IP komputer pada jaringan lokal, misalnya `192.168.1.10:3000`.

## Endpoint autentikasi

Semua endpoint auth memakai prefix `/api/auth`.

| Method | Endpoint | Body utama |
| --- | --- | --- |
| POST | `/register` | `username`, `email`, `password`, `fullName` |
| POST | `/login` | `identity`, `password` |
| POST | `/google` | `idToken` dari Google Sign-In |
| POST | `/refresh` | `refreshToken` |
| POST | `/logout` | `refreshToken` |
| GET | `/me` | Header `Authorization: Bearer <accessToken>` |
| POST | `/forgot-password` | `email` |
| POST | `/reset-password` | `token`, `password` |

Access token berumur pendek. Simpan refresh token secara aman di client dan gunakan endpoint `/refresh` untuk membuat pasangan token baru. Logout mencabut refresh token yang dikirim.

## Google Sign-In

1. Buat OAuth client di Google Cloud Console.
2. Isi `GOOGLE_CLIENT_ID` dengan Web Client ID yang dipakai untuk memperoleh ID token.
3. Android membutuhkan package name dan SHA-1/SHA-256 certificate yang benar.
4. Web membutuhkan origin development dan production yang didaftarkan.
5. Client mengirim ID token Google ke `POST /api/auth/google`.

Backend memverifikasi signature, audience, subject, email, dan status email terverifikasi sebelum membuat atau menghubungkan user lokal.

## Password reset lokal

Pada `NODE_ENV=development`, response `/forgot-password` menyertakan `resetToken` agar alur bisa dites tanpa email service. Pada production field itu tidak dikembalikan; endpoint tersebut perlu dihubungkan ke SMTP atau provider email untuk mengirim link reset.

## Catatan keamanan

- Jangan commit file `.env`.
- Gunakan secret JWT acak dan panjang.
- Jangan memakai mode development untuk production.
- Tambahkan rate limit, HTTPS, dan provider email sebelum deployment publik.
