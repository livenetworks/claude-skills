# Claude Skills — Live Networks

Centralized skill definitions for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
Single source of truth across all Live Networks projects.

## Skills

| Folder | Skill Name | Description |
|--------|-----------|-------------|
| `architecture/` | architecture | Software architecture decisions and patterns |
| `css/` | css | Token-driven SCSS/CSS architecture with ln-acme |
| `database/` | database | Database design, queries, and optimization |
| `html/` | html | Semantic, accessible HTML markup with ln-acme |
| `js/` | js | Vanilla JS, IIFE, event-driven components with ln-acme |
| `laravel/` | laravel | Laravel conventions, LN-Starter patterns |
| `ui/` | ui-designer | UI/visual layout and information presentation |
| `ux/` | ux-designer | Interaction flow and user journey decisions |

## Setup (per project)

### Option A: PowerShell script (recommended)

Copy `setup-skills.ps1` to your project root and run:

```powershell
.\setup-skills.ps1
```

### Option B: Manual

```bash
git submodule add -b main https://github.com/livenetworks/claude-skills.git .claude/skills
git commit -m "Add claude-skills submodule"
```

## Updating skills in a project

```powershell
# Quick update
.\setup-skills.ps1

# Or manually
cd .claude/skills
git pull origin main
cd ../..
git add .claude/skills
git commit -m "Update claude-skills"
```

## Editing a skill

Edit from **any project** that has the submodule:

```bash
cd .claude/skills
# edit the skill you need, e.g. css/SKILL.md
git add -A
git commit -m "Update css: add grid token examples"
git push origin main
```

Then update other projects with `.\setup-skills.ps1`.

## Adding supporting files to a skill

The folder convention allows each skill to grow beyond a single SKILL.md:

```
css/
├── SKILL.md              ← main skill (required)
├── tokens-reference.md   ← additional reference
└── examples/
    └── form-grid.scss    ← code examples
```

Claude Code reads all `.md` files in the skill folder.

## Cloning a project that uses this

```bash
git clone --recurse-submodules <project-url>

# Or if already cloned without --recurse-submodules:
git submodule update --init --recursive
```

## Structure

```
claude-skills/
├── README.md
├── setup-skills.ps1
├── architecture/
│   └── SKILL.md
├── css/
│   └── SKILL.md
├── database/
│   └── SKILL.md
├── html/
│   └── SKILL.md
├── js/
│   └── SKILL.md
├── laravel/
│   └── SKILL.md
├── ui/
│   └── SKILL.md
└── ux/
    └── SKILL.md
```

## License

Proprietary — Live Networks DOOEL
