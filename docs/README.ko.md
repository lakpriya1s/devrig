<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**모든 저장소를 하나의 rig로 — AI 지원 멀티 레포 개발 워크스페이스 템플릿.**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · **한국어** · [සිංහල](README.si.md)

</div>

---

## devrig란?

devrig는 *메타 레포*입니다. 프로젝트의 모든 저장소와 그 사이를 넘나들며
개발하는 데 쓰이는 AI 툴링을 하나의 폴더에 담습니다. 이 저장소는 툴링만
버전 관리합니다 — 프로젝트 저장소들은 `setup.sh`가 나란히 클론하며 추적되지
않습니다. 모든 설정은 단 하나의 **`devrig.toml`** 파일에서 이루어집니다.

| | 제공되는 것 |
|---|---|
| 🧠 | **AI 워크플로우 스킬** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (에이전트 독립적으로 `.agents/skills/`에 위치, Claude Code용 심볼릭 링크, opencode도 설정됨) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep과 파일 읽기 대신 에이전트가 MCP로 사용하는 시맨틱 코드 검색 |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code의 토큰을 절약하는 명령어 프록시 |
| 🎫 | **이슈 트래커 MCP** — Linear, Jira, 또는 직접 연결; `setup.sh`가 대화식으로 선택하게 함 |
| 🛡️ | **보호 브랜치 git 훅** — 어떤 저장소에서도 기본 브랜치에 실수로 커밋/푸시하지 않도록 차단 |
| 📚 | **`knowledge/`** — AI 툴링이 색인하고 기록하는 markdown 지식 베이스 뼈대(아키텍처, ADR, 설계 문서, 런북) |
| 🖥️ | **자동 생성되는 VS Code 멀티 루트 워크스페이스** — 모든 저장소를 한 창에서 |

## 빠른 시작

가장 빠른 방법 — 클론 없이 명령어 하나로:

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig)가 이 템플릿을 가져오고(git 기록 없이), `my-project/`에 새 git 저장소를 초기화한 뒤, 바로 대화식 설정 마법사를 실행합니다 — 아래 설명과 동일한 마법사이며, 별도의 클론 단계만 없습니다.

GitHub UI를 선호하거나 처음부터 자신의 org 아래에 저장소를 만들고 싶다면:

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)**을 클릭해 `your-org/your-project-workspace`를 만듭니다.
2. 클론한 뒤 실행:

   ```bash
   ./setup.sh
   ```

   처음 실행 시 `devrig.toml`이 아직 예시 값 그대로면 대화식으로 안내합니다:
   프로젝트 이름, GitHub org, 클론할 저장소(공백이나 쉼표로 구분해 여러
   개를 한 번에 붙여넣기 가능), 이슈 트래커(**Linear**, **Jira**, 또는
   **기타** — 메뉴에서 선택), 티켓 접두사, 기본 브랜치, 기능 토글을 물어본
   뒤 `devrig.toml`을 대신 작성해 줍니다. 직접 편집하고 싶다면 스크립트 실행
   전에 `devrig.toml`을 미리 채워 두면 프롬프트를 건너뜁니다.
3. 이 폴더에서 `claude`를 실행하고 작업을 시작하세요.

어느 방법이든, 그다음 Claude Code 안에서 `/mcp`를 실행해 설정된 트래커 서버(**linear**
또는 **atlassian**)를 인증하고(1회성 OAuth, **semble**은 인증 불필요),
rtk 훅이 적용되도록 Claude Code를 한 번 재시작하세요.

## 🤖 AI 에이전트로 시작하기

방금 이 템플릿으로 워크스페이스를 만드셨나요? 아래 내용을 AI 코딩
에이전트(Claude Code, Cursor, opencode 등)에 붙여넣고 나머지 설정을 함께
마무리하세요:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md and AGENTS.md to understand the workspace.
2. Run ./setup.sh with me, relaying its interactive prompts (project name,
   GitHub org, repos, issue tracker, ticket prefix, default branch, feature
   toggles) so I can answer them — then help me fix anything it flags.
3. Work through the README's "Customization checklist" section with me.
4. Commit the personalization on a task branch and open a PR.
```

## setup.sh가 하는 일

`setup.sh`는 멱등합니다 — 언제든 다시 실행해 모든 저장소와 도구를 업데이트할 수 있습니다:

0. **최초 1회만**: `devrig.toml`이 아직 예시 값이면 위 모든 항목을 대화식으로 묻고 `devrig.toml`에 기록.
1. 사전 요구사항 확인(`git`, 인증된 `gh`; semble 활성화 시 `uv` 설치).
2. `repos`의 각 저장소를 나란히 클론(깨끗한 기본 브랜치 체크아웃은 fast-forward)하고, `.git/info/exclude`로 이 저장소의 git status에서 제외.
3. 이 저장소와 클론된 모든 저장소에 보호 브랜치 git 훅 설치.
4. `.mcp.json` / `opencode.json`을 `devrig.toml` 토글에 수렴 — `issue_tracker`에 따라 `linear` 또는 `atlassian`(Jira) 서버를 추가하고, "기타"를 선택했다면 아무것도 추가하지 않음 — 직접 추가한 MCP 서버는 보존하고 `.claude/settings.local.json` 생성.
5. semble을 설치하고 저장소별 검색 인덱스를 예열.
6. rtk를 설치하고 Claude Code 훅 등록.
7. VS Code용 `<project>.code-workspace` 생성(이미 있으면 건너뛰므로 커스터마이즈해 커밋해도 안전).

## 커스터마이징 체크리스트

첫 `setup.sh` 실행 후 개인화 커밋을 만드세요:

- [ ] `devrig.toml` — 첫 실행 시 `setup.sh`가 대화식으로 물어봅니다(또는 실행 전에 직접 채워 두면 프롬프트를 건너뜁니다). 나중에 값을 바꾸려면(트래커 변경, 저장소 추가 등) `devrig.toml`을 직접 편집하고 `./setup.sh`를 다시 실행하세요.
- [ ] `AGENTS.md` — **Systems** 표(저장소마다 한 줄: 역할, 스택)와 **Testing** 섹션 작성. 모든 스킬이 읽는 단일 정보원입니다.
- [ ] `.agents/skills/code-review/references/`와 `.agents/skills/write-doc/references/` — 저장소마다 레퍼런스 파일 하나(`_example-repo.md` 복사). 없어도 동작하지만 있으면 훨씬 정밀해집니다.
- [ ] `issue_tracker`가 `linear`라면: `.agents/skills/create-ticket/SKILL.md`의 "컨벤션" 표를 Linear 워크스페이스(팀, 프로젝트, 라벨)와 대조하세요. `jira`나 `other`라면: `/start-task`, `/raise-pr`, `/create-ticket`의 `mcp__linear__*` 호출을 트래커의 MCP 도구 이름에 맞게 조정하세요(각 스킬 상단에 안내가 있습니다).
- [ ] 토글로 비활성화한 것들 삭제·조정(예: semble을 쓰지 않으면 `CLAUDE.md`에서 관련 내용 제거).

## 구조

| 경로 | 설명 |
|---|---|
| `devrig.toml` | 프로젝트 설정 — 모든 도구가 읽는 단 하나의 파일 |
| `setup.sh` | 멱등한 부트스트랩/업데이트 스크립트 |
| `AGENTS.md` | 에이전트 독립적 단일 정보원(시스템, 브랜치 규칙, 컨벤션) |
| `CLAUDE.md` | Claude Code 전용 내용; `AGENTS.md`를 임포트 |
| `.agents/skills/` | 표준 워크플로우 스킬(에이전트 독립적) |
| `.claude/` | Claude Code 설정, 에이전트, 스킬 심볼릭 링크 |
| `.opencode/` | opencode 에이전트 및 플러그인 설정 |
| `.mcp.json` / `opencode.json` | MCP 서버(이슈 트래커, semble) |
| `git-hooks/` | 보호 브랜치 pre-commit / pre-push 훅 |
| `knowledge/` | markdown 지식 베이스(아키텍처, 결정, 설계, 런북, 제품, 릴리스) |
| `<repo>/` (미추적) | `setup.sh`가 클론하는 프로젝트 저장소 |

## 스킬 추가하기

[`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md)를 참고하세요.
요약: `.agents/skills/<name>/SKILL.md`를 만들고 `.claude/skills/`에 심볼릭
링크한 뒤 `CLAUDE.md`에 등록합니다.

## 지식 베이스

새 설계 문서, 아키텍처 노트, ADR, 런북은 markdown으로 PR을 통해
[`knowledge/`](../knowledge/)에 들어갑니다 — semble이 색인하므로 에이전트는
코드를 찾듯 설계 컨텍스트를 찾습니다. 이 저장소 규모를 넘어서면 별도의
`<project>-knowledge` 저장소로 push하고, `devrig.toml`의 `repos`에 추가한 뒤
여기 폴더를 삭제하고 `AGENTS.md`의 포인터를 업데이트하세요.

## 문제 해결

- **setup 후 `semble`이나 `uv`를 찾을 수 없음** — 새 셸을 열고(PATH가 갱신됨) `./setup.sh`를 다시 실행하세요.
- **Claude에 트래커 도구가 없음** — `/mcp`를 실행해 `linear` 또는 `atlassian` 서버의 OAuth 흐름을 완료하세요.
- **rtk가 동작하지 않음** — Claude Code를 재시작하고 `rtk gain`으로 명령어가 프록시되는지 확인하세요.
- **저장소가 업데이트되지 않음** — `setup.sh`는 로컬 변경이 있거나 태스크 브랜치에 있는 저장소는 건드리지 않습니다. 깨끗한 기본 브랜치 체크아웃만 fast-forward합니다.
- **setup.sh가 아무것도 묻지 않고 바로 "edit devrig.toml first"라고 실패함** — 대화식 터미널에 연결된 경우에만 프롬프트가 나타납니다. 스크립트나 CI에서 실행하면 `devrig.toml`이 이미 채워져 있어야 합니다.
- **Jira나 "기타"를 선택함** — `atlassian`(Jira) MCP 서버는 자동으로 설정되지만, `/start-task`, `/raise-pr`, `/create-ticket`은 여전히 Linear의 MCP 도구 이름을 호출합니다 — 이 스킬들을 조정하기 전까지 `setup.sh`는 매 실행 끝에 이를 경고합니다.

## 기여하기

devrig는 사용하는 팀이 늘수록 좋아집니다. 버그 리포트, 새로운 범용 스킬,
문서 개선, 그리고 **README 번역**을 환영합니다 —
[CONTRIBUTING.md](../CONTRIBUTING.md)를 확인하세요. devrig가 팀의 셋업
시간을 아껴줬다면 ⭐ 하나가 다른 사람들의 발견을 돕습니다.

## 라이선스와 인용

[MIT 라이선스](../LICENSE)로 배포됩니다.

작업물이나 저술에 devrig를 사용하셨다면 인용해 주시면 감사하겠습니다 —
GitHub의 **"Cite this repository"** 버튼([`CITATION.cff`](../CITATION.cff)
기반)에 상세 정보가 있습니다. 또는:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>프로덕션 멀티 레포 워크스페이스에서 탄생 · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
