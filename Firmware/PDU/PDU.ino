#include <Wire.h>

uint8_t pin;
bool value;
uint8_t  portStat = 0;
char welcome[] = "BS_PDU_MK2:0,15";

void setup() {
  
  delay(1000);
  
  Serial.begin(9600);
  Wire.begin();
  
  rawWriteMCP(0x20,0x2,0x00); // OLAT0
  rawWriteMCP(0x20,0x3,0x00); // OLAT1
  rawWriteMCP(0x20,0x4,0x00); // IPOL0
  rawWriteMCP(0x20,0x5,0x00); // IPOL1
  rawWriteMCP(0x20,0x6,0x00); // IODIR0
  rawWriteMCP(0x20,0x7,0x00); // IODIR1
//rawWriteMCP(0x20,0x8,0x00); // INTCAP0 READ ONLY
//rawWriteMCP(0x20,0x9,0x00); // INTCAP1 READ ONLY
  rawWriteMCP(0x20,0xA,0x01); // IOCON0
  rawWriteMCP(0x20,0xB,0x01); // IOCON1
  
  rawWriteMCP(0x20,0x0,0xFF); // GP0
  rawWriteMCP(0x20,0x1,0x01); // GP1

}
 
void loop() {
  while (Serial.available() > 0) {
    switch (Serial.read()) {
      case 'S':
        // look for the next valid integer in the incoming serial stream
        pin = Serial.parseInt();
        // do it again
        value = Serial.parseInt();

        // look for a newline.
        if (Serial.read() == '\n') {
          // constrain the values to 0 - 255 and invert
          // if you're using a common-cathode LED, just use "constrain(color, 0, 255);"
          pin = constrain(pin, 0, 255);
          value = constrain(value, 0, 1);

          Serial.println(digitalWriteMCP(pin,value));
        }
        break;
      case 'G':
        // look for the next valid integer in the incoming serial stream
        pin = Serial.parseInt();

        // look for a newline.
        if (Serial.read() == '\n') {
          // constrain the values to 0 - 255 and invert
          // if you're using a common-cathode LED, just use "constrain(color, 0, 255);"
          pin = constrain(pin, 0, 255);

          Serial.println(digitalReadMCP(pin));
        }
        break;
      case '?':
        Serial.println(welcome);
        break;
      default:
        // ignore all the other shit
        break;
    }
  }
}

uint8_t rawWriteMCP(uint8_t hwAddr, uint8_t regAddr, uint8_t valData) {
  
  while(Wire.available()){
    Wire.read();
  }
  Wire.beginTransmission(hwAddr); // select hardware address
  Wire.write(regAddr); // select register
  Wire.write(valData); // write values to register
  Wire.endTransmission(); // drop the connection
  
  return rawReadMCP(hwAddr,regAddr);

}

uint8_t rawReadMCP(uint8_t hwAddr, uint8_t regAddr) {

  while(Wire.available()){
    Wire.read();
  }
  Wire.beginTransmission(hwAddr);  // select our MCP
  Wire.write(regAddr); // Select IO port to read from
  Wire.requestFrom(hwAddr, 1, true); // Request 1 byte from the MCP (the IO port address mentioned before)
  uint8_t retVal = Wire.read(); // Dump the first byte recv'd in portStat
  Wire.endTransmission(); // Terminate communication
  
  return retVal;
  
}

boolean digitalReadMCP(uint8_t pinNo) {
  
  if ( pinNo > 127 || pinNo < 0 ) { return false; }
  
  uint8_t chipAddr = ( pinNo / 16 ) + 0x20 ;
  uint8_t ioAddr = (( pinNo % 16 ) / 8 );
  uint8_t bitNumber = (pinNo % 8);
  
  // this is a hack to make the chip latch the correct address in, as the instruction registers don't update for 35ms
  // This is technically incorrect and i know why now. But effort updating it until i get back to my desk.
  rawReadMCP(chipAddr,ioAddr);
  delay(35);
  
  portStat = rawReadMCP(chipAddr,ioAddr);

  portStat = bitRead(~portStat,bitNumber);
  
  return portStat;
}

boolean digitalWriteMCP(uint8_t pinNo, boolean IO) {
  
  if ( pinNo > 127 || pinNo < 0 ) { return false; }
  if ( IO != 1 && IO != 0 ) { return false; }

  IO = 1 - IO;
  
  uint8_t chipAddr = ( pinNo / 16 ) + 0x20 ;
  uint8_t ioAddr = (( pinNo % 16 ) / 8 );
  uint8_t bitNumber = (pinNo % 8);

  // this is a hack to make the chip latch the correct address in, as the instruction registers don't update for 35ms
  // This is technically incorrect and i know why now. But effort updating it until i get back to my desk.
  rawReadMCP(chipAddr,ioAddr);
  delay(35);
  
  portStat = rawReadMCP(chipAddr,ioAddr);
  
  switch (IO) {
    case 0:
      rawWriteMCP(chipAddr,ioAddr,portStat & ~(0x01 << bitNumber)); // Shifts 0x01 (Hex) B00000001 (Binary) to the left by bitNumber times, flips all the bits, then ANDs it with portStatus
      break;
      
    case 1:
      rawWriteMCP(chipAddr,ioAddr,portStat | (0x01 << bitNumber)); // Shifts 0x01 (Hex) B00000001 (Binary) to the left by bitNumber times, then ORs that with portStatus.
      break;
      
    default:
      return false;
      break;
  }
  
  return digitalReadMCP(pinNo);
}
