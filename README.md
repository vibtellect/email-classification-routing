# KI-E-Mail-Klassifikation & Routing

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![n8n](https://img.shields.io/badge/n8n-1.76+-blue)](https://n8n.io)
[![AWS Bedrock](https://img.shields.io/badge/AWS-Bedrock-FF9900)](https://aws.amazon.com/bedrock/)
[![Docker](https://img.shields.io/badge/Docker-ready-blue)](https://www.docker.com/)
[![German](https://img.shields.io/badge/Language-German-black)](README.md)

Intelligente E-Mail-Klassifikation und Routing mit AWS Bedrock und n8n. Automatisiert Eingangs-Triage für Mittelstandsunternehmen.

---

## Pipeline-Übersicht

```
┌─────────────────┐
│  E-Mail-Input   │
│   (Webhook)     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│  AWS Bedrock Klassifikation     │
│  (Claude 3.5 Sonnet / Nova)     │
│                                 │
│  • Kategorie-Erkennung          │
│  • Prioritäts-Bewertung         │
│  • Sentiment-Analyse            │
│  • Zusammenfassung              │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Kategorisierung & Routing      │
│                                 │
│  anfrage → Vertrieb             │
│  beschwerde → Support           │
│  bewerbung → HR                 │
│  rechnung → Buchhaltung         │
│  spam → Papierkorb              │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────┐
│  JSON-Response   │
│  mit Route       │
└──────────────────┘
```

---

## Kategorien & Routing

| Kategorie | Abteilung | Priorität | Beispiel |
|-----------|-----------|-----------|----------|
| **anfrage** | Vertrieb | hoch/mittel/niedrig | "Angebot für KI-Lösung" |
| **beschwerde** | Support | hoch/mittel | "Systemausfall seit heute" |
| **bewerbung** | HR | mittel/niedrig | "Bewerbung als Dev-Lead" |
| **rechnung** | Buchhaltung | mittel | "Rechnung #2026-045" |
| **spam** | Papierkorb | niedrig | Newsletter, Werbung |

---

## Prioritäts-Level

- **hoch**: Beschwerden, System-Ausfälle, Mahnungen, dringende Anfragen
- **mittel**: Standard-Anfragen, normale Beschwerden, Bewerbungen
- **niedrig**: Info-Anfragen, Newsletter, nicht-dringend

---

## Schnellstart

### Voraussetzungen

- Docker & Docker Compose (mindestens v2.0)
- AWS Account mit Bedrock-Zugriff auf Claude-Modelle
- GNU Make (optional, für Makefile)
- curl (für Test-Requests)

### 1. Setup

```bash
make setup
```

Dies erstellt `.env` aus `.env.example`. Jetzt die AWS-Credentials eintragen:

```bash
nano .env
```

```env
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=eu-central-1
```

### 2. Container starten

```bash
make up
```

n8n ist nun erreichbar unter `http://localhost:5678`.

### 3. Smoke-Test

```bash
make smoke
```

Erwartet: "n8n UI erreichbar auf :5678"

### 4. Workflow importieren

1. Browser: `http://localhost:5678`
2. Menu: **Workflows** → **Import from File**
3. Datei wählen: `workflows/email-classification.json`
4. AWS-Credentials im Bedrock-Node eintragen
5. **Activate** klicken

### 5. Demo testen

Siehe Sektion [Demo](#demo).

### 6. Herunterfahren

```bash
make down
```

---

## Demo

### Test-Request mit curl

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "kunde@example.de",
    "subject": "Rechnung Februar 2026",
    "body": "Anbei die Rechnung für Februar. Bitte begleichen Sie diese innerhalb von 14 Tagen."
  }'
```

### Erwartete JSON-Antwort

```json
{
  "success": true,
  "classification": {
    "kategorie": "rechnung",
    "prioritaet": "mittel",
    "zusammenfassung": "Rechnung für Februar mit 14-Tage Zahlungsfrist.",
    "empfohlene_abteilung": "Buchhaltung",
    "dringend": false
  },
  "route": "buchhaltung"
}
```

### Test-E-Mails (11 Beispiele)

Die Demo-Emails decken alle Kategorien ab:

| Datei | Kategorie | Routing |
|-------|-----------|---------|
| `anfrage-klein.txt` | anfrage | vertrieb |
| `anfrage-enterprise.txt` | anfrage | vertrieb |
| `beschwerde.txt` | beschwerde | support |
| `beschwerde-lieferung.txt` | beschwerde | support |
| `support-technisch.txt` | beschwerde | support |
| `bewerbung.txt` | bewerbung | hr |
| `bewerbung-initiativ.txt` | bewerbung | hr |
| `rechnung.txt` | rechnung | buchhaltung |
| `rechnung-saas.txt` | rechnung | buchhaltung |
| `spam-newsletter.txt` | spam | papierkorb |
| `partnerschaft-anfrage.txt` | anfrage | vertrieb |

**Schnelltest:** Siehe [test-emails/README.md](./test-emails/README.md) für curl-Befehle pro E-Mail.

---

## API-Endpoint

### POST `/webhook/email-classification`

**Request-Body:**

```json
{
  "from": "sender@example.de",
  "subject": "Betreff der E-Mail",
  "body": "Inhalt der E-Mail..."
}
```

**Response (200):**

```json
{
  "success": true,
  "classification": {
    "kategorie": "anfrage|beschwerde|bewerbung|rechnung|spam",
    "prioritaet": "hoch|mittel|niedrig",
    "zusammenfassung": "2-3 Sätze Deutsch",
    "empfohlene_abteilung": "Vertrieb|Support|HR|Buchhaltung|Papierkorb",
    "dringend": boolean
  },
  "route": "vertrieb|support|hr|buchhaltung|papierkorb|manuell-pruefen"
}
```

**Fehler (400, 500):**

```json
{
  "success": false,
  "error": "Beschreibung des Fehlers"
}
```

---

## Projektstruktur

```
.
├── Makefile                          # make setup, up, down, smoke, logs, import
├── docker-compose.yml                # n8n + volumes
├── .env.example                      # AWS-Template
├── .gitignore                        # Git-Ausschlüsse
├── LICENSE                           # MIT (2026 Bojatschkin LTD.)
├── README.md                         # Diese Datei (Deutsch)
├── workflows/
│   └── email-classification.json     # n8n Workflow (Bedrock + Routing)
├── prompts/
│   └── email-classifier.txt          # System-Prompt für Bedrock
├── test-emails/
│   ├── README.md                     # Test-Dokumentation
│   ├── anfrage-klein.txt
│   ├── anfrage-enterprise.txt
│   ├── beschwerde.txt
│   ├── beschwerde-lieferung.txt
│   ├── bewerbung.txt
│   ├── bewerbung-initiativ.txt
│   ├── rechnung.txt
│   ├── rechnung-saas.txt
│   ├── spam-newsletter.txt
│   ├── support-technisch.txt
│   └── partnerschaft-anfrage.txt
├── iam/
│   └── n8n-automation-policy.json    # AWS IAM Policy für n8n-User
└── .github/
    └── workflows/
        └── ci.yml                    # GitHub Actions (optional)
```

---

## Tech-Stack

| Komponente | Version | Zweck |
|-----------|---------|-------|
| **n8n** | 1.76+ | Workflow-Automation Engine |
| **AWS Bedrock** | Latest | KI-Klassifikation (Claude 3.5 Sonnet / Nova Micro) |
| **Docker Compose** | v2.0+ | Container-Orchestrierung |
| **Node.js** | 20+ | n8n Runtime |

---

## AWS IAM-Permissions

Für den n8n-Service-User braucht es diese Permissions (siehe `iam/n8n-automation-policy.json`):

```json
{
  "Effect": "Allow",
  "Action": [
    "bedrock:InvokeModel",
    "bedrock:InvokeModelWithResponseStream",
    "bedrock:ListFoundationModels"
  ],
  "Resource": "*"
}
```

**Einrichtung:**

1. AWS Console: **IAM** → **Users** → **Create User**
2. Name: `n8n-automation` (oder ähnlich)
3. **Create access key** (access key type)
4. Policy: JSON-Inhalt aus `iam/n8n-automation-policy.json` einfügen
5. Access Key ID + Secret Key in `.env` eintragen

---

## Workflow-Details

Der n8n-Workflow (`workflows/email-classification.json`) besteht aus 6 Nodes:

1. **Webhook Trigger** — Empfängt POST-Request auf `/webhook/email-classification`
2. **Normalize Input** — Validiert und normalisiert from/subject/body
3. **Basic LLM Chain** — Bedrock-Prompt mit E-Mail-Inhalt
4. **AWS Bedrock Chat Model** — Bedrock-Integration (Claude-Modelle)
5. **Parse und Route** — JSON-Antwort parsen, Routing-Regel applizieren
6. **Respond to Webhook** — JSON-Response an Client zurückgeben

**Routing-Logik:**
- `anfrage` → `vertrieb`
- `beschwerde` → `support`
- `bewerbung` → `hr`
- `rechnung` → `buchhaltung`
- `spam` → `papierkorb`
- Unbekannt → `manuell-pruefen`

---

## Makefile-Targets

```bash
make setup      # .env aus .env.example erstellen
make up         # Docker Container starten (docker compose up -d)
make down       # Docker Container stoppen
make logs       # Live-Logs folgen (docker compose logs -f)
make smoke      # Health-Check: n8n UI erreichbar?
make import     # Workflow aus JSON importieren (curl to API)
```

---

## Umgebungsvariablen

`.env.example` als Template:

```bash
# AWS Bedrock Credentials (erforderlich)
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_REGION=eu-central-1

# IMAP Zugangsdaten (optional, für Live-Integration)
IMAP_HOST=imap.gmail.com
IMAP_PORT=993
IMAP_USER=dein-test-email@gmail.com
IMAP_PASS=xxxx-xxxx-xxxx-xxxx

# Slack Integration (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXX
SLACK_CHANNEL_VERTRIEB=#vertrieb
SLACK_CHANNEL_SUPPORT=#support
SLACK_CHANNEL_HR=#hr
SLACK_CHANNEL_BUCHHALTUNG=#buchhaltung
```

---

## Kosten (Schätzung)

**AWS Bedrock** — Pro API-Call:

- **Claude 3.5 Sonnet**: ~0,01-0,05 EUR pro E-Mail (abhängig von Länge)
- **Claude 3.5 Haiku**: ~0,001-0,005 EUR pro E-Mail (schneller, günstiger)
- **Nova Micro**: ~0,0005-0,002 EUR pro E-Mail (optimal für Classification)

**Beispiel**: 1.000 E-Mails/Monat ≈ 1-10 EUR mit Nova Micro.

---

## Fehlerbehandlung

### "Bedrock-Antwort konnte nicht als JSON geparst werden"

- **Ursache:** Bedrock gibt ungültiges JSON zurück
- **Lösung:** System-Prompt (prompts/email-classifier.txt) auf Genauigkeit prüfen, Bedrock-Modell testen

### "AWS_ACCESS_KEY_ID nicht gesetzt"

- **Ursache:** `.env` nicht konfiguriert
- **Lösung:** `make setup` laufen lassen, `.env` mit Credentials füllen

### n8n UI antwortet nicht

- **Ursache:** Container nicht gestartet oder Port 5678 belegt
- **Lösung:** `make down && make up` neu starten, `netstat -tuln | grep 5678` prüfen

---

## Sicherheit

- **AWS Credentials:** Niemals in Git committen — `.env` steht in `.gitignore`
- **IAM Policy:** Least-Privilege — nur Bedrock + S3/CloudFormation/etc. (siehe `iam/`)
- **Webhook:** Keine Auth in diesem PoC — für Production: API-Key / OAuth2 ergänzen
- **DSGVO:** E-Mail-Daten gehen an AWS Bedrock — Datenschutzerklärung anpassen

---

## Grenzen des PoC

- ✗ Routing ist regelbasiert (statisch)
- ✗ Kein echtes Ticketing/CRM angebunden
- ✗ IMAP-Polling muss für Production gehärtet werden
- ✗ Keine Rate-Limiting oder Authentifizierung
- ✗ Keine Logging/Audit-Trail in DB
- ✓ Aber: Klare Architektur, leicht erweiterbar

---

## Erweiterungen (Next Steps)

1. **Kategorien kalibrieren** — Mit echten historischen E-Mails trainieren
2. **Slack/Teams Integration** — Automatisches Routing zu Channels
3. **CRM/Ticketing** — Direct Integration (HubSpot, Freshdesk, etc.)
4. **Sentiment-Tracking** — Kundenzufriedenheits-Metriken
5. **SLA-Metriken** — Response-Zeit pro Kategorie monitoren
6. **Multi-Tenant** — Mehrere Unternehmen unterstützen
7. **Fine-Tuning** — Custom Bedrock Model trainieren

---

## Support & Blog

Wenn du aus diesem PoC eine belastbare Service-Inbox-Automatisierung machen willst, erstelle ich dir die Zielarchitektur inkl. Rollout-Plan.

**Kontakt:** [https://bojatschkin.de](https://bojatschkin.de)

**Blog-Post (mit Schritt-für-Schritt Anleitung):**
[E-Mails mit KI klassifizieren](https://bojatschkin.de/blog/email-ki-klassifikation?utm_source=github&utm_medium=readme&utm_campaign=email-klassifikation-demo)

---

## Disclaimer

Dieses Projekt wird "as-is" bereitgestellt. Es ist ein PoC (Proof of Concept) für interne Demonstrations-Zwecke.

**Vor Production-Einsatz:**
- Vollständiger Security-Review
- Compliance-Check (DSGVO, Audit-Trail)
- Load-Testing & Capacity-Planning
- Fehlerbehandlung & Monitoring
- Backup-Strategie
- Disaster-Recovery-Plan

---

## Lizenz

MIT License — Copyright 2026 Vitalij Bojatschkin / BOJATSCHKIN LTD.

Siehe [LICENSE](./LICENSE) für Details.

---

## Contributing

Contributions sind willkommen! Siehe [CONTRIBUTING.md](./CONTRIBUTING.md).

---

*Projekt: KI-Email-Classification-Routing | GitHub: vibtellect/email-classification-routing*
