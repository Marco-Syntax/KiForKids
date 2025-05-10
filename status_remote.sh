#!/bin/bash

# ===========================
# 📡 KiForKids Remote-Status
# ===========================

echo "🔐 SSH auf Server..."
ssh root@152.53.255.176 << 'EOF'

  echo "📦 Aktive Docker-Container auf dem Server:"
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

  echo ""
  echo "🌐 Teste Backend-Erreichbarkeit (localhost:8000)..."
  curl -s --head http://localhost:8000 | head -n 1

  echo ""
  echo "🔐 Letztes Git-Commit im Server-Projekt:"
  cd /opt/KiForKids
  git log -1 --pretty=format:"%h %s (%ci)"

EOF
