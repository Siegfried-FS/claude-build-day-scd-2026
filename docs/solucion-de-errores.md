# Guía de resolución de fallos y planes de contingencia (Plan B)
## Claude Build Day @ Student Community Day México 2026

> **Mentor responsable de Fase 1:** Roberto Flores Segundo (Siegfried)  
> **Propósito:** Anticipar y resolver en menos de 1 minuto cualquier error técnico, bloqueo de permisos o fallo de conectividad que sufran los asistentes durante el taller en vivo.

---

## 1. Claridad sobre los créditos del taller

> [!NOTE]
> * **En AWS (Nueva Experiencia):** Al crear una cuenta con inicio de sesión social (Google, GitHub, Apple o Amazon) y crear un proyecto, AWS otorga créditos de cortesía para construir y desplegar en la nube sin costo inicial.
> * **En Claude / Anthropic:** El cupón promocional de cortesía para los asistentes se anunciará durante la dinámica del evento. Si un asistente aún no tiene créditos aplicados o su saldo está en proceso, existen planes de contingencia para que trabaje sin interrupción.

---

## 2. Mapa de alertas críticas y puntos de quiebre (Evita que el asistente se trabe)

### Alerta 1: El error `command not found: claude` (Linux, macOS, Git Bash)
* **El síntoma:** Corres el instalador nativo, escribes `claude` y la terminal responde `command not found`.
* **La causa raíz:** El instalador de Anthropic deposita el ejecutable en `~/.local/bin/claude`. Esta ruta **no viene incluida por defecto** en la variable `$PATH` de la mayoría de terminales limpias.
* **Solución inmediata en la terminal actual (3 segundos):**
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```
  *(O arráncalo directamente tecleando la ruta completa: `~/.local/bin/claude`)*.

* **Solución permanente según tu Sistema y Shell:**
  * **Linux con Bash:**
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
    ```
  * **macOS con Bash (Terminal abre Login Shells que ignoran `~/.bashrc`):**
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
    ```
  * **macOS o Linux con Zsh:**
    ```zsh
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    ```
  * **Fish:**
    ```fish
    fish_add_path "$HOME/.local/bin"
    ```
  * **Git Bash en Windows:**
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    ```
  * **Comando comodín universal (lo inyecta en todos tus archivos sin fallar):**
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null; echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile 2>/dev/null
    ```

---

### Alerta 2: Incidencias en Windows (PowerShell, CMD y Git Bash)
* **El síntoma A (ExecutionPolicy):** En PowerShell dice `File ... cannot be loaded because running scripts is disabled on this system`.
  * **Solución:** Ejecuta `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` y vuelve a correr el comando.
* **El síntoma B (PATH no recargado):** Ya corriste el instalador de PowerShell pero al escribir `claude` en esa misma ventana no lo reconoce.
  * **Causa:** Windows actualizó el registro de variables de usuario, pero el proceso de PowerShell activo no hereda cambios en caliente.
  * **Solución 1:** Cierra la ventana y abre una nueva de PowerShell.
  * **Solución 2 (en caliente):** Ejecuta en esa misma ventana:
    ```powershell
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
    ```
* **El síntoma C (TLS 1.2 en Windows 10):** Error `Could not create SSL/TLS secure channel`.
  * **Solución:** Corre antes: `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`.
* **El síntoma D (Consola equivocada):** Corriste el comando en `cmd.exe` y dice `'irm' is not recognized`.
  * **Solución:** Abre **PowerShell** o **Git Bash**, nunca `cmd.exe`.

---

### Alerta 3: Modalidad de cuenta en Anthropic (Organización vs Individual)
* **El error invisible:** Si el estudiante elige *Individual* al registrarse en la consola de Anthropic, los cupones y ofertas de eventos fallan de forma silenciosa sin explicar la causa.
* **La regla:** Registrar la cuenta como **Organización** (ejemplo de nombre: `dev-tunombre`).
* **Plan de contingencia:** Si ya creó cuenta individual, ir a **Organization settings -> Organization** y convertirla a Organización en 2 clics.

---

### Alerta 4: Alcance de la clave de API (Default Workspace vs Organización)
* **El síntoma:** En terminal, las solicitudes son rechazadas con error de encabezado `anthropic-workspace-id required`.
* **La causa:** Al crear la API Key se eligió el alcance global `__all_workspaces__`.
* **La solución en 20 segundos:** Eliminar esa clave y crear una nueva asegurándose de seleccionar **Espacio de trabajo predeterminado (Default workspace)**.

---

### Alerta 5: La terminal del agente se queda esperando entrada interactiva (Exit code 253)
* **El síntoma:** El agente de IA intenta configurar el toolkit en un subproceso de fondo y arroja error `Exit code 253: requires interactive terminal`.
* **La solución inmediata:** Indicarle al alumno que abra una pestaña de terminal regular y corra el asistente interactivo manualmente:
  ```bash
  aws configure agent-toolkit --region us-east-1 --profile mi-proyecto
  ```
  Completar el asistente (tarda 30 segundos) y regresar al chat de la IA.

---

### Alerta 6: El navegador no se abre al ejecutar `aws login` (Entornos WSL / SSH / Headless)
* **El síntoma:** El comando se queda colgado o dice que no encuentra navegador web.
* **La solución en 15 segundos:** Usar el modo remoto de AWS CLI:
  ```bash
  aws login --region us-east-1 --profile mi-proyecto --remote
  ```
  Esto imprimirá una URL y un código alfanumérico en pantalla. El estudiante copia la URL en su navegador habitual de Windows/Mac, ingresa el código y autoriza.

---

### Alerta 7: Ya tenía Claude Code instalado con su cuenta personal previa (sin créditos)
* **El síntoma:** El estudiante ya tenía Claude Code en su máquina. Al abrirlo, entra directo a su sesión personal anterior sin pedirle vincularse a la organización del taller, y sus prompts fallan con `credit balance is too low`.
* **La solución en 30 segundos:**
  1. Dentro de la sesión activa de Claude, escribe:
     ```text
     /logout
     ```
  2. Vuelve a iniciar sesión tecleando:
     ```text
     /login
     ```
  3. Selecciona **Option 2 (Anthropic Console account · API usage billing)** y autoriza en el navegador seleccionando la organización del taller.
  4. *Opción directa por variable de entorno:* Si prefiere no tocar el navegador, simplemente puede exportar su clave de API de la organización del evento:
     * En Linux / macOS / Git Bash: `export ANTHROPIC_API_KEY="sk-ant-..."`
     * En Windows PowerShell: `$env:ANTHROPIC_API_KEY="sk-ant-..."`

---

## 3. Matriz de solución de incidencias en 30 segundos

| Mensaje de error en pantalla | Causa raíz | Solución operativa en el podio |
| :--- | :--- | :--- |
| **`command not found: claude`** | La ruta `~/.local/bin` no está en `$PATH` de la terminal activa. | Correr `export PATH="$HOME/.local/bin:$PATH"` o ejecutar `~/.local/bin/claude`. |
| **`'claude' is not recognized` (Windows)** | La ventana de PowerShell no ha recargado el `$PATH`. | Cerrar PowerShell y abrir una nueva ventana, o recargar `$env:Path`. |
| **`irm` o `iex` no se reconoce (Windows)** | El asistente está en `cmd.exe` clásico en lugar de PowerShell. | Abrir **PowerShell** (tecla Windows -> escribir PowerShell) o usar **Git Bash**. |
| **`ExecutionPolicy` restringida en Windows** | PowerShell bloquea la ejecución de scripts descargados. | Ejecutar: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` y volver a correr el comando. |
| **`Could not create SSL/TLS secure channel`** | Windows 10 con PowerShell 5.1 no tiene activo TLS 1.2. | Correr `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`. |
| **Alerta de desarrollador no verificado (macOS)** | Gatekeeper bloquea el paquete de AWS CLI. | Ajustes del Sistema -> Privacidad y seguridad -> Permitir de todos modos. |
| **`credit balance is too low` (Claude)** | Saldo en $0 USD en la organización de Anthropic. | **Plan B:** Si el alumno cuenta con suscripción web (Claude Pro/Team), correr `claude` sin variable de entorno y seleccionar *Claude account with subscription*. Si no, trabajar en parejas (*pair programming*) mientras se acredita el cupón. |
| **`anthropic-workspace-id required`** | La API Key se creó con ámbito «All workspaces». | Eliminar la clave y crear una nueva con ámbito **Default workspace**. |
| **`Profile is already configured with Access Key`** | El perfil tiene credenciales estáticas previas en `~/.aws/credentials`. | Ejecutar `aws login` con un nombre de perfil nuevo (ejemplo: `scd-2026`) o limpiar la sección correspondiente en `~/.aws/credentials`. |
| **`Invalid request parameters: JSON-RPC -32602`** | El servidor MCP (`aws-mcp`) no sabe qué perfil de AWS usar o la sesión caducó. | Volver a correr `aws login --profile mi-proyecto` para renovar la sesión de 12 horas. |
| **`403 Forbidden` / Desfase de hora (STS)** | El reloj interno de la laptop está desfasado por más de 5 minutos respecto al servidor de AWS. | En Windows: Ajustes -> Hora e idioma -> Sincronizar reloj ahora. En Linux: `sudo timedatectl set-ntp on`. En Mac: Ajustes -> Fecha y hora -> Ajustar automáticamente. |
| **Fuga accidental de clave en pantalla** | Durante una duda con proyector, una clave de API quedó visible. | **Sin pánico.** Ir a la consola de Anthropic o AWS, presionar **Revoke / Inactivate** sobre la clave comprometida y generar una nueva en 30 segundos. |

---

## 4. Los 3 planes de contingencia (Planes B) si la red o las cuentas fallan

### Plan B.1: Si la red del auditorio bloquea puertos o instaladores
* Si el WiFi del evento restringe descargas de binarios con `curl` o `irm`, compartir vía memoria USB o enlace local los instaladores predescargados:
  * `awscli-exe-linux-x86_64.zip` (Linux) / `AWSCLIV2.pkg` (macOS) / `AWSCLIV2.msi` (Windows).
  * Scripts preconfigurados: `install_claude.sh` y `install_claude.ps1`.

### Plan B.2: Si un estudiante no tiene créditos activos de Claude en terminal
* Puede utilizar **Kiro** o **Cursor** apuntando a un modelo alternativo o a las credenciales del equipo de trabajo.
* Modalidad de trabajo en parejas (*Pair Programming*): uno actúa como piloto (con la terminal activa) y otro como copiloto (analizando prompts y arquitectura).

### Plan B.3: Si la Nueva Experiencia de AWS presenta retrasos al crear el proyecto
* Entrar a la consola tradicional de AWS y canjear un cupón tradicional de AWS en **Billing and Cost Management -> Credits -> Redeem credit**.
