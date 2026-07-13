<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Un solo rig para todos tus repos — plantilla de workspace multi-repo lista para IA.**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
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

La forma más rápida — un solo comando, sin clonar:

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) descarga esta plantilla (sin historial de git), inicializa un repositorio git nuevo en `my-project/`, y lanza el asistente de configuración interactivo de inmediato — el mismo asistente descrito abajo, solo que sin el paso de clonar por separado.

¿Prefieres la interfaz de GitHub, o quieres que el repo se cree bajo tu organización desde el principio?

1. Haz clic en **[Use this template](https://github.com/lakpriya1s/devrig/generate)** para crear `tu-org/tu-proyecto-workspace`.
2. Clónalo y ejecuta:

   ```bash
   ./setup.sh
   ```

   La primera vez, si `devrig.toml` todavía tiene los valores de ejemplo, te
   guiará de forma interactiva: nombre del proyecto, una descripción de una
   línea, organización de GitHub, los repos a clonar (puedes pegar varios a
   la vez, separados por espacios o comas), tu gestor de tickets (**Linear**,
   **Jira** u **otro** — elige uno de un menú), prefijo de tickets, rama por
   defecto y toggles de funciones — y luego escribe `devrig.toml` por ti,
   elimina los archivos propios de devrig y genera un `README.md` para *tu*
   proyecto en su lugar. ¿Prefieres editarlo a mano? Rellena `devrig.toml`
   antes de ejecutar el script y se saltará las preguntas.
3. Ejecuta `claude` desde esta carpeta y empieza a trabajar.

De cualquier forma, dentro de Claude Code: ejecuta `/mcp` y autentica el servidor del
gestor de tickets configurado (**linear** o **atlassian**; OAuth una sola vez
— **semble** no necesita autenticación), y reinicia Claude Code una vez para
que el hook de rtk surta efecto.

## 🤖 Arranca con tu agente de IA

### ¿Ya tienes tus repos?

¿Acabas de crear un workspace desde esta plantilla? Pega esto en tu agente de
programación (Claude Code, Cursor, opencode, …) y deja que termine la
configuración contigo:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md and AGENTS.md to understand the workspace.
2. Run ./setup.sh with me, relaying its interactive prompts (project name,
   description, GitHub org, repos, issue tracker, ticket prefix, default
   branch, feature toggles) so I can answer them — then help me fix anything
   it flags. It personalizes the workspace: devrig's own template files are
   removed and a README for my project is generated.
3. Work through the generated README's "Customize this workspace" checklist
   with me — fill AGENTS.md's Systems table and the per-repo skill references.
4. Commit the personalization on a task branch and open a PR.
```

### ¿Empezando un proyecto totalmente nuevo?

¿Todavía sin repos, solo una idea? Sustituye la parte marcada por la descripción de tu proyecto y pega esto en su lugar — el agente te lleva de la idea a un workspace funcionando, repos nuevos incluidos:

```text
I want to start a brand-new project using the devrig template
(https://github.com/lakpriya1s/devrig). Here's what I'm building:

[describe your project — what it does, who it's for, and any stack or
platform preferences you already have]

Help me go from this description to a working workspace:

1. Run `npx create-devrig <name>` to scaffold the workspace (pick a short
   project name from my description if I haven't given one).
2. Propose a repo breakdown and stack for each piece based on what I'm
   building — confirm with me before creating anything.
3. Create each repo on GitHub under my org (ask which) and scaffold it
   with its framework's starter command, committing the initial code.
4. Fill in devrig.toml (project name, description, org, the repos we just
   created, issue tracker, ticket prefix, default branch — make sure it
   matches what the new repos actually use) and run ./setup.sh.
5. Fill in AGENTS.md's Systems table and the generated README's "What's
   inside" table since you already know each stack.
```

## Qué hace setup.sh

`setup.sh` es idempotente — vuelve a ejecutarlo cuando quieras para actualizar
todos los repos y herramientas. Hace lo siguiente:

0. **Solo la primera vez**: si `devrig.toml` todavía tiene los valores de ejemplo, pregunta todo lo anterior de forma interactiva y escribe `devrig.toml`.
1. **Personaliza el workspace**: elimina los archivos propios de devrig
   (`docs/`, `assets/`, `CITATION.cff`, `CONTRIBUTING.md`, `LICENSE`) y genera
   un `README.md` para *tu* proyecto a partir de `devrig.toml`. Se omite dentro
   del propio repo de devrig, y un README que hayas editado nunca se sobrescribe.
2. Comprueba los prerrequisitos (`git`, `gh` autenticado; instala `uv` si semble está habilitado).
3. Clona cada repo de `repos` lado a lado (o hace fast-forward de checkouts limpios de la rama por defecto), y los excluye del estado git de este repo vía `.git/info/exclude`.
4. Instala los hooks de git de ramas protegidas en este repo y en cada repo clonado.
5. Converge `.mcp.json` / `opencode.json` a tus toggles de `devrig.toml` — añadiendo el servidor `linear` o `atlassian` (Jira) según `issue_tracker`, o ninguno si elegiste "otro" — conservando los servidores MCP añadidos a mano, y genera `.claude/settings.local.json`.
6. Instala semble y calienta un índice de búsqueda por repo.
7. Instala rtk y registra su hook de Claude Code.
8. Genera `<project>.code-workspace` para VS Code (se omite si ya existe, así puedes personalizarlo y commitearlo).

## Lista de personalización

`setup.sh` se encarga por sí solo de la personalización mecánica (escribe
`devrig.toml`, elimina los archivos de la plantilla de devrig, genera tu
README de proyecto). Lo que queda es el conocimiento que solo tú tienes — la
sección **"Customize this workspace"** del README generado lleva esta misma
lista de tareas a tu workspace:

- [ ] `AGENTS.md` — rellena la tabla **Systems** (una fila por repo: qué es, stack) y la sección **Testing**. Es la fuente de verdad que lee cada skill. Mantén sincronizada la tabla "What's inside" del README generado.
- [ ] `.agents/skills/code-review/references/` y `.agents/skills/write-doc/references/` — un archivo de referencia por repo (copia `_example-repo.md`). Las skills funcionan sin ellos, pero con ellos son mucho más precisas.
- [ ] Si `issue_tracker` es `linear`: verifica la tabla de "Convenciones" de `.agents/skills/create-ticket/SKILL.md` contra tu workspace de Linear (equipos, proyectos, etiquetas). Si es `jira` u `other`: adapta las llamadas `mcp__linear__*` de `/start-task`, `/raise-pr` y `/create-ticket` a las herramientas MCP de tu gestor (cada skill lo señala al principio).
- [ ] Elimina o ajusta lo que un toggle haya deshabilitado (p. ej. quita las notas de semble de `CLAUDE.md` si no lo usas).

Para cambiar valores de configuración después (cambiar de gestor, añadir un
repo), edita `devrig.toml` directamente y vuelve a ejecutar `./setup.sh`.

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
