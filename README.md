# 🌟 WanderSafe Foresight App  
AI-Powered Predictive Navigation for the Visually Impaired

---

## 📱 App Overview

WanderSafe Foresight is a next-generation assistive technology app built using **Flutter + Python (Flask)**.  
It provides real-time **hazard detection**, **predictive movement tracking**, **vibration alerts**, and **voice assistance** for visually-impaired users.

---

## 🛡️ Key Features

- 🚀 **Real-Time Hazard Detection** using YOLOv8  
- 📡 **Predictive Path Tracking** (anticipates moving objects & collision risks)  
- 🔉 **Voice Alerts** for warnings  
- 📳 **Directional Vibration Feedback**  
- 🎯 **Trajectory Prediction System**  
- 🎨 **Elegant Flutter UI + Custom Visual Overlays**  

---

## 🎨 App Branding

![App Logo](/mnt/data/A_flat_vector_graphic_features_a_logo_consisting_o.png)

---

## 📸 Real-Time Hazard Detection (Mockup)
<img width="403" height="599" alt="image" src="https://github.com/user-attachments/assets/20d321f9-1b91-4df0-af2c-f61d700ffbd4" />


---

## ⚙️ System Architecture

The app uses this workflow:

1. Flutter app captures camera frame  
2. Sends image → Python backend (`/detect`)  
3. YOLO processes objects  
4. Backend returns:  
   - labels  
   - bounding boxes  
   - distances  
   - velocity  
   - hazard status  
5. Flutter displays:  
   - bounding boxes  
   - trajectories  
   - predicted collision lines  
   - warning messages  
6. Device vibrates + speaks warnings

---

## 🧠 Predictive Navigation Logic

The system:
- Tracks objects for **15 consecutive frames**
- Calculates **smoothed velocity**
- Predicts **2 seconds ahead**
- Computes **Time-to-Collision (TTC)**
- Determines:
  - urgency level  
  - vibration pattern  
  - speech message  
  - motion direction  

---

## 📳 Vibration Patterns

| Condition | Pattern |
|----------|---------|
| **Immediate danger (TTC < 1.5s)** | 4 rapid pulses |
| **Warning (1.5–3s)** | left/right directional double-pulse |
| **Caution** | one short pulse |

---

## 🗣️ Voice Alerts Examples

- “**Stop! Person approaching fast from your left!**”
- “**Warning — bicycle moving toward you**”
- “**Caution: object on your right**”

---

## 🧩 Tech Stack

### **Frontend (Flutter)**
- Flutter / Dart  
- camera  
- flutter_tts  
- vibration  
- http  
- CustomPainters  

### **Backend (Python)**
- Flask  
- Flask-CORS  
- ultralytics (YOLOv8)  
- OpenCV  
- Pillow  

---

## 🚀 Backend Setup

```sh
py -3.10 -m venv .venv
.\.venv\Scripts\activate
pip install flask flask-cors ultralytics opencv-python pillow
python api_server.py
