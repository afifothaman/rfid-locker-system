/*
 * RapidKL Smart Locker System - ESP8266 Minimal Code
 * Final Year Project (FYP) - ESP8266 Version
 * 
 * Hardware: ESP8266 (NodeMCU) + RC522 RFID + SG90 Servo
 * Communication: USB Serial with Flutter App (No WiFi)
 * 
 * Simple Flow:
 * 1. Read RFID card UID
 * 2. Send UID to Flutter via Serial
 * 3. Wait for ACCESS_GRANTED or ACCESS_DENIED response
 * 4. Control servo accordingly
 */

#include <SPI.h>
#include <MFRC522.h>
#include <Servo.h>

// Pin Definitions for ESP8266 (NodeMCU)
#define RST_PIN    D3    // RC522 Reset pin
#define SS_PIN     D4    // RC522 SDA pin
#define SERVO_PIN  D8    // Servo control pin

// Hardware Objects
MFRC522 rfid(SS_PIN, RST_PIN);
Servo lockServo;

// System Variables
String lastUID = "";
unsigned long lastScanTime = 0;
unsigned long responseTimeout = 0;
const unsigned long SCAN_DELAY = 2000;        // 2 seconds between scans
const unsigned long RESPONSE_TIMEOUT = 5000;  // 5 seconds to wait for Flutter
const unsigned long UNLOCK_DURATION = 3000;   // 3 seconds unlock time

// Servo Positions
const int LOCKED_POSITION = 0;      // 0 degrees = locked
const int UNLOCKED_POSITION = 90;   // 90 degrees = unlocked

// System States
enum State {
  READY,
  WAITING_RESPONSE,
  UNLOCKING,
  UNLOCKED,
  LOCKED
};

State currentState = READY;
bool isLockerUnlocked = false;

void setup() {
  // Initialize Serial (115200 baud for ESP8266)
  Serial.begin(115200);
  delay(1000);
  
  // Initialize SPI and RFID
  SPI.begin();
  rfid.PCD_Init();
  
  // Initialize Servo
  lockServo.attach(SERVO_PIN);
  lockServo.write(LOCKED_POSITION);  // Start locked
  delay(500);
  
  // Send ready message to Flutter
  Serial.println("SYSTEM_READY");
  Serial.println("ESP8266 RapidKL Smart Locker initialized");
  Serial.println("Waiting for RFID cards...");
}

void loop() {
  // Process incoming commands from Flutter
  processSerialCommands();
  
  // Main state machine
  switch (currentState) {
    case READY:
      checkForRFIDCard();
      break;
      
    case WAITING_RESPONSE:
      checkResponseTimeout();
      break;
      
    case UNLOCKING:
      executeUnlock();
      break;
      
    case UNLOCKED:
      checkUnlockTimeout();
      break;
  }
  
  delay(100);
}

void checkForRFIDCard() {
  // Check if new card is present and readable
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    return;
  }
  
  // Prevent rapid scans
  if (millis() - lastScanTime < SCAN_DELAY) {
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
    return;
  }
  
  // Read UID from card
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) uid += "0";
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  
  // Send UID to Flutter
  Serial.println("RFID_SCAN:" + uid);
  
  // Store for reference and set timeout
  lastUID = uid;
  lastScanTime = millis();
  responseTimeout = millis();
  currentState = WAITING_RESPONSE;
  
  // Clean up RFID
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
}

void processSerialCommands() {
  if (!Serial.available()) return;
  
  String command = Serial.readStringUntil('\n');
  command.trim();
  
  if (command == "ACCESS_GRANTED") {
    if (currentState == WAITING_RESPONSE) {
      currentState = UNLOCKING;
    }
  }
  else if (command == "ACCESS_DENIED") {
    if (currentState == WAITING_RESPONSE) {
      Serial.println("Access denied - locker remains in current state");
      currentState = READY;
    }
  }
  else if (command == "TOGGLE_LOCK") {
    // Toggle between lock and unlock
    if (isLockerUnlocked) {
      lockServo.write(LOCKED_POSITION);
      isLockerUnlocked = false;
      Serial.println("Manual lock executed - Locker LOCKED");
    } else {
      lockServo.write(UNLOCKED_POSITION);
      isLockerUnlocked = true;
      Serial.println("Manual unlock executed - Locker UNLOCKED");
    }
    currentState = READY;
  }
  else if (command == "STATUS") {
    sendStatus();
  }
  else if (command == "UNLOCK") {
    // Manual unlock command
    lockServo.write(UNLOCKED_POSITION);
    isLockerUnlocked = true;
    Serial.println("Manual unlock command received - Locker UNLOCKED");
    currentState = READY;
  }
  else if (command == "LOCK") {
    // Manual lock command
    lockServo.write(LOCKED_POSITION);
    isLockerUnlocked = false;
    Serial.println("Manual lock executed - Locker LOCKED");
    currentState = READY;
  }
  else if (command == "PING") {
    // Connectivity test
    Serial.println("PONG");
  }
}

void checkResponseTimeout() {
  if (millis() - responseTimeout > RESPONSE_TIMEOUT) {
    Serial.println("Timeout - no response from Flutter");
    currentState = READY;
  }
}

void executeUnlock() {
  if (!isLockerUnlocked) {
    Serial.println("ACCESS_GRANTED - Unlocking locker");
    
    // Unlock servo
    lockServo.write(UNLOCKED_POSITION);
    isLockerUnlocked = true;
    
    Serial.println("Locker is now UNLOCKED. Tap again to lock.");
    currentState = READY; // Go back to ready for next tap
  } else {
    Serial.println("Locker already unlocked. Tap again to lock.");
    currentState = READY;
  }
}

void checkUnlockTimeout() {
  // Remove auto-lock functionality for manual control
  // Locker stays in current state until next RFID tap
}

void sendStatus() {
  Serial.println("STATUS_REPORT:");
  Serial.println("Board: ESP8266");
  Serial.println("State: " + getStateString());
  Serial.println("Servo: " + String(lockServo.read()) + " degrees");
  Serial.println("Last UID: " + lastUID);
  Serial.println("Uptime: " + String(millis() / 1000) + " seconds");
  Serial.println("Free Heap: " + String(ESP.getFreeHeap()) + " bytes");
}

String getStateString() {
  switch (currentState) {
    case READY: return "Ready";
    case WAITING_RESPONSE: return "Waiting for response";
    case UNLOCKING: return "Unlocking";
    case UNLOCKED: return "Unlocked";
    default: return "Unknown";
  }
}

/*
 * ==================== ESP8266 WIRING GUIDE ====================
 * 
 * ESP8266 (NodeMCU) Pin Mapping:
 * D0 = GPIO16    D1 = GPIO5     D2 = GPIO4     D3 = GPIO0
 * D4 = GPIO2     D5 = GPIO14    D6 = GPIO12    D7 = GPIO13
 * D8 = GPIO15    D9 = GPIO3     D10 = GPIO1
 * 
 * RC522 RFID Module → ESP8266 (NodeMCU):
 * VCC  → 3.3V
 * RST  → D3 (GPIO0)
 * GND  → GND
 * MISO → D6 (GPIO12)
 * MOSI → D7 (GPIO13)
 * SCK  → D5 (GPIO14)
 * SDA  → D4 (GPIO2)
 * 
 * SG90 Servo Motor → ESP8266 (NodeMCU):
 * Red (VCC)    → 3.3V or VIN (if external power)
 * Brown (GND)  → GND
 * Orange (PWM) → D8 (GPIO15)
 * 
 * ⚠️ IMPORTANT NOTES:
 * - ESP8266 runs at 3.3V logic level
 * - RC522 should use 3.3V power
 * - Servo may need external 5V power for strong torque
 * - Serial baud rate is 115200 (ESP8266 standard)
 * 
 * Serial Communication Protocol:
 * ESP8266 → Flutter: RFID_SCAN:A1B2C3D4
 * Flutter → ESP8266: ACCESS_GRANTED or ACCESS_DENIED
 * 
 * Optional Commands:
 * Flutter → ESP8266: STATUS, UNLOCK, LOCK, PING
 * 
 * ==================== END OF CODE ====================
 */