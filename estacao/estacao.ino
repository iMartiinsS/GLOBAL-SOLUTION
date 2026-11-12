/*
 * AlagAlerta - Estação de monitoramento de córrego (Arduino Uno)
 * Global Solution 2026/2 - CitizenTech - Disruptive Architectures: IoT
 *
 * O que faz:
 *  - Mede a distância até a água com o sensor ultrassônico HC-SR04 instalado embaixo de uma ponte
 *    e converte em NÍVEL DA ÁGUA (cm) = altura de instalação - distância.
 *  - Mede a CHUVA (mm/h). No protótipo um potenciômetro simula o pluviômetro; no campo seria um
 *    pluviômetro de báscula ligado na interrupção do pino 2 (código incluído, ver USAR_PLUVIOMETRO).
 *  - Classifica o risco com os mesmos limites da API: NORMAL, ATENCAO, ALERTA, EMERGENCIA.
 *  - Aciona alarme LOCAL (LEDs + buzzer + LCD) mesmo sem internet: a comunidade é avisada no ponto.
 *  - Envia a cada ciclo uma linha JSON pela serial para o gateway, que repassa à API AlagAlerta.
 *
 * Ligações (ver diagram.json):
 *   HC-SR04  TRIG -> D9   ECHO -> D10
 *   Potenciômetro (chuva) -> A0
 *   LED verde D4, amarelo D5, laranja D6, vermelho D7 (resistores de 220 ohms)
 *   Buzzer -> D8
 *   LCD 16x2 I2C (0x27) -> SDA A4, SCL A5
 */

#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// ---------------- Configuração da estação ----------------
const char*  CODIGO_SENSOR     = "SNS-PANT-01";  // mesmo código cadastrado na API
const float  ALTURA_SENSOR_CM  = 250.0;          // do leito do córrego até o sensor
const float  NIVEL_ALERTA_CM   = 120.0;
const float  NIVEL_CRITICO_CM  = 180.0;
const float  CHUVA_FORTE       = 30.0;           // mm/h
const float  CHUVA_MUITO_FORTE = 50.0;           // mm/h
const unsigned long INTERVALO_MS = 5000;         // 5 s no protótipo (no campo: 60 s)
const int    AMOSTRAS          = 5;              // média móvel para filtrar ondas/ruído

// #define USAR_PLUVIOMETRO  // descomente no campo para usar o pluviômetro de báscula
const float  MM_POR_BASCULADA  = 0.2794;

// ---------------- Pinos ----------------
const int PIN_TRIG = 9;
const int PIN_ECHO = 10;
const int PIN_CHUVA = A0;
const int PIN_PLUVIOMETRO = 2;
const int LED_VERDE = 4, LED_AMARELO = 5, LED_LARANJA = 6, LED_VERMELHO = 7;
const int PIN_BUZZER = 8;

LiquidCrystal_I2C lcd(0x27, 16, 2);

enum Risco { NORMAL, ATENCAO, ALERTA, EMERGENCIA };
const char* NOMES_RISCO[] = { "NORMAL", "ATENCAO", "ALERTA", "EMERGENCIA" };

float leituras[AMOSTRAS];
int indiceLeitura = 0;
bool bufferCheio = false;
float nivelAnterior = -1;
unsigned long ultimoEnvio = 0;
unsigned long sequencia = 0;
volatile unsigned long basculadas = 0;

void contarBasculada() { basculadas++; }

// ---------------- Medições ----------------
float medirDistanciaCm() {
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);
  unsigned long duracao = pulseIn(PIN_ECHO, HIGH, 30000UL);  // timeout ~5 m
  if (duracao == 0) return -1;                               // sem eco: leitura inválida
  return duracao * 0.0343 / 2.0;
}

float medirNivelAguaCm() {
  float distancia = medirDistanciaCm();
  if (distancia < 0) return -1;
  float nivel = ALTURA_SENSOR_CM - distancia;
  return constrain(nivel, 0, ALTURA_SENSOR_CM);
}

float mediaMovel(float valor) {
  leituras[indiceLeitura] = valor;
  indiceLeitura = (indiceLeitura + 1) % AMOSTRAS;
  if (indiceLeitura == 0) bufferCheio = true;
  int n = bufferCheio ? AMOSTRAS : indiceLeitura;
  float soma = 0;
  for (int i = 0; i < n; i++) soma += leituras[i];
  return soma / n;
}

float medirChuvaMmHora() {
#ifdef USAR_PLUVIOMETRO
  noInterrupts();
  unsigned long n = basculadas;
  basculadas = 0;
  interrupts();
  // basculadas no intervalo -> mm -> extrapola para 1 hora
  return n * MM_POR_BASCULADA * (3600000.0 / INTERVALO_MS);
#else
  return analogRead(PIN_CHUVA) * 100.0 / 1023.0;  // simulação: 0 a 100 mm/h
#endif
}

// ---------------- Regra de negócio (igual à API) ----------------
Risco classificar(float nivel, float chuva) {
  bool preAlerta = nivel >= NIVEL_ALERTA_CM * 0.7;
  if (nivel >= NIVEL_CRITICO_CM) return EMERGENCIA;
  if (nivel >= NIVEL_ALERTA_CM || (preAlerta && chuva >= CHUVA_MUITO_FORTE)) return ALERTA;
  if (preAlerta || chuva >= CHUVA_FORTE) return ATENCAO;
  return NORMAL;
}

// ---------------- Atuadores ----------------
void sinalizar(Risco risco) {
  digitalWrite(LED_VERDE,    risco == NORMAL);
  digitalWrite(LED_AMARELO,  risco == ATENCAO);
  digitalWrite(LED_LARANJA,  risco == ALERTA);
  digitalWrite(LED_VERMELHO, risco == EMERGENCIA);

  if (risco == EMERGENCIA) {
    tone(PIN_BUZZER, 2000, 800);   // sirene contínua a cada ciclo
  } else if (risco == ALERTA) {
    tone(PIN_BUZZER, 1200, 200);   // bipe curto
  } else {
    noTone(PIN_BUZZER);
  }
}

void mostrarLcd(float nivel, float chuva, float variacao, Risco risco) {
  lcd.setCursor(0, 0);
  lcd.print("Nivel ");
  lcd.print(nivel, 0);
  lcd.print("cm ");
  lcd.print(variacao >= 0 ? "+" : "");
  lcd.print(variacao, 0);
  lcd.print("   ");
  lcd.setCursor(0, 1);
  lcd.print(NOMES_RISCO[risco]);
  lcd.print(" ");
  lcd.print(chuva, 0);
  lcd.print("mm/h     ");
}

// ---------------- Comunicação com o gateway ----------------
void enviarJson(float nivel, float chuva, Risco risco, float variacao) {
  // Uma linha por leitura. O gateway envia nivelAguaCm/chuvaMmHora para POST /api/leituras.
  Serial.print("{\"codigoSensor\":\"");
  Serial.print(CODIGO_SENSOR);
  Serial.print("\",\"seq\":");
  Serial.print(sequencia++);
  Serial.print(",\"nivelAguaCm\":");
  Serial.print(nivel, 1);
  Serial.print(",\"chuvaMmHora\":");
  Serial.print(chuva, 1);
  Serial.print(",\"variacaoCm\":");
  Serial.print(variacao, 1);
  Serial.print(",\"riscoLocal\":\"");
  Serial.print(NOMES_RISCO[risco]);
  Serial.println("\"}");
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);
  pinMode(LED_VERDE, OUTPUT);
  pinMode(LED_AMARELO, OUTPUT);
  pinMode(LED_LARANJA, OUTPUT);
  pinMode(LED_VERMELHO, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
#ifdef USAR_PLUVIOMETRO
  pinMode(PIN_PLUVIOMETRO, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIN_PLUVIOMETRO), contarBasculada, FALLING);
#endif

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("AlagAlerta");
  lcd.setCursor(0, 1);
  lcd.print(CODIGO_SENSOR);

  // autoteste dos LEDs na inicialização
  for (int pino = LED_VERDE; pino <= LED_VERMELHO; pino++) {
    digitalWrite(pino, HIGH);
    delay(150);
    digitalWrite(pino, LOW);
  }
  Serial.println("# AlagAlerta estacao iniciada");
}

void loop() {
  unsigned long agora = millis();
  if (agora - ultimoEnvio < INTERVALO_MS && ultimoEnvio != 0) return;
  ultimoEnvio = agora;

  float bruto = medirNivelAguaCm();
  if (bruto < 0) {
    Serial.println("# erro: sensor ultrassonico sem eco");
    lcd.setCursor(0, 1);
    lcd.print("FALHA SENSOR    ");
    return;
  }

  float nivel = mediaMovel(bruto);
  float chuva = medirChuvaMmHora();
  float variacao = nivelAnterior < 0 ? 0 : nivel - nivelAnterior;
  nivelAnterior = nivel;

  Risco risco = classificar(nivel, chuva);
  sinalizar(risco);
  mostrarLcd(nivel, chuva, variacao, risco);
  enviarJson(nivel, chuva, risco, variacao);
}
