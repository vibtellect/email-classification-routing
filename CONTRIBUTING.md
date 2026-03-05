# Contributing

Contributions sind willkommen! Dieses Projekt ist ein Open-Source-PoC und wir freuen uns über Verbesserungsvorschläge.

## Vor dem Start

1. **Fork** das Repo auf GitHub
2. **Clone** deinen Fork lokal
3. Erstelle einen Feature-Branch: `git checkout -b feature/meine-feature`
4. **Teste** deine Änderungen lokal

## Contribution Types

### Bug-Fixes
- Beschreibe den Bug deutlich in der Issue
- Gib Schritte zur Reproduktion an
- Bitte PR mit Referenz zur Issue ein

### Feature-Requests
- Diskutiere größere Features zuerst in einer Issue
- Erkläre den Use-Case und den Nutzen
- Kleinere Verbesserungen können direkt als PR eingereicht werden

### Dokumentation
- Verbesserungen zu README, Test-Beispiele, etc. sind immer willkommen
- Achte auf korrekte Formatierung (Markdown)

### Test-E-Mails
- Neue Test-E-Mail-Beispiele können als `.txt` in `test-emails/` hinzugefügt werden
- Aktualisiere auch `test-emails/README.md` mit der neuen E-Mail

## Commit-Richtlinien

```
Format: <type>: <subject>

<body>

Closes #<issue-number>
```

### Types
- `fix:` Bug-Fix
- `feat:` Neue Feature
- `docs:` Dokumentation
- `test:` Tests hinzufügen/ändern
- `chore:` Build, Dependencies, etc.
- `refactor:` Code-Umstrukturierung ohne Feature-Änderung

### Beispiele
```
feat: Add Slack channel routing configuration
docs: Update quickstart section in README
fix: Parse JSON response from Bedrock with special characters
test: Add test email for partnership inquiries
```

## Code-Stil

### JavaScript/n8n
- Konsistente Formatierung (siehe `workflows/email-classification.json`)
- Kommentare auf Deutsch (Funktionalität deutsch, techn. Details ok)
- Keine kurzen Variablennamen — `email_content` statt `ec`

### JSON
- 2 Spaces Indentation
- Keine Trailing Commas
- Strukturiert nach Logik, nicht alphabetisch

### Dokumentation
- Deutsche Texte für Benutzer
- Englisch ok für techn. Prozesse (AWS, Docker, etc.)
- Markdown-Konventionen: `# H1`, `## H2`, usw.

## Testing

Vor dem Commit:

```bash
# 1. Starte den lokalen Demo-Container
make up

# 2. Teste mit allen Test-E-Mails
bash test-emails/test-batch.sh

# 3. Überprüfe die Klassifikationsergebnisse
curl -X POST http://localhost:5678/webhook/email-classification \
  -H "Content-Type: application/json" \
  -d '{...}'

# 4. Logs prüfen
make logs
```

## PR-Prozess

1. **Branch erstellen**: `git checkout -b feature/xyz`
2. **Commits**: Aussagekräftige Commit-Messages
3. **Push**: `git push origin feature/xyz`
4. **PR öffnen**: Mit aussagekräftiger Beschreibung
5. **Review abwarten**: Wir geben Feedback
6. **Merge**: Nach Approval wird PR gemergt

## Reporting Issues

### Bug-Report-Template
```
## Beschreibung
[Kurze Beschreibung des Bugs]

## Reproduzierbarkeitschritte
1. ...
2. ...

## Erwartetes Verhalten
[Was sollte passieren?]

## Aktuelles Verhalten
[Was passiert stattdessen?]

## Umgebung
- OS: [z.B. macOS 13.2]
- Docker Version: [z.B. 24.0.0]
- n8n Version: [z.B. 1.76.1]

## Logs
[Relevante Fehlerausgaben hier einfügen]
```

### Feature-Request-Template
```
## Feature-Beschreibung
[Kurze Beschreibung der gewünschten Feature]

## Problem-Statement
[Welches Problem löst diese Feature?]

## Mögliche Implementierung
[Ideen zur Umsetzung, falls vorhanden]

## Zusätzlicher Kontext
[Screenshots, Referenzen, etc.]
```

## Code of Conduct

- Respektvolle Kommunikation
- Keine Belästigung, Diskriminierung oder Missbrauch
- Sachliche Kritik ist willkommen
- Fragen sind keine doofen Fragen

## Lizenz

Mit deinem Beitrag akzeptierst du, dass dein Code unter der MIT-Lizenz veröffentlicht wird.

## Kontakt

Fragen? Schreib eine Issue oder kontaktiere:
- GitHub Issues für Bug-Reports
- GitHub Discussions für allgemeine Fragen

Danke für deine Unterstützung!
