# Test-E-Mails

11 Beispiel-E-Mails für den KI-E-Mail-Klassifikations-Workflow.

## Übersicht

| Datei | Kategorie | Priorität | Abteilung | Beschreibung |
|-------|-----------|-----------|-----------|--------------|
| `anfrage-klein.txt` | anfrage | mittel | Vertrieb | Kleinunternehmen, einfache Anfrage |
| `anfrage-enterprise.txt` | anfrage | hoch | Vertrieb | Enterprise-CTO, SAP-Integration |
| `beschwerde.txt` | beschwerde | hoch | Support | System-Ausfall, kritisch |
| `beschwerde-lieferung.txt` | beschwerde | hoch | Support | Projektversatz, Vertragsstrafen |
| `support-technisch.txt` | beschwerde | hoch | Support | Produktionsausfall, 847 Dokumente gestaaut |
| `bewerbung.txt` | bewerbung | mittel | HR | Cloud Engineer mit Zertifikaten |
| `bewerbung-initiativ.txt` | bewerbung | niedrig | HR | Initiativbewerbung mit CV |
| `rechnung.txt` | rechnung | mittel | Buchhaltung | Standard-Rechnung 14.875 EUR |
| `rechnung-saas.txt` | rechnung | niedrig | Buchhaltung | SaaS-Rechnung 54,74 EUR |
| `spam-newsletter.txt` | spam | niedrig | Papierkorb | Newsletter/Spam mit "90% RABATT" |
| `partnerschaft-anfrage.txt` | anfrage | mittel | Vertrieb | B2B-Kooperationsanfrage |

## Schnelltest mit curl

Nach `make up` und Workflow-Import in n8n:

### Test 1: Einfache Anfrage

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "max@example.com",
    "subject": "Angebot für KI-Automatisierung gesucht",
    "body": "wir sind ein mittelständisches Unternehmen mit ca. 50 Mitarbeitern und verarbeiten monatlich etwa 300 Rechnungen manuell. Das kostet uns viel Zeit und ist fehleranfällig. Könnten Sie uns ein Angebot für eine automatisierte Lösung erstellen? Unser Budget liegt bei ca. 15.000-20.000 EUR."
  }'
```

**Erwartung:**
```json
{
  "success": true,
  "classification": {
    "kategorie": "anfrage",
    "prioritaet": "mittel",
    "empfohlene_abteilung": "Vertrieb"
  },
  "route": "vertrieb"
}
```

### Test 2: Kritische Beschwerde

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "sabine@customer.de",
    "subject": "DRINGEND: System funktioniert nicht!",
    "body": "Seit gestern Nachmittag funktioniert das von Ihnen eingesetzte System überhaupt nicht mehr. Wir können keine Rechnungen mehr verarbeiten und das ganze Accounting steht still! Das ist eine Katastrophe!"
  }'
```

**Erwartung:**
```json
{
  "success": true,
  "classification": {
    "kategorie": "beschwerde",
    "prioritaet": "hoch",
    "dringend": true,
    "empfohlene_abteilung": "Support"
  },
  "route": "support"
}
```

### Test 3: Rechnung

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maria@dienstleister.de",
    "subject": "Rechnung Februar 2026 - RE-2026-089",
    "body": "im Anhang finden Sie die Rechnung für die im Februar erbrachten Dienstleistungen. Rechnungsnummer: RE-2026-089, Betrag brutto: 14.875,00 EUR, Zahlungsbedingungen: 30 Tage netto."
  }'
```

**Erwartung:**
```json
{
  "success": true,
  "classification": {
    "kategorie": "rechnung",
    "prioritaet": "mittel",
    "empfohlene_abteilung": "Buchhaltung"
  },
  "route": "buchhaltung"
}
```

### Test 4: Spam

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "noreply@spammer.com",
    "subject": "MEGA DEAL: 90% Rabatt auf Cloud-Zertifikate!!!",
    "body": "NUR HEUTE: Alle AWS-, Azure- und Google-Cloud-Zertifizierungen mit 90% RABATT! Diese Nachricht wurde an 50.000 Empfänger gesendet."
  }'
```

**Erwartung:**
```json
{
  "success": true,
  "classification": {
    "kategorie": "spam",
    "prioritaet": "niedrig",
    "empfohlene_abteilung": "Papierkorb"
  },
  "route": "papierkorb"
}
```

### Test 5: Bewerbung

```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{
    "from": "lisa.weber@email.de",
    "subject": "Initiativbewerbung als Cloud Engineer",
    "body": "Ich bin erfahrene Cloud Engineer mit 5 Jahren Erfahrung in AWS und Azure. Ich würde mich sehr freuen, Teil Ihres Teams zu werden. Qualifikationen: AWS Solutions Architect Professional, CKA, Terraform Associate."
  }'
```

**Erwartung:**
```json
{
  "success": true,
  "classification": {
    "kategorie": "bewerbung",
    "prioritaet": "mittel",
    "empfohlene_abteilung": "HR"
  },
  "route": "hr"
}
```

## Batch-Test aller E-Mails

```bash
#!/bin/bash

declare -a subjects=(
  "Angebot für KI-Automatisierung gesucht"
  "Evaluierung KI-gestützte Dokumentenverarbeitung"
  "DRINGEND: System funktioniert nicht!"
  "Projekt 3 Wochen im Verzug — eskaliert an GF"
  "Initiativbewerbung als Cloud Engineer"
  "Initiativbewerbung als Cloud Engineer / DevOps"
  "Rechnung Februar 2026 - RE-2026-089"
  "Rechnung Nr. INV-2026-0891"
  "MEGA DEAL: 90% Rabatt"
  "DRINGEND: Produktionssystem ausgefallen"
  "Kooperationsanfrage - KI-Integration"
)

for i in {0..10}; do
  echo "Test $((i+1)): ${subjects[$i]}"
  curl -s -X POST http://localhost:5678/webhook/email-classification \
    -H "Content-Type: application/json" \
    -d "{\"subject\": \"${subjects[$i]}\", \"body\": \"Test-Body $i\"}" | jq '.classification.kategorie'
done
```

## Daten aus Dateien lesen (Fortgeschritten)

Für realistische Tests mit den kompletten E-Mail-Texten:

```bash
#!/bin/bash

for file in test-emails/*.txt; do
  subject=$(head -1 "$file" | sed 's/Betreff: //')
  body=$(tail -n +3 "$file" | tr '\n' ' ')

  echo "Testing: $subject"
  curl -s -X POST http://localhost:5678/webhook/email-classification \
    -H "Content-Type: application/json" \
    -d "{\"subject\": \"$subject\", \"body\": \"$body\"}" | jq .
  echo "---"
done
```

## Erwartete Klassifikationen

| Datei | kategorie | route | dringend |
|-------|-----------|-------|----------|
| anfrage-klein.txt | anfrage | vertrieb | false |
| anfrage-enterprise.txt | anfrage | vertrieb | true |
| beschwerde.txt | beschwerde | support | true |
| beschwerde-lieferung.txt | beschwerde | support | true |
| support-technisch.txt | beschwerde | support | true |
| bewerbung.txt | bewerbung | hr | false |
| bewerbung-initiativ.txt | bewerbung | hr | false |
| rechnung.txt | rechnung | buchhaltung | false |
| rechnung-saas.txt | rechnung | buchhaltung | false |
| spam-newsletter.txt | spam | papierkorb | false |
| partnerschaft-anfrage.txt | anfrage | vertrieb | false |

## Fehlerbehandlung testen

### Leerer Request
```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Erwartung:** Fehler 400, "Es wurde kein E-Mail-Inhalt übergeben."

### Ungültiges JSON
```bash
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d 'invalid json'
```

**Erwartung:** Fehler 400, JSON parse error

## Performance-Test

```bash
#!/bin/bash

time for i in {1..100}; do
  curl -s -X POST http://localhost:5678/webhook/email-classification \
    -H "Content-Type: application/json" \
    -d '{"subject": "Test", "body": "Body"}' > /dev/null
done
```

Durchschnittliche Response-Zeit sollte unter 5 Sekunden pro Request liegen (abhängig von Bedrock-Latenz).
