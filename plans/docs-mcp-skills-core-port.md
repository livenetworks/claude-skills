# Plan: docs-mcp/skills/ — порт на 4-те core skill документи (Фаза 6, јадро)

Авторска задача (порт + адаптација + grounding), НЕ blind copy. НЕМА build, НЕМА git.
Изворите во `.claude/skills/` НЕ СЕ МЕНУВААТ (thin-pointer конверзијата е ПО целосна Фаза 6, не сега).

## Документи (извор → цел)

| Извор | Цел | Белешка |
|---|---|---|
| `.claude/skills/ux/SKILL.md` | `docs-mcp/skills/ux.md` | ревјуиран извор |
| `.claude/skills/ux/interaction-patterns.md` | `docs-mcp/skills/ux-interaction-patterns.md` | ⚠ НЕПРЕГЛЕДАН извор — оди со ревју (види подолу) |
| `.claude/skills/ui/SKILL.md` | `docs-mcp/skills/ui.md` | ревјуиран извор |
| `.claude/skills/ui/visual-language.md` | `docs-mcp/skills/ui-visual-language.md` | |

`ui/components/*.md` (data-table, form, modal...) НЕ се портираат сега — тие се спарени со Фаза 3/4 (види mcp-todo Фаза 6). Ако `ui/SKILL.md` линкува кон нив, линкот во портот станува релативен кон ИДНИТЕ `./ui-<name>.md` документи (dangling дозволено).

## Контракт (задолжително пред авторирање)

Прочитај ги: `docs-mcp/_templates/skill.md` (темплејт + конвенции), `docs-mcp/README.md` (frontmatter контракт), и еден постоечки документ за тон (`docs-mcp/doctrine/mindset.md`).

Секој од 4-те документи:

- Frontmatter: `name:` == filename без .md, `classification: skill`, `status: draft`, `domain: frontend`, `context: app`, `summary:` (една реченица, англиски), `source:` = патеката на изворот во `.claude/skills/`, `tags:` непразно.
- `# [emoji] Наслов` па `## Summary` како ПРВА секција (2-3 реченици — кои одлуки ги владее документот и кога агент да го консултира).
- Содржина на АНГЛИСКИ (изворите се веќе англиски — се пренесува со адаптација).
- Релативни крос-линкови: меѓу skills (`./ux.md` ↔ `./ui.md`), кон doctrine (`../doctrine/mindset.md`, `../doctrine/html-markup-rules.md`...), кон components/patterns каде што правило именува компонента (`../components/ln-toggle.md`; dangling кон планирани документи е ДОЗВОЛЕНО — пр. `../components/ln-table.md`, `../patterns/modal-crud.md`). Минимум 3 крос-линка по документ.

## Порт-правила (од mcp-todo Фаза 6)

1. **`## Identity` секциите СЕ ОТСТРАНУВААТ.** Никаква персона-нарација („You are a senior designer..."). Персоната е промпт-слој на MCP серверот.
2. **Scope-квалификаторите СЕ ЗАЧУВУВААТ дословно.** „never **in data tools**" останува scoped — НЕ се генерализира во „never". Идните `context: web` skills носат спротивни правила по дизајн.
3. **Decision tables пред проза.** Изворните табели се пренесуваат; „except in some situations" без набројана листа е забрането — ако изворот има таква формулација, набројај ги исклучоците од контекстот на изворот или означи ја точката за ревју во извештајот.
4. **Ground every claim.** Секое правило што именува компонента/атрибут/настан → провери во кодот (`js/`, `scss/`, `demo/`):
   - постои → релативен линк кон соодветниот док (dangling кон планиран док е ОК),
   - НЕ постои → правилото ОСТАНУВА како дизајн-барање, но се означува експлицитно со `*(aspirational — not yet supported by the library)*`. НЕ бриши правила, НЕ измислувај замени.
   - Именува API што не постои (пр. измислен настан/компонента) → преформулирај library-агностички + aspirational ознака.

## Познати сомнителни тврдења (задолжителна verdict-табела во извештајот)

За секое: grep во `js/` и/или `scss/`, врати verdict (постои со file:line / не постои → aspirational):

1. **`ln-validate`** — постои ли воопшто како компонента? (grep `js/`)
2. **focus-trap / ESC во modal** — што од тоа е рачно имплементирано во `js/ln-modal/src/ln-modal.js` сега? (Внимание: native `<dialog>` миграцијата е ИДЕН рефактор — `docs-mcp/refactor-todo.md` §5. Документирај ја СЕГАШНАТА состојба; не го документирај `<dialog>` однесувањето како тековно.)
3. **virtual scroll** — постои ли (ln-list? ln-table?) — grep `virtual` во `js/`
4. **delta sync** — постои ли такво однесување во data слојот (`js/ln-data-store/`, `js/ln-data-coordinator/`) или е аспирација?
5. **reserved error space во форми** — резервираат ли form микс-ините простор за validation порака? (grep `scss/config/mixins/` — form/field mixins)

## Ревју на ux-interaction-patterns (непрегледан извор)

Изворот `.claude/skills/ux/interaction-patterns.md` никогаш не поминал ревју. При портирање:
- сè што противречи на doctrine документите (`docs-mcp/doctrine/*.md`) се ЗАДРЖУВА ВО ИЗВЕШТАЈОТ како наод, НЕ се портира тивко;
- непроверливи/нејасни правила → листа во извештајот со предлог (port as-is / aspirational / skip);
- ако нешто е скокнато при порт, кажи ШТО и ЗОШТО.

## mcp-todo ажурирање (по авторирањето)

Во `docs-mcp/mcp-todo.md`:
- Фаза 6 Јадро: четирите ставки `- [ ]` → `- [x]` (**ux**, **ux-interaction-patterns**, **ui**, **ui-visual-language**)
- Прогрес табела: ред `| skills | 13 | 0 |` → `| skills | 13 | 4 |`; ред `| **Вкупно** | **108** | **12** |` → `| **Вкупно** | **108** | **16** |`

## Acceptance criteria (задолжителни проверки пред PASS)

1. `docs-mcp/skills/` содржи ТОЧНО 4 фајла: ux.md, ux-interaction-patterns.md, ui.md, ui-visual-language.md.
2. Секој има валиден frontmatter (сите 8 полиња, name==filename, `classification: skill`, `domain: frontend`, `context: app`, `status: draft`).
3. `## Summary` е прва секција по H1 во сите 4.
4. Нула појави на `## Identity`, „You are a senior", „You are an expert" во skills/.
5. Grep „in data tools" во skills/ — scope-квалификаторите присутни (ако ги имало во изворите).
6. Секој документ има ≥3 релативни markdown линкови (`](./` или `](../`).
7. Verdict-табелата за 5-те сомнителни тврдења е комплетна, со file:line за постоечките.
8. `.claude/skills/**` непроменето (git status или диф не покажува промени таму — провери со `git status --porcelain .claude/skills/` САМО читање, без stage/commit).
9. mcp-todo: 4-те checkbox-а штиклирани, прогресот 4/16 внесен.
10. Никаде `context:` ≠ `app` и никаде без `context:` во skills/.

## Извештај

PASS/FAIL по документ; verdict-табела (5 тврдења + било кое друго ungrounded најдено); листа aspirational ознаки по документ; ревју-наоди за ux-interaction-patterns; список скокнати делови со причина. НЕ враќај цела содржина на документите.
