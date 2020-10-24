# FurMikrotik Bot
Pada dasarnya kegunaan script ini adalah untuk menjadikan router mikrotik kita sebagai server dari telegram bot
karena saya tidak bisa membeli server untuk menjalankan bot telegram maka saya membuat ini sebagai alternatif,
script ini memiliki banyak fungsi yang bisa digunakan untuk membantu kita sehari-hari, contohnya perintah `/corona`
bisa digunakan untuk mengetahui data pasien corona di dunia, dan masih banyak perintah bermanfaat lainnya

---

## Instalasi
Untuk menginstal script ini anda butuh token telegram bot serta ChatID akun telegram anda, untuk cara membuat telegram bot bisa dicari di internet.
Setelah mendapatkan token bot telegram dan ChatID nya, lalu ikuti step dibawah ini

1. Download file setup.rsc
2. Import file setup.rsc kedalam mikrotik dengan cara drag and drop melalui winbox atau menggunakan aplikasi tambahan seperti FileZilla atau WinSCP
3. Buka terminal MikroTik anda dan copy paste perintah ini: `/import file-name=setup.rsc`
4. Arahkan winbox ke System >> Script >> tg_config, lalu konfigurasikan sesuai dengan yang anda miliki dengan mengikuti penjelasan [disini](#penjelasan-konfigurasi-tg_config)

### Penjelasan Konfigurasi tg_config
* `"botAPI"="xxxxxxxxxxxxxx:xxxxxxxxxx";` ganti dengan bot token anda
* `"defaultChatID"="xxxxxxxxxx";` ganti dengan ChatID milik anda
* `"trusted"="xxxxxxx, xxxxxxxx, xxxxxxxx";` ini adalah daftar akun telegram yang menjadi admin bot, diisi dengan ChatID per user
* `"storage"="";` ini adalah konfigurasi tempat menyimpan file file telegram. Saran saya biarkan default
* `"timeout"=5;` yang ini juga biarkan default
* `"refresh_active"=15;` yang ini juga biarkan default
* `"refresh_standby"=300;` yang ini juga biarkan default
* `"available_for_public"=true;` apabila anda ingin bot anda bisa diakses seluruh pengguna telegram maka biarkan `true`, jika tidak silahkan ganti `false`

## Daftar perintah
| Perintah | Fungsi | Contoh |
| -------- | ------ | ------ |
| ``/help`` |  Menampilkan daftar perintah yang tersedia | ``/help`` |
| ``/install`` |  Menginstall perintah | `/install jokes` |
| ``/update`` |  Mengupdate perintah | `/update jokes` |

## Catatan
* Untuk menampilkan daftar perintah lengkap gunakan fitur /help pada telegram bot anda
* Untuk menampilkan penjelasan perintah silahkan menggunakan `/perintah help`. contoh apabila anda ingin menampilkan penjelasan untuk perintah `jokes` maka ketikkan `/jokes help`

## Changelog / Catatan Perubahan
* [INDONESIA](CHANGELOG-ID.md)
* [ENGLISH](CHANGELOG-EN.md)