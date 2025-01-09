/*
 * Işık Yoğunluğu Ölçer - ESP8266 ve BH1750 Sensör Kodu
 * Bu kod ESP8266 ve BH1750 ışık sensörü kullanarak ışık yoğunluğunu ölçer
 * ve bir web sunucusu üzerinden JSON formatında veri sağlar.
 */

#include <Wire.h>              // I2C haberleşme kütüphanesi
#include <BH1750.h>           // BH1750 ışık sensörü kütüphanesi
#include <ESP8266WiFi.h>      // ESP8266 WiFi kütüphanesi
#include <ESP8266WebServer.h> // ESP8266 Web Sunucu kütüphanesi

// Sensör ve sunucu nesnelerinin oluşturulması
BH1750 lightMeter;
ESP8266WebServer server(80);  // 80 portu üzerinden web sunucusu

// WiFi bağlantı bilgileri
const char* ssid = "Emre";      // WiFi ağ adı
const char* password = "26052002";  // WiFi şifresi

void setup() {
  // Seri haberleşme başlatılıyor
  Serial.begin(115200);
  
  // I2C ve sensör başlatılıyor
  Wire.begin();
  lightMeter.begin();
  
  // WiFi bağlantısı başlatılıyor
  WiFi.begin(ssid, password);
  
  Serial.println("");
  Serial.print("WiFi'ya Bağlanıyor");
  // WiFi bağlantısı bekleniliyor
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  // Bağlantı başarılı olduğunda IP adresi yazdırılıyor
  Serial.println("");
  Serial.print("Bağlandı! IP adresi: ");
  Serial.println(WiFi.localIP());
  
  // /light endpoint'i için handler tanımlanıyor
  server.on("/light", HTTP_GET, []() {
    float lux = lightMeter.readLightLevel();  // Sensörden ışık değeri okunuyor
    String json = "{\"lux\":" + String(lux) + "}";  // JSON formatında yanıt hazırlanıyor
    server.send(200, "application/json", json);  // Yanıt gönderiliyor
  });
  
  // Web sunucusu başlatılıyor
  server.begin();
}

void loop() {
  // Gelen istekleri işle
  server.handleClient();
}