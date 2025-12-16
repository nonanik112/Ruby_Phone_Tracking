# Ruby Phone Tracking Projesi
<!-- ========== TÜRKÇE ========== -->
# 📡 Gelişmiş Telefon Takip Sistemi (API’siz + AI + Blockchain)

> **Hiçbir harici API'ye bağımlı olmadan** çalışan, **yapay zeka destekli**, **blockchain güvenlikli** ve **IoT sensör füzyonlu** gerçek zamanlı cihaz takip platformu.

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Win%20%7C%20macOS-lightgrey.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

## 🔒 Zero-External-API & Legal Boundary
This tool **never phones home**.  
- **GPS**: your **own USB-serial dongle** – no Google Maps, no cell-tower query.  
- **Wi-Fi / Bluetooth**: local `iwlist` / `BlueZ` scans – no cloud triangulation.  
- **AI models**: offline Torch CPU weights – no HuggingFace, no Torch Hub.  
- **Maps / geocoding**: rendered by **your own Matplotlib / Folium** – zero external tile server.  

**Result**: **no API key, no cloud bill, no privacy leak** – **fully air-gapped** operation.  
**Limitation**: accuracy is **lower** than cloud services (≈ 3-15 m GPS, ≈ 30-100 m Wi-Fi) – **but legal and ethical**.  
**Use only on devices you own or have explicit permission to test** – **academic / pen-test sandbox** by design.

<img width="1449" height="286" alt="Image" src="https://github.com/user-attachments/assets/ab8b72d6-f3a3-4362-9e98-fc726d903326" />

## ✨ Öne Çıkan Özellikler
- **🧠 Yapay Zeka**: LSTM ile gelecek konum tahmini, IsolationForest anomali tespiti
- **⛓️ Blockchain**: SHA-256 hash, değiştirilemez konum kaydı
- **📡 IoT Füzyonu**: GPS seri, Wi-Fi triangülasyon, Bluetooth proximity, QR kamera, ses finger-print
- **⚡ Edge Computing**: <100 ms gecikme, çevrimdışı mod
- **🔐 Güvenlik**: AES-256 Fernet şifreleme, yerel depolama
- **📊 Otomatik Rapor**: HTML + PNG, 7 günlük detay

📸 Screenshot

<img width="700" height="466" alt="Image" src="https://github.com/user-attachments/assets/60734cb1-b2e9-4c49-bf7d-7fb75c1420c5" />

## 🚀 Hızlı Başlangıç
```bash
git clone https://github.com/nonanik112/Phone_Tracking.git
cd Phone_Tracking
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python src/tracking.py
```
# Menü → 3 (Demo Modu) ile hemen test et!

🛠️ Gereksinimler

    Python ≥ 3.9
    GPS dongle (opsiyonel)
    Bluetooth 4.0+ (opsiyonel)
    Kamera (opsiyonel)

🔌 Opsiyonel API (İstersen)

    Google Maps Platform: 10.000 ücretsiz/ay
    OpenCage: 75.000 ücretsiz/ay
    Mapbox: 50.000 ücretsiz/ay

📄 Lisans
BY_MIT – ticari kullanım serbest.
<!-- ========== ENGLISH ========== -->
📡 Advanced Phone Tracking System (API-Free + AI + Blockchain)

    Real-time device tracking platform without any external API, powered by AI, blockchain and IoT sensor fusion.

✨ Key Features

    🧠 AI: LSTM future-location prediction, IsolationForest anomaly detection
    ⛓️ Blockchain: SHA-256 hash, immutable ledger
    📡 IoT Fusion: GPS serial, Wi-Fi triangulation, Bluetooth proximity, QR camera, audio finger-print
    ⚡ Edge Computing: <100 ms latency, offline mode
    🔐 Security: AES-256 Fernet encryption, local storage
    📊 Auto Report: HTML + PNG, 7-day detailed

🚀 Quick Start
```

bash
Copy

git clone https://github.com/nonanik112/Phone_Tracking.git
cd Phone_Tracking
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python src/phone_tracker.py
# Menu → 3 (Demo Mode) and enjoy!

```
🛠️ Requirements

    Python ≥ 3.9
    GPS dongle (optional)
    Bluetooth 4.0+ (optional)
    Camera (optional)

🔌 Optional APIs (if you want)

    Google Maps Platform: 10k free/month
    OpenCage: 75k free/month
    Mapbox: 50k free/month

📄 License
MIT – free for commercial use.
Copy

<img width="700" height="467" alt="Image" src="https://github.com/user-attachments/assets/8ffdef50-9c77-4dc4-8e6b-7bb50fcb934d" />


### 🎯 Ekstra 30 Saniye – Görsel & Link

1. `docs/demo.gif` yapıştır (basit ekran kaydı bile yeterli).  
2. `requirements.txt` zaten varsa bağlantısını ver:  
```markdown
 ## 📦 Dependencies
 See [requirements.txt](requirements.txt)

 LICENSE dosyası yoksa oluştur: bash
```
" echo "BY_MIT License" > LICENSE"


