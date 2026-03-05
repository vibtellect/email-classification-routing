# Sicherheit

Dieses Dokument behandelt Sicherheitsaspekte des Email-Classification-Routing Projekts.

## Sicherheits-Disclosure

Wenn du eine Sicherheitslücke findest, bitte **keine öffentliche Issue** öffnen.

Schreib stattdessen eine vertrauliche E-Mail an:
```
security@bojatschkin.de
```

Bitte gib an:
- Beschreibung der Sicherheitslücke
- Wie man sie reproduziert
- Mögliche Auswirkungen
- Suggested Fix (falls möglich)

Wir kümmern uns um Sicherheitsprobleme mit höchster Priorität.

---

## Bekannte Sicherheits-Einschränkungen (PoC)

Dieses Projekt ist ein **Proof of Concept** und **nicht production-ready**. Folgende Aspekte müssen für Production verbessert werden:

### 1. Webhook-Authentifizierung

**Status:** ❌ Nicht vorhanden

**Risiko:** Jeder kann Emails an `/webhook/email-classification` senden

**Für Production:**
```json
{
  "type": "POST /webhook/email-classification",
  "authentication": ["API-Key", "OAuth2", "HMAC-Signature"],
  "rate_limiting": "50 requests/minute",
  "ip_whitelist": "Optional"
}
```

### 2. AWS Credentials im Container

**Status:** ⚠️ Environment Variables in `docker-compose.yml`

**Risiko:** Credentials können in Docker logs sichtbar sein

**Für Production:**
- AWS IAM Roles für ECS/EC2 nutzen (keine Access Keys in .env)
- Secrets Manager oder SSM Parameter Store verwenden
- Rotate Access Keys regelmäßig (z.B. monthly)

```bash
# Credential rotation mit saws-CLI
saws rotate bojatschkin-dev --force
```

### 3. Fehler-Handling

**Status:** ⚠️ Minimal

**Risiko:** Detaillierte Fehlermeldungen können Informationen preisgeben

**Für Production:**
- Generische Error-Messages zu Clients
- Detaillierte Logs nur intern (CloudWatch)
- No stack traces in HTTP responses

### 4. Input-Validation

**Status:** ⚠️ Basis-Validierung nur

**Für Production:**
- Strict input validation (max length, character whitelist)
- Email header validation (From, Subject, etc.)
- MIME type checking
- Attachment size limits (wenn implementiert)

### 5. Datenspeicherung

**Status:** ⚠️ n8n speichert Executions lokal

**Risiko:** Sensitives Email-Content kann in n8n-Daten gespeichert sein

**Für Production:**
- Konfiguriere n8n `EXECUTIONS_DATA_PRUNE` auf kurze Retention (z.B. 7 Tage)
- Encrypt persisted data
- GDPR-konforme Data-Deletion Workflows

```yaml
# In docker-compose.yml
environment:
  - EXECUTIONS_DATA_PRUNE=true
  - EXECUTIONS_DATA_PRUNE_MAX_COUNT=50  # Keep only last 50
  - EXECUTIONS_DATA_PRUNE_TIMEOUT=604800  # 7 days in seconds
```

### 6. Bedrock-API Security

**Status:** ⚠️ Keine Encryption in Transit konfiguriert

**Für Production:**
- Nutze AWS VPC Endpoints für Bedrock (kein Internet)
- Enable Bedrock model monitoring
- Audit/Log alle Klassifikations-Anfragen

### 7. Logging & Monitoring

**Status:** ⚠️ Basic Docker logs nur

**Für Production:**
```
- CloudWatch Logs für alle Requests
- Structured Logging (JSON format)
- Alerts bei anomalen Mustern
- Monthly Security Audit Reports
```

### 8. DSGVO/Privacy

**Status:** ⚠️ Email-Inhalte gehen an AWS Bedrock

**Compliance-Anforderungen:**
- Datenschutzerklärung muss AWS Datenverarbeitung offenlegen
- Data Processing Agreement (DPA) mit AWS
- Recht auf Vergessenwerden implementiert
- Daten-Residenz beachten (EU-Bedrock in eu-central-1)

---

## Security Checkliste für Production

Vor dem Go-Live abarbeiten:

### Access Control
- [ ] Webhook-Authentifizierung aktiviert
- [ ] Rate Limiting aktiv
- [ ] IP Whitelist konfiguriert
- [ ] IAM Roles statt Access Keys

### Data Protection
- [ ] TLS/HTTPS erzwungen
- [ ] Credentials nicht in git
- [ ] .env in .gitignore
- [ ] Database/File encryption

### Monitoring & Audit
- [ ] CloudWatch Logs aktiv
- [ ] Error Tracking (Sentry/DataDog)
- [ ] Security Event Alerts
- [ ] Monthly Audit Logs

### Compliance
- [ ] DSGVO-Impact Assessment
- [ ] Data Processing Agreement
- [ ] Privacy Policy updated
- [ ] Retention Policy defined

### Infrastructure
- [ ] WAF (Web Application Firewall) vor n8n
- [ ] VPC Endpoints für AWS Services
- [ ] Backup Strategy
- [ ] Disaster Recovery Plan

### Code/Dependencies
- [ ] Dependency Scanning (npm audit)
- [ ] SAST (Static Analysis)
- [ ] Secrets Scanning
- [ ] Penetration Test

---

## Best Practices

### 1. Deployment

```bash
# Never run in production with:
- N8N_BASIC_AUTH_ACTIVE=false  (braucht Basic Auth!)
- Credentials in .env files
- Public Docker registry images ohne Scan

# Stattdessen:
- Private ECR repository mit signed images
- Credentials aus Secrets Manager
- Network isolation (VPC, Security Groups)
```

### 2. Secret Management

```bash
# AWS Secrets Manager für Credentials
aws secretsmanager create-secret \
  --name n8n/email-classification/bedrock \
  --secret-string '{"access_key":"...","secret_key":"..."}'

# In docker-compose oder ECS referenzieren
"secrets": {
  "AWS_CREDENTIALS": {
    "secretsManager": "n8n/email-classification/bedrock"
  }
}
```

### 3. Network Security

```yaml
# Security Groups (AWS EC2/ECS)
ingress:
  - port: 443  # HTTPS only!
    from: ALB  # Application Load Balancer

  - port: 5678  # n8n API
    from: VPC-Internal  # Nur intern

egress:
  - port: 443  # AWS Bedrock HTTPS
  - port: 53   # DNS

# Block all other traffic by default
default_policy: DENY
```

### 4. Logging Best Practices

```json
{
  "timestamp": "2026-03-05T14:30:00Z",
  "request_id": "uuid-v4",
  "event": "email_classification_received",
  "from_domain": "example.com",  // Not full email!
  "category": "anfrage",
  "status": "success",
  "latency_ms": 2345,
  "error": null
}
```

### 5. Incident Response

Notfall-Spielbuch:

1. **Detection:** CloudWatch Alert → Slack Notification
2. **Assessment:** Is it a security issue? Check logs, metrics
3. **Containment:** Disable webhook if attacked, kill containers
4. **Eradication:** Find root cause, fix code/config
5. **Recovery:** Redeploy, test, monitor closely
6. **Post-Incident:** Incident report, improve monitoring

---

## Dependency Security

### Regelmäßiges Scanning

```bash
# n8n built-in: npm audit
npm audit fix

# For Docker image security
trivy image n8nio/n8n:1.76.1

# Regular dependency updates (use dependabot)
```

### Locked Versions

Halte Versionen in docker-compose.yml explizit:

```yaml
services:
  n8n:
    image: n8nio/n8n:1.76.1  # ✓ Explicit version, not :latest
```

---

## Bug Bounty

Wenn du eine kritische Sicherheitslücke findest und verantwortungsvoll offenlegst, belohnen wir diese gerne.

Kontakt: `security@bojatschkin.de`

---

## Security Updates

Wenn ein kritisches Update für n8n/AWS/Dependencies veröffentlicht wird:

1. **Notification:** Wir werden das Repo aktualisieren
2. **Advisory:** Issue mit Severity-Label
3. **Patch Release:** Schnellstmögliches Update
4. **Notification:** GitHub Security Advisory

---

## Externe Ressourcen

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [n8n Security](https://docs.n8n.io/reference/security/)
- [DSGVO Compliance](https://www.bfdi.bund.de/)

---

**Letztes Update:** 05.03.2026
**Nächstes Security Review:** 05.06.2026
