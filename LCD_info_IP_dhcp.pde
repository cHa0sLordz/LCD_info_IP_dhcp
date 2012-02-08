// Modded for use the Arduino with the W204B-NLW LCD by C-L|cHa0s
// visit www.chaos-lordz.net for more stuff!
// ... and check www.gkaindl.com for some infos about the Ethernet DHCP Library

#include <Ethernet.h>
#include <EthernetDHCP.h>
#include <LiquidCrystal.h>

byte mac[] = { 
  0x77, 0x77, 0x77, 0x77, 0x77, 0x77 };

const char* ip_to_str(const uint8_t*);
LiquidCrystal lcd(8, 7, 6, 5, 4, 3, 2);
int EthernetResetPin = 9;


void setup()
{
  Serial.begin(9600);
  lcd.begin(4,20);              // rows, columns.  use 2,16 for a 2x16 LCD, etc.
  lcd.clear();                  // start with a blank screen
  lcd.setCursor(0,0);           // set cursor to column 0, row 0 (the first row)
  pinMode(EthernetResetPin, OUTPUT);  
  digitalWrite(EthernetResetPin, LOW);  
  digitalWrite(EthernetResetPin, HIGH);

  // Initiate a DHCP session. The argument is the MAC (hardware) address that
  // you want your Ethernet shield to use. The second argument enables polling
  // mode, which means that this call will not block like in the
  // SynchronousDHCP example, but will return immediately.
  // Within your loop(), you can then poll the DHCP library for its status,
  // finding out its state, so that you can tell when a lease has been
  // obtained. You can even find out when the library is in the process of
  // renewing your lease.
  EthernetDHCP.begin(mac, 1);
}

void loop()
{
  static DhcpState prevState = DhcpStateNone;
  static unsigned long prevTime = 0;

  // poll() queries the DHCP library for its current state (all possible values
  // are shown in the switch statement below). This way, you can find out if a
  // lease has been obtained or is in the process of being renewed, without
  // blocking your sketch. Therefore, you could display an error message or
  // something if a lease cannot be obtained within reasonable time.
  // Also, poll() will actually run the DHCP module, just like maintain(), so
  // you should call either of these two methods at least once within your
  // loop() section, or you risk losing your DHCP lease when it expires!
  DhcpState state = EthernetDHCP.poll();

  if (prevState != state) {
    Serial.println();  

    switch (state) {
    case DhcpStateDiscovering:
      Serial.print("Discovering servers.");
      lcd.print("Discovering servers.");
      break;
    case DhcpStateRequesting:
      Serial.print("Requesting lease.");
      lcd.print("Requesting lease.");
      break;
    case DhcpStateRenewing:
      Serial.print("Renewing lease.");
      lcd.print("Renewing lease.");
      break;
    case DhcpStateLeased: 
      {
        Serial.println("Obtained lease!");
        lcd.print("Obtained lease!");
        lcd.clear();
        // Since we're here, it means that we now have a DHCP lease, so we
        // print out some information.
        const byte* ipAddr = EthernetDHCP.ipAddress();
        const byte* gatewayAddr = EthernetDHCP.gatewayIpAddress();
        const byte* dnsAddr = EthernetDHCP.dnsIpAddress();

        Serial.print("My IP address is ");
        lcd.setCursor(0,0);
        lcd.print("TheGeek's IP Info :");

        lcd.setCursor(0,1);
        Serial.println(ip_to_str(ipAddr));
        lcd.print(ip_to_str(ipAddr));
        lcd.setCursor(14,1); 
        lcd.print("- IP");

        Serial.print("Gateway IP address is ");
        //lcd.print("Gateway IP address is ");

        Serial.println(ip_to_str(gatewayAddr));

        lcd.setCursor(0,2);
        lcd.print(ip_to_str(gatewayAddr));
        lcd.setCursor(14,2); 
        lcd.print("- Gate");
        Serial.print("DNS IP address is ");
        //lcd.print("DNS IP address is");
        Serial.println(ip_to_str(dnsAddr));

        lcd.setCursor(0,3);        
        lcd.print(ip_to_str(dnsAddr));
        lcd.setCursor(14,3); 
        lcd.print("- DNS");
        Serial.println();

        break;
      }
    }
  } 
  else if (state != DhcpStateLeased && millis() - prevTime > 300) {
    prevTime = millis();
    Serial.print('.'); 
  }

  prevState = state;
}

// Just a utility function to nicely format an IP address.
const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}




