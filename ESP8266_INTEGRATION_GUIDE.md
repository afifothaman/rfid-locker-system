# RapidKL Smart Locker - ESP8266 Integration Guide

## 🔧 **Hardware Setup**

### **Components:**
- ESP8266 (NodeMCU or Wemos D1 Mini)
- RC522 RFID Reader Module
- SG90 Servo Motor
- Jumper wires
- Micro USB cable (ESP8266 to computer)

### **ESP8266 Pin Mapping Reference:**
```
NodeMCU Label → GPIO Pin
D0 → GPIO16    D1 → GPIO5     D2 → GPIO4     D3 → GPIO0
D4 → GPIO2     D5 → GPIO14    D6 → GPIO12    D7 → GPIO13
D8 → GPIO15    D9 → GPIO3     D10 → GPIO1
```

### **Wiring Connections:**

#### **RC522 RFID → ESP8266 (NodeMCU)**
```
RC522 Pin    →    NodeMCU Pin    →    GPIO
VCC          →    3.3V           →    3.3V Power
RST          →    D3             →    GPIO0
GND          →    GND            →    Ground
MISO         →    D6             →    GPIO12
MOSI         →    D7             →    GPIO13
SCK          →    D5             →    GPIO14
SDA          →    D4             →    GPIO2
```

#### **SG90 Servo → ESP8266 (NodeMCU)**
```
Servo Wire   →    NodeMCU Pin    →    Notes
Red (VCC)    →    3.3V or VIN    →    May need external 5V for strong torque
Brown (GND)  →    GND            →    Ground
Orange (PWM) →    D8             →    GPIO15 (PWM capable)
```

### **⚠️ Important ESP8266 Notes:**
- **3.3V Logic**: ESP8266 operates at 3.3V (not 5V like Arduino)
- **Power**: RC522 works fine with 3.3V
- **Servo Power**: SG90 may need external 5V for full torque
- **Serial Baud**: ESP8266 typically uses 115200 baud (not 9600)

## 💻 **Arduino IDE Setup for ESP8266**

### **1. Install ESP8266 Board Package**
```
1. Open Arduino IDE
2. Go to File → Preferences
3. Add this URL to "Additional Board Manager URLs":
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
4. Go to Tools → Board → Boards Manager
5. Search "ESP8266" and install "ESP8266 by ESP8266 Community"
```

### **2. Install Required Libraries**
```
1. Go to Tools → Manage Libraries
2. Search and install:
   - "MFRC522 by GithubCommunity" (v1.4.10+)
   - "Servo" (ESP8266Servo or built-in)
```

### **3. Board Configuration**
```
1. Select Board: Tools → Board → ESP8266 Boards → NodeMCU 1.0 (ESP-12E Module)
2. Set Upload Speed: 115200
3. Set CPU Frequency: 80 MHz
4. Set Flash Size: 4MB (FS:2MB OTA:~1019KB)
5. Select Port: Tools → Port → (your ESP8266's COM port)
```

### **4. Upload Code**
```
1. Connect ESP8266 to computer via USB
2. Open RapidKL_ESP8266_Simple.ino
3. Click Upload (or Ctrl+U)
4. Wait for "Hard resetting via RTS pin..." message
```

## 📡 **Serial Communication**

### **Baud Rate: 115200** (ESP8266 standard)
```
// In your Flutter ArduinoSerialService, update:
static int _baudRate = 115200; // Change from 9600 to 115200
```

### **Communication Protocol:**

#### **ESP8266 → Flutter Messages:**
```
SYSTEM_READY                    // ESP8266 is ready
RFID_SCAN:A1B2C3D4             // RFID card detected
ACCESS_GRANTED - Unlocking locker  // Servo unlocking
Auto-lock - locker secured      // Servo locked again
Timeout - no response from Flutter // No Flutter response
```

#### **Flutter → ESP8266 Commands:**
```
ACCESS_GRANTED                  // Unlock servo
ACCESS_DENIED                   // Keep locked
STATUS                         // Get system status
UNLOCK                         // Manual unlock
LOCK                          // Manual lock
PING                          // Connectivity test
```

## 🧪 **Testing Steps**

### **1. Hardware Test**
```bash
1. Upload ESP8266 code
2. Open Serial Monitor (115200 baud)
3. Should see: "SYSTEM_READY" and initialization messages
4. Scan RFID card → Should see: "RFID_SCAN:XXXXXXXX"
5. Type "ACCESS_GRANTED" → servo should unlock for 3 seconds
```

### **2. Flutter Integration**
```dart
// Update your ArduinoSerialService:
class ArduinoSerialService {
  static String _portName = 'COM3'; // Update to ESP8266's port
  static int _baudRate = 115200;    // ESP8266 baud rate
  
  // Rest of the code remains the same
}
```

### **3. End-to-End Test**
```bash
1. Run Flutter app: flutter run
2. Connect to ESP8266 via Arduino Test utility
3. Scan RFID card
4. Verify Flutter processes the UID
5. Check servo responds correctly
```

## 🔧 **Flutter Code Updates**

### **Update Serial Service (if needed):**
```dart
// In lib/services/arduino_serial_service.dart
class ArduinoSerialService {
  static String _portName = 'COM3'; // Change to your ESP8266's port
  static int _baudRate = 115200;    // ESP8266 standard baud rate
  
  // The rest of your existing code should work fine
  // ESP8266 sends same message format: "RFID_SCAN:UID"
}
```

## 🐛 **Troubleshooting**

### **ESP8266 Not Detected:**
```bash
- Install CH340 or CP2102 USB drivers (depending on your board)
- Try different USB cable (data cable, not just power)
- Press and hold FLASH button while connecting (if needed)
- Check Device Manager for COM port
```

### **Upload Issues:**
```bash
- Lower upload speed to 57600 if 115200 fails
- Press and hold FLASH button during upload
- Try different USB port
- Restart Arduino IDE
```

### **RFID Not Working:**
```bash
- Double-check wiring (3.3V power, correct GPIO pins)
- Try different RFID cards
- Check SPI connections (MISO, MOSI, SCK, SDA)
- Ensure RC522 module is not damaged
```

### **Servo Issues:**
```bash
- Check if servo needs external 5V power
- Verify PWM pin connection (D8 → GPIO15)
- Test servo with simple sweep code first
- Some servos may need different pulse widths
```

### **Serial Communication Problems:**
```bash
- Update Flutter baud rate to 115200
- Close Arduino Serial Monitor before running Flutter
- Check COM port in Flutter code
- Verify ESP8266 is not in deep sleep mode
```

## ⚡ **ESP8266 Advantages for Your FYP**

### **Why ESP8266 is Great:**
- **Smaller & Cheaper**: More compact than Arduino Mega
- **Built-in WiFi**: Future expansion possible (though not used now)
- **More GPIO**: Sufficient pins for your project
- **Lower Power**: Better for battery operation (if needed later)
- **Modern**: More current technology for FYP presentation

### **Performance:**
- **CPU**: 80MHz (vs Arduino's 16MHz)
- **RAM**: 80KB (sufficient for your application)
- **Flash**: 4MB (plenty of storage)
- **Voltage**: 3.3V (modern standard)

## 📋 **Quick Reference**

### **Key Differences from Arduino:**
- **Baud Rate**: 115200 (not 9600)
- **Voltage**: 3.3V logic (not 5V)
- **Pin Names**: D0-D10 (not digital 0-13)
- **Power**: May need external 5V for servo

### **Serial Commands for Testing:**
```
ACCESS_GRANTED  → Unlock servo
ACCESS_DENIED   → Keep locked
STATUS          → Show system info
UNLOCK          → Manual unlock
LOCK            → Manual lock
PING            → Test connection (returns PONG)
```

## ✅ **Final Checklist**

- [ ] ESP8266 board package installed in Arduino IDE
- [ ] MFRC522 library installed
- [ ] Correct board selected (NodeMCU 1.0)
- [ ] Hardware wired correctly (3.3V for RC522)
- [ ] Code uploaded successfully
- [ ] Serial Monitor shows "SYSTEM_READY" at 115200 baud
- [ ] RFID cards can be read
- [ ] Servo responds to commands
- [ ] Flutter baud rate updated to 115200
- [ ] End-to-end communication working

Your ESP8266-based RapidKL Smart Locker System is ready! 🚀

**ESP8266 is actually a better choice than Arduino Mega for modern IoT projects - great decision for your FYP!** 👍