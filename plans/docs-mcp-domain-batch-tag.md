# Plan: docs-mcp — batch `domain:` дотагирање + запис на one-server одлуката

Markdown-only задача. НЕМА build, НЕМА git, НЕ се менува ништо надвор од наведените фајлови.
Табови за индентација не се релевантни (YAML frontmatter + markdown проза).

## Контекст

Одлука 2026-07-11: еден MCP сервер, N федерирани корпус-корени — НЕ одвоени сервери по стек.
Сепарацијата ја носат frontmatter оските `domain:` и `context:`. Постоечкиот корпус се потпираше
на „отсутно поле = frontend" — сега се дотагира експлицитно (корпусот е мал, 14 документи),
а default-правилото останува во контрактот за идни корени.

## T1 — вметни `domain: frontend` во 14 индексирани документи

Во YAML frontmatter блокот (меѓу `---` линиите), вметни нова линија **точно `domain: frontend`**
непосредно ПО линијата `status: ...`. Ако некој фајл нема `status:` линија — вметни по
`classification: ...` и пријави ја аномалијата во извештајот. Ако фајлот ВЕЌЕ има `domain:`
линија — не менувај ништо, пријави.

Фајлови (14):

- docs-mcp/doctrine/mindset.md
- docs-mcp/doctrine/data-flow.md
- docs-mcp/doctrine/js-component-model.md
- docs-mcp/doctrine/data-layer.md
- docs-mcp/doctrine/scss-architecture.md
- docs-mcp/doctrine/html-markup-rules.md
- docs-mcp/guides/write-workflow.md
- docs-mcp/guides/spa-routing.md
- docs-mcp/guides/coordinator-authoring.md
- docs-mcp/guides/getting-started.md
- docs-mcp/guides/component-authoring.md
- docs-mcp/components/ln-toggle.md
- docs-mcp/components/ln-accordion.md
- docs-mcp/components/ln-dropdown.md

НЕ додавај `context:` — тоа поле е само за skills/ засега.

## T2 — исто за 4 темплејти

Истото правило (`domain: frontend` по `status:` линијата) во:

- docs-mcp/_templates/component.md
- docs-mcp/_templates/css.md
- docs-mcp/_templates/pattern.md
- docs-mcp/_templates/guide.md

`_templates/skill.md` ВЕЌЕ го има — не го допирај. НЕ додавај `context:` во овие четири.

## T3 — docs-mcp/refactor-todo.md §3 (два edit-а, точен текст)

**Edit A** — замени ја постоечката линија:

```
- **`domain:` frontmatter поле** (`frontend` | `backend` | `process`) — филтрирање по домен; отсутно поле = `frontend` (постоечкиот корпус е имплицитно frontend до batch дотагирање).
```

со:

```
- **`domain:` frontmatter поле** (`frontend` | `backend` | `process`) — филтрирање по домен; отсутно поле = `frontend` (правилото останува во контрактот за идни корени; постоечкиот ashlar корпус е експлицитно дотагиран 2026-07-11).
```

**Edit B** — непосредно ПО bullet-от што почнува со `- **Повеќе корпус-корени**` (и пред bullet-от `- **Отворено (серверска одлука):**`) вметни нов bullet:

```
- **Еден сервер, N корпуси (одлука 2026-07-11):** НЕ се прават одвоени MCP сервери по стек (ashlar / laravel / node / wordpress) — сепарацијата ја носат `domain:`/`context:` оските и config-низата корени. Кога ќе се појави потреба (тим што работи само еден стек), сервирањето добива per-client/per-project профили (scoping по domain/context). Профилот НЕ го укинува тврдото правило: никогаш два context-а во еден сервиран сет.
```

## T4 — docs-mcp/mcp-todo.md, секција «Идни корпуси» (два edit-а)

**Edit A** — замени ја линијата (bullet «frontend»):

```
- **frontend** — овој корпус (`ln-ashlar\docs-mcp\`); постоечките документи се имплицитно `domain: frontend` до batch дотагирање.
```

со:

```
- **frontend** — овој корпус (`ln-ashlar\docs-mcp\`); сите постоечки документи носат експлицитно `domain: frontend` (batch дотагирано 2026-07-11).
```

**Edit B** — на КРАЈОТ од секцијата `## Идни корпуси` (по последниот параграф — оној што почнува со «Крајна насока»), а ПРЕД `---` сепараторот што му претходи на `## Прогрес`, вметни нов параграф (со празна линија пред и по):

```
**Еден сервер, N корпуси (одлука 2026-07-11):** федерацијата е на корпусите, не на серверите — НЕ се прават одвоени MCP сервери по стек (ashlar / laravel / node / wordpress). Еден сервер чита N корени; сепарацијата е преку `domain:`/`context:`. Идна потреба: per-client/per-project serving профили (тим што работи само еден стек) — профилот никогаш не меша два context-а во еден сет.
```

## Acceptance criteria (задолжителни проверки пред PASS)

1. `grep -l "^domain: frontend"` во docs-mcp/doctrine/, guides/, components/ → точно 14 фајлови.
2. Секој од тие 14 има ТОЧНО една `^domain:` линија (никаде дупликат).
3. Четирите темплејти (component, css, pattern, guide) содржат `^domain: frontend`; skill.md останат непроменет (сè уште точно една `domain:` линија).
4. `domain:` линијата е ВНАТРЕ во frontmatter блокот (пред второто `---`) кај сите 18 фајлови.
5. refactor-todo.md содржи „Еден сервер, N корпуси" и „профили"; старата фраза „имплицитно frontend до batch дотагирање" ја нема.
6. mcp-todo.md содржи „Еден сервер, N корпуси" и „batch дотагирано 2026-07-11"; новиот параграф е ПРЕД `## Прогрес`.
7. НИКАДЕ не е додадено `context:` освен каде што веќе постоеше (skill.md, README.md).

## Извештај

Врати: PASS/FAIL по задача (T1-T4), листа аномалии (ако има), излез од acceptance проверките.
НЕ враќај содржина на фајловите.
