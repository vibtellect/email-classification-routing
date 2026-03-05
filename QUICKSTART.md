# Quick Start (3 Minuten)

## 1. Setup (2 Min)

```bash
git clone https://github.com/vibtellect/email-classification-routing.git
cd email-classification-routing

make setup
# Erstellt .env aus .env.example
```

## 2. Credentials eintragen (1 Min)

```bash
nano .env
```

Füge deine AWS Bedrock Credentials ein:

```env
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=eu-central-1
```

## 3. Container starten (30 Sec)

```bash
make up
# n8n läuft auf http://localhost:5678
```

## 4. Health Check

```bash
make smoke
```

Output:
```
[smoke] ✓ n8n UI is reachable at http://localhost:5678
```

## 5. Workflow importieren (1 Min)

1. Browser öffnen: `http://localhost:5678`
2. **Workflows** → **Import from File**
3. `workflows/email-classification.json` wählen
4. Im Bedrock-Node AWS Credentials eintragen
5. **Activate** klicken

## 6. Test (30 Sec)

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "test@example.de",
    "subject": "Rechnung Februar 2026",
    "body": "Bitte begleichen Sie diese Rechnung innerhalb von 14 Tagen."
  }'
```

**Erwartete Antwort:**

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

---

## Weitere Befehle

```bash
make help         # Alle verfügbaren Befehle
make logs         # Container Logs live folgen
make down         # Container stoppen

# Test-E-Mails sehen
cat test-emails/anfrage-klein.txt
cat test-emails/beschwerde.txt
cat test-emails/bewerbung.txt
cat test-emails/rechnung.txt
cat test-emails/spam-newsletter.txt
```

## Dokumentation

- **README.md** — Ausführliche Dokumentation
- **test-emails/README.md** — Alle Test-Beispiele mit curl-Befehlen
- **SECURITY.md** — Sicherheitshinweise für Production

## Troubleshooting

### n8n UI nicht erreichbar?

```bash
# Container-Logs anschauen
make logs

# Container neustarten
make down
make up
```

### "AWS_ACCESS_KEY_ID nicht gesetzt"

```bash
# .env prüfen
nano .env

# Muss folgende Werte enthalten:
# AWS_ACCESS_KEY_ID=...
# AWS_SECRET_ACCESS_KEY=...
# AWS_REGION=eu-central-1
```

### Bedrock Timeout

Bedrock kann 10-30 Sekunden pro Request brauchen. Das ist normal.

---

**Nächste Schritte:**

1. [Alle Test-E-Mails durchlaufen](./test-emails/README.md#batch-test-aller-e-mails)
2. [Kategorien kalibrieren](./README.md#erweiterungen-next-steps)
3. [Zu Slack/Teams integrieren](./docker-compose.yml#optional-slack-integration)
4. [In Production deployen](./SECURITY.md#security-checkliste-für-production)

**Hilfe? Schreib eine Issue auf GitHub oder kontaktiere security@bojatschkin.de**
