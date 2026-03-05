.PHONY: setup up down logs smoke import help

help:
	@echo "E-Mail-Klassifikation & Routing — Available targets:"
	@echo ""
	@echo "  make setup          Create .env from .env.example"
	@echo "  make up             Start Docker containers (docker compose up -d)"
	@echo "  make down           Stop Docker containers"
	@echo "  make logs           Stream logs from n8n container"
	@echo "  make smoke          Health check (n8n UI reachable?)"
	@echo "  make import         Import workflow from JSON file (via API)"
	@echo "  make help           Show this message"
	@echo ""
	@echo "Quickstart:"
	@echo "  make setup && make up && make smoke"
	@echo ""

setup:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "[setup] .env created from .env.example"; \
		echo "[setup] Please update AWS credentials in .env before running 'make up'"; \
	else \
		echo "[setup] .env already exists"; \
	fi

up:
	@echo "[up] Starting Docker containers..."
	docker compose up -d
	@echo "[up] n8n will be available at http://localhost:5678"
	@echo "[up] Use 'make logs' to view logs"

down:
	@echo "[down] Stopping Docker containers..."
	docker compose down
	@echo "[down] Stopped."

logs:
	docker compose logs -f n8n

smoke:
	@echo "[smoke] Checking n8n API health..."
	@if curl -fsS http://localhost:5678 >/dev/null 2>&1; then \
		echo "[smoke] ✓ n8n UI is reachable at http://localhost:5678"; \
		echo "[smoke] Next: Import workflow at http://localhost:5678/workflows/import"; \
	else \
		echo "[smoke] ✗ n8n UI is not reachable. Try 'make logs' to debug."; \
		exit 1; \
	fi

import:
	@echo "[import] Importing workflow from workflows/email-classification.json..."
	@if [ ! -f workflows/email-classification.json ]; then \
		echo "[import] Error: workflows/email-classification.json not found"; \
		exit 1; \
	fi
	@echo "[import] Open http://localhost:5678 → Workflows → Import from File"
	@echo "[import] Select: workflows/email-classification.json"
	@echo "[import] Then configure AWS credentials in the Bedrock node"
