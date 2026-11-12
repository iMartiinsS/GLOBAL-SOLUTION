#!/usr/bin/env node
/**
 * AlagAlerta - Gateway IoT (protótipo)
 *
 * Papel na arquitetura: recebe as linhas JSON das estações (serial/LoRa), autentica na API
 * com JWT e faz POST /api/leituras. Se a internet cair, guarda as leituras em fila
 * (store-and-forward) e reenvia quando a conexão voltar, preservando o horário da medição.
 *
 * Uso:
 *   # lê linhas JSON da entrada padrão (ex.: monitor serial redirecionado ou arquivo)
 *   node gateway.mjs < leituras.jsonl
 *   # gera um cenário de enchente simulado (sem hardware)
 *   node gateway.mjs --simular
 *
 * Variáveis de ambiente:
 *   API_URL          (padrão http://localhost:8080)
 *   GATEWAY_EMAIL    (padrão gateway@alagalerta.com — usuário de teste com papel AGENTE)
 *   GATEWAY_SENHA    (obrigatória; no ambiente de demonstração é a senha de teste do README da API)
 */
import readline from 'node:readline';

const API_URL = process.env.API_URL ?? 'http://localhost:8080';
const EMAIL = process.env.GATEWAY_EMAIL ?? 'gateway@alagalerta.com';
const SENHA = process.env.GATEWAY_SENHA;
const SIMULAR = process.argv.includes('--simular');

if (!SENHA) {
  console.error('Defina GATEWAY_SENHA com a senha do usuário do gateway.');
  process.exit(1);
}

let token = null;
const fila = []; // leituras aguardando envio

function agoraLocalIso() {
  // LocalDateTime sem fuso, como a API espera (horário de quem mediu)
  const d = new Date();
  const off = d.getTimezoneOffset() * 60000;
  return new Date(d.getTime() - off).toISOString().slice(0, 19);
}

async function autenticar() {
  const resp = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: EMAIL, senha: SENHA }),
  });
  if (!resp.ok) throw new Error(`login falhou: HTTP ${resp.status}`);
  token = (await resp.json()).token;
  console.log(`[gateway] autenticado como ${EMAIL}`);
}

async function enviar(leitura) {
  if (!token) await autenticar();
  const corpo = {
    codigoSensor: leitura.codigoSensor,
    nivelAguaCm: leitura.nivelAguaCm,
    chuvaMmHora: leitura.chuvaMmHora,
    dataHora: leitura.dataHora,
  };
  let resp = await fetch(`${API_URL}/api/leituras`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify(corpo),
  });
  if (resp.status === 401) { // token expirado: renova e tenta de novo
    await autenticar();
    resp = await fetch(`${API_URL}/api/leituras`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify(corpo),
    });
  }
  const json = await resp.json().catch(() => ({}));
  if (resp.status >= 500) throw new Error(`API indisponível (HTTP ${resp.status})`);
  if (!resp.ok) {
    // erro de dados (400/404/422): não adianta reenviar, descarta e registra
    console.warn(`[gateway] leitura recusada (HTTP ${resp.status}): ${json.mensagem ?? ''}`);
    return;
  }
  const alerta = json.alertaGeradoId ? ` -> ALERTA #${json.alertaGeradoId}` : '';
  console.log(`[gateway] ${corpo.codigoSensor} ${corpo.nivelAguaCm} cm / ${corpo.chuvaMmHora} mm/h `
    + `=> ${json.nivelRisco}${alerta}`);
}

let enviando = false;

async function processarFila() {
  if (enviando) return; // um envio por vez, na ordem em que as leituras chegaram
  enviando = true;
  try {
    while (fila.length > 0) {
      try {
        await enviar(fila[0]);
        fila.shift();
      } catch (e) {
        console.warn(`[gateway] sem conexão (${e.message}). ${fila.length} leitura(s) na fila; nova tentativa em 10 s`);
        setTimeout(processarFila, 10_000);
        return;
      }
    }
  } finally {
    enviando = false;
  }
}

function receberLinha(linha) {
  const texto = linha.trim();
  if (!texto || texto.startsWith('#')) return; // comentários/diagnóstico da estação
  try {
    const leitura = JSON.parse(texto);
    if (typeof leitura.nivelAguaCm !== 'number' || !leitura.codigoSensor) throw new Error('campos ausentes');
    leitura.dataHora ??= agoraLocalIso();
    fila.push(leitura);
    processarFila();
  } catch (e) {
    console.warn(`[gateway] linha ignorada (${e.message}): ${texto}`);
  }
}

async function simular() {
  // Córrego Três Pontes subindo durante um temporal: normal -> atenção -> alerta -> emergência
  const cenario = [
    [60, 5], [78, 18], [95, 34], [112, 41], [128, 47], [150, 55], [172, 62], [185, 64],
  ];
  for (const [nivel, chuva] of cenario) {
    receberLinha(JSON.stringify({ codigoSensor: 'SNS-PANT-01', nivelAguaCm: nivel, chuvaMmHora: chuva }));
    await new Promise((r) => setTimeout(r, 400));
  }
}

if (SIMULAR) {
  await simular();
} else {
  readline.createInterface({ input: process.stdin }).on('line', receberLinha);
}
