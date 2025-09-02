Masukkan isi file ENV_VARS_*.json ke github action repository secret. 
Backslash dipakai agar di github secret terbaca sebagai json. Kalau langsung json biasa, error jadinya.
- ribet banget njir cara masukin json ke secret github. harus ada backslash gini:

{
    "\"PLAYLIST_API_URL\"": "\"playlist\"",
    "\"GDRIVE_API_URL\"": "\"gdrive_api\"",
    "\"FOURCOVER_API_URL\"": "\"four_cover_album\"",
    "\"CRUD_PLAYLIST_API_URL\"": "\"crud_new_playlist\"",
    "\"MUSIC_PLAYLIST_API_URL\"": "\"music_playlist\"",
    "\"MUSIC_STREAM_API_URL\"": "\"stream\"",
    "\"RECENT_MUSIC_API_URL\"": "\"recents_music\"",
    "\"FAVORITE_API_URL\"": "\"favorite\"",
    "\"APP_ENV\"": "\"production\"",
    "\"DEBUG\"": "\"false\""
}