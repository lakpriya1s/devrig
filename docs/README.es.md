<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Un solo rig para todos tus repos — plantilla de workspace multi-repo lista para IA.**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · **Español** · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## ¿Qué es devrig?

devrig es un *meta-repo*: una carpeta que contiene todos los repos de tu
proyecto **más** las herramientas de IA para desarrollar a través de ellos.
Este repo solo versiona las herramientas — tus repos de proyecto los clona
`setup.sh` lado a lado y quedan sin seguimiento. Todo se configura desde un
único archivo **`devrig.toml`**.

| | Qué obtienes |
|---|---|
| 🧠 | **Skills de flujo de trabajo con IA** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (independientes del agente, en `.agents/skills/`, con symlinks para Claude Code; opencode también configurado) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — búsqueda semántica de código que los agentes usan vía MCP en lugar de grep y lectura de archivos |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — proxy de comandos que optimiza tokens para Claude Code |
| 🎫 | **MCP de gestor de tickets** — Linear, Jira o el tuyo propio; elegido de forma interactiva por `setup.sh` |
| 🛡️ | **Hooks de git para ramas protegidas** — sin commits/pushes accidentales a tu rama por defecto, en ningún repo |
| 📚 | **`knowledge/`** — esqueleto de base de conocimiento en markdown (arquitectura, ADRs, documentos de diseño, runbooks) que las herramientas de IA indexan y donde escriben |
| 🖥️ | **Workspace multi-raíz de VS Code generado** — todos los repos en una ventana |

## Inicio rápido

1. Haz clic en **[Use this template](https://github.com/lakpriya1s/devrig/generate)** para crear `tu-org/tu-proyecto-workspace`.
2. Clónalo y ejecuta:

   ```bash
   ./setup.sh
   ```

   La primera vez, si `devrig.toml` todavía tiene los valores de ejemplo, te
   guiará de forma interactiva: nombre del proyecto, organización de GitHub,
   los repos a clonar (puedes pegar varios a la vez, separados por espacios o
   comas), tu gestor de tickets (**Linear**, **Jira** u **otro** — elige uno
   de un menú), prefijo de tickets, rama por defecto y toggles de funciones —
   y luego escribe `devrig.toml` por ti. ¿Prefieres editarlo a mano? Rellena
   `devrig.toml` antes de ejecutar el script y se saltará las preguntas.
3. Ejecuta `claude` desde esta carpeta y empieza a trabajar.

Después, dentro de Claude Code: ejecuta `/mcp` y autentica el servidor del
gestor de tickets configurado (**linear** o **atlassian**; OAuth una sola vez
— **semble** no necesita autenticación), y reinicia Claude Code una vez para
que el hook de rtk surta efecto.

## 🤖 Arranca con tu agente de IA

¿Acabas de crear un workspace desde esta plantilla? Pega esto en tu agente de
programación (Claude Code, Cursor, opencode, …) y deja que termine la
configuración contigo:

```text
Acabo de crear un workspace desde la plantilla devrig
(https://github.com/lakpriya1s/devrig). Ayúdame a configurarlo:

1. Lee README.md, AGENTS.md y devrig.toml para entender el workspace.
2. Ejecuta ./setup.sh conmigo — te preguntará de forma interactiva mi nombre
   de proyecto, organización de GitHub, lista de repos (puedo pegar varios a
   la vez), gestor de tickets (Linear, Jira u otro), prefijo de tickets, rama
   por defecto y toggles de funciones, y luego escribirá devrig.toml. Transmíteme
   sus preguntas y ayúdame a responderlas.
3. Ayúdame a arreglar lo que ./setup.sh señale.
4. Rellena la tabla Systems de AGENTS.md — una fila por repo (qué es, stack).
5. Para cada repo, escribe una referencia de revisión en
   .agents/skills/code-review/references/<repo>.md y una de documentación en
   .agents/skills/write-doc/references/<repo>.md (copia los scaffolds
   _example-repo.md y verifica cada dato en el código).
6. Si elegí Linear, verifica la tabla de convenciones de create-ticket contra
   mi workspace de Linear. Si elegí Jira u otro gestor, ayúdame a adaptar las
   llamadas MCP de /start-task, /raise-pr y /create-ticket a él.
7. Haz commit de la personalización en una rama de tarea y abre un PR.
```

## Qué hace setup.sh

`setup.sh` es idempotente — vuelve a ejecutarlo cuando quieras para actualizar
todos los repos y herramientas. Hace lo siguiente:

0. **Solo la primera vez**: si `devrig.toml` todavía tiene los valores de ejemplo, pregunta todo lo anterior de forma interactiva y escribe `devrig.toml`.
1. Comprueba los prerrequisitos (`git`, `gh` autenticado; instala `uv` si semble está habilitado).
2. Clona cada repo de `repos` lado a lado (o hace fast-forward de checkouts limpios de la rama por defecto), y los excluye del estado git de este repo vía `.git/info/exclude`.
3. Instala los hooks de git de ramas protegidas en este repo y en cada repo clonado.
4. Converge `.mcp.json` / `opencode.json` a tus toggles de `devrig.toml` — añadiendo el servidor `linear` o `atlassian` (Jira) según `issue_tracker`, o ninguno si elegiste "otro" — conservando los servidores MCP añadidos a mano, y genera `.claude/settings.local.json`.
5. Instala semble y calienta un índice de búsqueda por repo.
6. Instala rtk y registra su hook de Claude Code.
7. Genera `<project>.code-workspace` para VS Code (se omite si ya existe, así puedes personalizarlo y commitearlo).

## Lista de personalización

Tras la primera ejecución de `setup.sh`, haz tu commit de personalización:

- [ ] `devrig.toml` — `setup.sh` te pregunta estos valores de forma interactiva la primera vez (o rellénalo a mano antes de ejecutarlo y se saltará las preguntas). Para cambiar valores después (cambiar de gestor, añadir un repo), edita `devrig.toml` directamente y vuelve a ejecutar `./setup.sh`.
- [ ] `AGENTS.md` — rellena la tabla **Systems** (una fila por repo: qué es, stack) y la sección **Testing**. Es la fuente de verdad que lee cada skill.
- [ ] `.agents/skills/code-review/references/` y `.agents/skills/write-doc/references/` — un archivo de referencia por repo (copia `_example-repo.md`). Las skills funcionan sin ellos, pero con ellos son mucho más precisas.
- [ ] Si `issue_tracker` es `linear`: verifica la tabla de "Convenciones" de `.agents/skills/create-ticket/SKILL.md` contra tu workspace de Linear (equipos, proyectos, etiquetas). Si es `jira` u `other`: adapta las llamadas `mcp__linear__*` de `/start-task`, `/raise-pr` y `/create-ticket` a las herramientas MCP de tu gestor (cada skill lo señala al principio).
- [ ] Elimina o ajusta lo que un toggle haya deshabilitado (p. ej. quita las notas de semble de `CLAUDE.md` si no lo usas).

## Estructura

| Ruta | Qué es |
|---|---|
| `devrig.toml` | Tu configuración de proyecto — el único archivo que leen todas las herramientas |
| `setup.sh` | Script de arranque/actualización idempotente |
| `AGENTS.md` | Fuente de verdad independiente del agente (sistemas, reglas de ramas, convenciones) |
| `CLAUDE.md` | Específicos de Claude Code; importa `AGENTS.md` |
| `.agents/skills/` | Skills de flujo de trabajo canónicas (independientes del agente) |
| `.claude/` | Ajustes de Claude Code, agentes, symlinks de skills |
| `.opencode/` | Agentes y configuración de plugin de opencode |
| `.mcp.json` / `opencode.json` | Servidores MCP (gestor de tickets, semble) |
| `git-hooks/` | Hooks pre-commit / pre-push de ramas protegidas |
| `knowledge/` | Base de conocimiento en markdown (arquitectura, decisiones, diseño, runbooks, producto, releases) |
| `<repo>/` (sin seguimiento) | Tus repos de proyecto, clonados por `setup.sh` |

## Añadir una skill

Ver [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md).
Versión corta: crea `.agents/skills/<name>/SKILL.md`, crea el symlink en
`.claude/skills/` y lístala en `CLAUDE.md`.

## Base de conocimiento

Los nuevos documentos de diseño, notas de arquitectura, ADRs y runbooks van en
[`knowledge/`](../knowledge/) como markdown vía PR — semble lo indexa, así que
los agentes encuentran el contexto de diseño igual que encuentran código.
Cuando supere este repo, publícalo como un repo `<project>-knowledge`
separado, añádelo a `repos` en `devrig.toml`, borra la carpeta aquí y actualiza el
puntero en `AGENTS.md`.

## Solución de problemas

- **`semble` o `uv` no se encuentran tras el setup** — abre un nuevo shell (el PATH se actualizó) y vuelve a ejecutar `./setup.sh`.
- **Faltan las herramientas del gestor de tickets en Claude** — ejecuta `/mcp` y completa el flujo OAuth del servidor `linear` o `atlassian`.
- **rtk no se activa** — reinicia Claude Code; verifica con `rtk gain` que los comandos se están proxificando.
- **Un repo no se actualiza** — `setup.sh` nunca toca un repo con cambios locales o en una rama de tarea; solo hace fast-forward de checkouts limpios de la rama por defecto.
- **setup.sh no me pregunta nada, falla directo con "edit devrig.toml first"** — solo pregunta de forma interactiva si está conectado a una terminal; ejecutarlo desde un script o CI exige que `devrig.toml` ya esté rellenado.
- **Elegiste Jira u "otro"** — el servidor MCP `atlassian` (Jira) se configura automáticamente, pero `/start-task`, `/raise-pr` y `/create-ticket` siguen llamando a las herramientas MCP de Linear — `setup.sh` te lo avisará al final de cada ejecución hasta que adaptes esas skills.

## Contribuir

devrig mejora con cada equipo que lo monta. Los reportes de bugs, nuevas
skills genéricas, mejor documentación y **traducciones del README** son muy
bienvenidos — ver [CONTRIBUTING.md](../CONTRIBUTING.md). Si devrig le ahorró
tiempo de configuración a tu equipo, una ⭐ ayuda a que otros lo encuentren.

## Licencia y cita

Publicado bajo la [Licencia MIT](../LICENSE).

Si usas devrig en tu trabajo o publicaciones, se agradece una cita — el botón
**"Cite this repository"** de GitHub (impulsado por [`CITATION.cff`](../CITATION.cff))
tiene los detalles, o:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>Construido a partir de un workspace multi-repo en producción · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
