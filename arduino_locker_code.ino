/*
 * RapidKL Smart Locker System - Arduino Code
 * Hardware: Arduino Mega 2560 + RC522 RFID + SG90 Servo
 * Communication: USB Serial with Flutter App
 */

#include <SPI.h>
#include <MFRC522.h>
#include <Servo.h>

// Pin Definitions
#define RST_PIN         5    // RC522 Reset pin
#define SS_PIN          53   // RC522 SDA pin
#define SERVO_PIN       9    // Servo control pin
#define LED_READY       2    // Green LED - System ready
#define LED_SCANNING    3    // Blue LED - Card detected
#define LED_GRANTED     4    // Green LED - Access granted
#define LED_DENIED      7    // Red LED - Access denied
#define BUZZER_PIN      8    // Buzzer for audio feedback
#define TAMPER_PIN      6    // Tamper detection switch

// Hardware Objects
MFRC522 rfid(SS_PIN, RST_PIN);
Servo lockServo;

// System Variables
String lastUID = "";
unsigned long lastScanTime = 0;
const unsigned long SCAN_DELAY = 2000; // 2 second delay between scans
bool systemReady = false;
int servoLockedPosition = 0;    // Locked position
int servoUnlockedPosition = 90; // Unlocked position

// System States
enum SystemState {
  INITIALIZING,
  READY,
  SCANNING,
  PROCESSING,
  ACCESS_GRANTED,
  ACCESS_DENIED,
  ERROR
};

SystemState currentState = INITIALIZING;

void setup() {
  // Initialize Serial Communication
  Serial.begin(9600);
  while (!Serial) delay(10);
  
  // Initialize SPI and RFID
  SPI.begin();
  rfid.PCD_Init();
  
  // Initialize Servo
  lockServo.attach(SERVO_PIN);
  lockServo.write(servoLockedPosition); // Start in locked position
  
  // Initialize GPIO pins
  pinMode(LED_READY, OUTPUT);
  pinMode(LED_SCANNING, OUTPUT);
  pinMode(LED_GRANTED, OUTPUT);
  pinMode(LED_DENIED, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(TAMPER_PIN, INPUT_PULLUP);
  
  // System startup sequence
  systemStartup();
  
  Serial.println("RapidKL Smart Locker System Initialized");
  Serial.println("Waiting for RFID cards...");
  
  currentState = READY;
  systemReady = true;
}

void loop() {
  // Check for tamper detection
  if (digitalRead(TAMPER_PIN) == LOW) {
    handleTamperAlert();
    return;
  }
  
  // Main system logic based on current state
  switch (currentState) {
    case READY:
      updateStatusLEDs();
      checkForRFIDCard();
      break;
      
    case SCANNING:
      processRFIDCard();
      break;
      
    case PROCESSING:
      waitForFlutterResponse();
      break;
      
    case ACCESS_GRANTED:
      grantAccess();
      break;
      
    case ACCESS_DENIED:
      denyAccess();
      break;
      
    case ERROR:
      handleError();
      break;
  }
  
  // Process any incoming serial commands
  processSerialCommands();
  
  delay(100); // Small delay for stability
}

void systemStartup() {
  // LED startup sequence
  digitalWrite(LED_READY, HIGH);
  delay(200);
  digitalWrite(LED_SCANNING, HIGH);
  delay(200);
  digitalWrite(LED_GRANTED, HIGH);
  delay(200);
  digitalWrite(LED_DENIED, HIGH);
  delay(200);
  
  // Turn off all LEDs
  digitalWrite(LED_READY, LOW);
  digitalWrite(LED_SCANNING, LOW);
  digitalWrite(LED_GRANTED, LOW);
  digitalWrite(LED_DENIED, LOW);
  
  // Startup beep
  playBeep(2, 100);
  
  // Test servo movement
  lockServo.write(servoUnlockedPosition);
  delay(500);
  lockServo.write(servoLockedPosition);
  delay(500);
}

void checkForRFIDCard() {
  // Check if a new card is present
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    return;
  }
  
  // Prevent rapid successive scans
  if (millis() - lastScanTime < SCAN_DELAY) {
    return;
  }
  
  currentState = SCANNING;
  digitalWrite(LED_SCANNING, HIGH);
  playBeep(1, 50);
}

void processRFIDCard() {
  // Read UID from card
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uid += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  
  // Send UID to Flutter app
  Serial.println("RFID_SCAN:" + uid);
  
  lastUID = uid;
  lastScanTime = millis();
  currentState = PROCESSING;
  
  // Halt PICC and stop encryption
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
  
  Serial.println("UID sent to Flutter: " + uid);
}

void waitForFlutterResponse() {
  // Wait for response from Flutter app (with timeout)
  static unsigned long processingStartTime = 0;
  if (processingStartTime == 0) {
    processingStartTime = millis();
  }
  
  // Timeout after 5 seconds
  if (millis() - processingStartTime > 5000) {
    Serial.println("Timeout waiting for Flutter response");
    currentState = ERROR;
    processingStartTime = 0;
  }
}

void grantAccess() {
  Serial.println("Access Granted - Unlocking locker");
  
  // Visual feedback
  digitalWrite(LED_SCANNING, LOW);
  digitalWrite(LED_GRANTED, HIGH);
  
  // Audio feedback
  playBeep(2, 200);
  
  // Unlock the locker
  lockServo.write(servoUnlockedPosition);
  
  // Keep unlocked for 5 seconds
  delay(5000);
  
  // Lock again
  lockServo.write(servoLockedPosition);
  digitalWrite(LED_GRANTED, LOW);
  
  Serial.println("Locker locked again");
  currentState = READY;
}

void denyAccess() {
  Serial.println("Access Denied");
  
  // Visual feedback
  digitalWrite(LED_SCANNING, LOW);
  digitalWrite(LED_DENIED, HIGH);
  
  // Audio feedback
  playBeep(3, 100);
  
  // Keep denied LED on for 2 seconds
  delay(2000);
  digitalWrite(LED_DENIED, LOW);
  
  currentState = READY;
}

void handleError() {
  Serial.println("System Error - Resetting");
  
  // Flash error LED
  for (int i = 0; i < 5; i++) {
    digitalWrite(LED_DENIED, HIGH);
    delay(200);
    digitalWrite(LED_DENIED, LOW);
    delay(200);
  }
  
  currentState = READY;
}

void handleTamperAlert() {
  Serial.println("TAMPER_ALERT:Locker tamper detected");
  
  // Flash all LEDs and sound alarm
  for (int i = 0; i < 10; i++) {
    digitalWrite(LED_DENIED, HIGH);
    digitalWrite(LED_GRANTED, HIGH);
    playBeep(1, 100);
    delay(100);
    digitalWrite(LED_DENIED, LOW);
    digitalWrite(LED_GRANTED, LOW);
    delay(100);
  }
}

void processSerialCommands() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.startsWith("ACCESS_GRANTED")) {
      currentState = ACCESS_GRANTED;
    }
    else if (command.startsWith("ACCESS_DENIED")) {
      currentState = ACCESS_DENIED;
    }
    else if (command.startsWith("UNLOCK_MANUAL")) {
      // Manual unlock command from Flutter
      lockServo.write(servoUnlockedPosition);
      Serial.println("Manual unlock executed");
    }
    else if (command.startsWith("LOCK_MANUAL")) {
      // Manual lock command from Flutter
      lockServo.write(servoLockedPosition);
      Serial.println("Manual lock executed");
    }
    else if (command.startsWith("STATUS_REQUEST")) {
      // Send system status to Flutter
      sendSystemStatus();
    }
    else if (command.startsWith("RESET_SYSTEM")) {
      // Reset system
      currentState = READY;
      Serial.println("System reset completed");
    }
  }
}

void updateStatusLEDs() {
  // Ready state - slow breathing effect on ready LED
  static unsigned long lastBreathe = 0;
  static bool breatheState = false;
  
  if (millis() - lastBreathe > 1000) {
    digitalWrite(LED_READY, breatheState ? HIGH : LOW);
    breatheState = !breatheState;
    lastBreathe = millis();
  }
}

void playBeep(int count, int duration) {
  for (int i = 0; i < count; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(duration);
    digitalWrite(BUZZER_PIN, LOW);
    if (i < count - 1) delay(duration);
  }
}

void sendSystemStatus() {
  // Send comprehensive system status to Flutter
  Serial.println("STATUS_REPORT:{");
  Serial.println("  \"system_ready\": " + String(systemReady ? "true" : "false") + ",");
  Serial.println("  \"current_state\": \"" + getStateString(currentState) + "\",");
  Serial.println("  \"servo_position\": " + String(lockServo.read()) + ",");
  Serial.println("  \"last_uid\": \"" + lastUID + "\",");
  Serial.println("  \"uptime\": " + String(millis()) + ",");
  Serial.println("  \"tamper_status\": \"" + String(digitalRead(TAMPER_PIN) == HIGH ? "normal" : "alert") + "\"");
  Serial.println("}");
}

String getStateString(SystemState state) {
  switch (state) {
    case INITIALIZING: return "initializing";
    case READY: return "ready";
    case SCANNING: return "scanning";
    case PROCESSING: return "processing";
    case ACCESS_GRANTED: return "access_granted";
    case ACCESS_DENIED: return "access_denied";
    case ERROR: return "error";
    default: return "unknown";
  }
}

// Diagnostic function for testing
void runDiagnostics() {
  Serial.println("Running system diagnostics...");
  
  // Test LEDs
  Serial.println("Testing LEDs...");
  digitalWrite(LED_READY, HIGH);
  delay(500);
  digitalWrite(LED_SCANNING, HIGH);
  delay(500);
  digitalWrite(LED_GRANTED, HIGH);
  delay(500);
  digitalWrite(LED_DENIED, HIGH);
  delay(500);
  
  // Turn off all LEDs
  digitalWrite(LED_READY, LOW);
  digitalWrite(LED_SCANNING, LOW);
  digitalWrite(LED_GRANTED, LOW);
  digitalWrite(LED_DENIED, LOW);
  
  // Test servo
  Serial.println("Testing servo...");
  lockServo.write(servoUnlockedPosition);
  delay(1000);
  lockServo.write(servoLockedPosition);
  delay(1000);
  
  // Test buzzer
  Serial.println("Testing buzzer...");
  playBeep(3, 200);
  
  Serial.println("Diagnostics completed");
}