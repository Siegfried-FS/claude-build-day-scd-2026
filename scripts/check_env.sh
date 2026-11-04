#!/usr/bin/env bash
# ==============================================================================
# Script de validación rápida de entorno — Claude Build Day @ SCD México 2026
# Mentor: Roberto Flores (Siegfried)
# ==============================================================================

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}================================================================${NC}"
echo -e "${CYAN}  Claude Build Day @ Student Community Day México 2026          ${NC}"
echo -e "${CYAN}  Verificación de entorno local / cloud (Fase 1: Setup seguro)  ${NC}"
echo -e "${CYAN}================================================================${NC}\n"

ERRORS=0

# Cargar variables de entorno si existen en archivos de perfil (Bash, Zsh, Profile)
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    for profile_file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$profile_file" ] && grep -q "ANTHROPIC_API_KEY" "$profile_file" 2>/dev/null; then
            eval "$(grep 'export ANTHROPIC_API_KEY=' "$profile_file" | tail -n 1)"
            break
        fi
    done
fi

# 1. Verificar Claude Code CLI (Instalador nativo o en PATH)
echo -n "1. Verificando Claude Code CLI... "
if command -v claude >/dev/null 2>&1; then
    CLAUDE_VER=$(claude --version 2>&1 | head -n 1)
    echo -e "${GREEN}[OK]${NC} $CLAUDE_VER"
elif [ -f "$HOME/.local/bin/claude" ]; then
    echo -e "${YELLOW}[INSTALADO PERO FUERA DE PATH]${NC}"
    echo -e "   └─ Archivo encontrado en ~/.local/bin/claude pero tu terminal actual no lo ve."
    echo -e "   └─ Ejecuta en tu terminal: export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo -e "   └─ Y persiste según tu shell:"
    echo -e "      • Bash (Linux):   echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
    echo -e "      • Bash (macOS):   echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bash_profile"
    echo -e "      • Zsh:            echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
else
    echo -e "${RED}[FALTA]${NC} Claude Code CLI no está instalado."
    echo -e "   └─ Instalación rápida oficial: curl -fsSL https://claude.ai/install.sh | bash && export PATH=\"\$HOME/.local/bin:\$PATH\""
    ERRORS=$((ERRORS + 1))
fi

# 2. Verificar ANTHROPIC_API_KEY o sesión /login
echo -n "2. Verificando credenciales de Anthropic... "
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    KEY_LEN=${#ANTHROPIC_API_KEY}
    if [ "$KEY_LEN" -gt 12 ]; then
        MASKED="${ANTHROPIC_API_KEY:0:10}...${ANTHROPIC_API_KEY:$((KEY_LEN-4)):4}"
    else
        MASKED="sk-ant-***"
    fi
    echo -e "${GREEN}[OK]${NC} Variable ANTHROPIC_API_KEY detectada ($MASKED)"
elif [ -f "$HOME/.claude.json" ] || [ -d "$HOME/.claude" ]; then
    echo -e "${GREEN}[OK]${NC} Sesión web configurada en ~/.claude"
else
    echo -e "${YELLOW}[PENDIENTE]${NC} Aún no has ejecutado /login dentro de Claude Code."
fi

# 3. Verificar uv (Gestor de herramientas del Agent Toolkit)
echo -n "3. Verificando uv... "
if command -v uv >/dev/null 2>&1; then
    UV_VER=$(uv --version 2>&1 | head -n 1)
    echo -e "${GREEN}[OK]${NC} $UV_VER"
else
    echo -e "${YELLOW}[AUTO-GESTIONADO]${NC} uv no detectado manualmente."
    echo -e "   └─ El agente de IA lo instalará de forma autónoma durante el setup si hace falta."
fi

# 4. Verificar AWS CLI
echo -n "4. Verificando AWS CLI v2... "
if command -v aws >/dev/null 2>&1; then
    AWS_VER=$(aws --version 2>&1 | cut -d' ' -f1)
    echo -e "${GREEN}[OK]${NC} $AWS_VER"
else
    echo -e "${YELLOW}[AUTO-GESTIONADO]${NC} aws-cli no detectado."
    echo -e "   └─ El agente lo instalará de forma autónoma con el prompt oficial."
fi

# 5. Verificar Node.js (Opcional si usas el instalador nativo)
echo -n "5. Verificando Node.js (opcional para desarrollo web)... "
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node -v)
    echo -e "${GREEN}[OK]${NC} $NODE_VER"
else
    echo -e "${YELLOW}[OPCIONAL]${NC} No detectado (el instalador nativo de Claude no lo requiere)."
fi

# 6. Verificar Python 3
echo -n "6. Verificando Python 3... "
if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}[OK]${NC} v$PY_VER"
else
    echo -e "${YELLOW}[OPCIONAL]${NC} python3 no detectado."
fi

# 7. Verificar credenciales activas de AWS (STS Caller Identity)
echo -n "7. Verificando sesión activa de AWS... "
if command -v aws >/dev/null 2>&1; then
    STS_OUTPUT=$(aws sts get-caller-identity 2>&1)
    if [ $? -eq 0 ]; then
        ACCOUNT_ID=$(echo "$STS_OUTPUT" | grep '"Account"' | awk -F'"' '{print $4}')
        ARN_ID=$(echo "$STS_OUTPUT" | grep '"Arn"' | awk -F'"' '{print $4}')
        echo -e "${GREEN}[OK]${NC} Conectado a cuenta: $ACCOUNT_ID"
        echo -e "   └─ Identidad: ${CYAN}$ARN_ID${NC}"
        
        if [[ "$ARN_ID" == *":root"* ]]; then
            echo -e "   ${RED}[ALERTA DE SEGURIDAD]${NC} Estás usando la cuenta Root. Por favor usa un usuario IAM con menor privilegio."
        fi
    else
        echo -e "${YELLOW}[PENDIENTE]${NC} Sin sesión activa aún. Se enlazará en el Paso 3 con aws login."
    fi
else
    echo -e "${YELLOW}[PENDIENTE]${NC} Se configurará durante el taller."
fi

# Resumen final
echo -e "\n----------------------------------------------------------------"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}[ESTADO] Entorno preparado para el taller.${NC}"
    echo -e "Listo para continuar con Fase 2 (Juan Mejía) y Fase 3 (Joselyn Lagunas)."
else
    echo -e "${YELLOW}[ESTADO] Se encontraron $ERRORS punto(s) de revisión.${NC}"
    echo -e "Revisa los pasos en el README.md o con el mentor Roberto Flores (Siegfried)."
fi
echo -e "----------------------------------------------------------------\n"
