# Hoja de referencia rápida: el camino veloz para vibecodear en AWS
## Claude Build Day @ Student Community Day México 2026

> **Mentor responsable de Fase 1:** Roberto Flores Segundo (Siegfried)  
> **Objetivo:** Conectar tu agente a AWS y tenerlo listo para construir en menos de 5 minutos.

---

## 1. El flujo express (En 4 comandos rápidos de copiar y pegar)

### Paso 1: Instalar Claude Code y activar PATH (Comando único)
* **Linux (Ubuntu, Debian, Mint, Fedora, Arch) o macOS (Terminal / iTerm2):**  
  ```bash
  curl -fsSL https://claude.ai/install.sh | bash && export PATH="$HOME/.local/bin:$PATH" && (echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile 2>/dev/null; true)
  ```
* **Windows (PowerShell):**  
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; irm https://claude.ai/install.ps1 | iex; $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
  ```
* **Windows (Git Bash):**  
  ```bash
  curl -fsSL https://claude.ai/install.sh | bash && export PATH="$HOME/.local/bin:$PATH" && (echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null; true)
  ```

---

### Paso 2: Crear carpeta de proyecto y entrar
* **En Linux, macOS o Git Bash:**
  ```bash
  mkdir mi-proyecto && cd mi-proyecto && claude
  ```
* **En Windows (PowerShell):**
  ```powershell
  mkdir mi-proyecto; cd mi-proyecto; claude
  ```

---

### Paso 3: Iniciar sesión en Claude Code
Dentro de Claude Code escribe:
```text
/login
```
*(Elige: `2. Anthropic Console account` -> `1. Sign in with your Console account`)*  
*(Nota: Si ya tenías Claude abierto previamente con tu cuenta personal sin créditos, teclea primero `/logout` y luego `/login`)*.

---

### Paso 4: Pegar el prompt mágico de AWS
```text
Configure el kit de herramientas de agentes para AWS siguiendo estas instrucciones:
https://raw.githubusercontent.com/aws/agent-toolkit-for-aws/refs/heads/main/setup-instructions/setup.md
```

---

## 2. Las 3 respuestas que debes darle al agente

Cuando el agente lea el archivo y te haga las preguntas de inicio, responde:

| Pregunta del agente | Qué debes responder |
| :--- | :--- |
| **Profile name** (Nombre del perfil AWS) | Escribe un nombre como `mi-proyecto` o `default`. |
| **AWS Experience** (¿Nueva experiencia?) | Responde **Sí** (si creaste tu cuenta con login de Google/GitHub y creaste un proyecto en `settings.aws.com`). |
| **Region** (Región de tu proyecto) | La región de tu proyecto en AWS (comúnmente `us-east-1`, ver en ajustes del proyecto). |

---

## 3. Las dos acciones humanas necesarias

Durante todo el proceso automático, solo deberás intervenir en dos momentos breves:
1. **Inicio de sesión en navegador:** Cuando el agente ejecute `aws login`, se abrirá tu navegador. Selecciona tu sesión activa y da clic en **Autorizar**.
2. **Asistente interactivo:** Si el agente lanza el asistente de configuración del Agent Toolkit en terminal, confirma tus opciones con `Enter`.

---

## 4. Matriz multiplataforma de dependencias previas

Si el agente detecta que falta alguna herramienta base, estos son los comandos directos por sistema:

| Herramienta | Linux (Ubuntu / Debian) | macOS (Zsh / Bash) | Windows (PowerShell) | Windows (Git Bash) |
| :--- | :--- | :--- | :--- | :--- |
| **Claude Code** (Nativo) | `curl -fsSL https://claude.ai/install.sh \| bash && export PATH="$HOME/.local/bin:$PATH"` | `curl -fsSL https://claude.ai/install.sh \| bash && export PATH="$HOME/.local/bin:$PATH"` *(o `brew install --cask claude-code`)* | `irm https://claude.ai/install.ps1 \| iex` | `curl -fsSL https://claude.ai/install.sh \| bash && export PATH="$HOME/.local/bin:$PATH"` |
| **uv** (Gestor de herramientas) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | `brew install uv` | `irm https://astral.sh/uv/install.ps1 \| iex` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| **AWS CLI v2** | `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install` | `curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg" && sudo installer -pkg AWSCLIV2.pkg -target /` | `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi` | `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi` |

---

## 5. Resolución de atascos en 30 segundos (Troubleshooting)

| Problema en pantalla | Causa frecuente | Solución operativa |
| :--- | :--- | :--- |
| **`command not found: claude`** | `~/.local/bin` no está en tu variable `$PATH`. | Corre `export PATH="$HOME/.local/bin:$PATH"` o ejecuta `~/.local/bin/claude`. |
| **`'claude' is not recognized` (Windows)** | La ventana de PowerShell no ha recargado el `$PATH`. | Cierra y vuelve a abrir PowerShell, o recárgalo con `$env:Path = ...`. |
| **El navegador no abre con `aws login`** | Entorno WSL, SSH o sin interfaz gráfica. | Ejecuta `aws login --region us-east-1 --profile mi-proyecto --remote` y copia el enlace en tu navegador. |
| **`Invalid request parameters: JSON-RPC -32602`** | La sesión de AWS caducó o el MCP no tiene el perfil configurado. | Vuelve a correr `aws login --profile mi-proyecto` en terminal. |
| **`401 Unauthorized` en Claude Code** | Clave de Anthropic no cargada o sesión no vinculada. | Ejecutar `/login` dentro de Claude Code y autenticar con la consola de Anthropic en el navegador. |
| **`credit balance is too low`** | Tu organización aún no tiene cargado el saldo de la oferta. | Verificar en la consola web de Anthropic que la organización activa sea la que recibió los créditos de cortesía. |

---

## 6. Validación de conexión sin costo y primer despliegue

Una vez completada la configuración, prueba que el agente se comunica con AWS sin crear recursos:

```text
Check that the AWS MCP Server is connected and that I'm signed in to AWS. Confirm the Region configured for this project. Do not create or change any AWS resources.
```

Y luego arranca tu primer despliegue en la nube:
```text
Please make a single page webapp game and deploy it to AWS.
```
