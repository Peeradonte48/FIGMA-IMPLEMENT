# Figma Implement — Claude Code skill suite

A portable, **stack-agnostic** set of [Claude Code](https://claude.com/claude-code) skills that turn Figma and FigJam into code. They detect and conform to whatever project you run them against — no hardcoded framework, design system, or domain. Every skill follows one rule: **clarify until clear** — it stops and asks rather than inventing a missing detail.

This repo is a **skill-only scaffold**. There is no application code, no build step, and nothing to compile — just the skills under [`skills/`](skills/) and an installer.

---

## The skills

The suite forms a **FigJam → narrative → prototype** pipeline, plus one standalone **design → code** path.

| Skill | Direction | What it does |
|-------|-----------|--------------|
| **[implement-figma-design](skills/implement-figma-design/SKILL.md)** | design → code | Transcribes a finished Figma frame into a 1:1, pixel-perfect build in your codebase, then verifies by diffing a screenshot of the running UI against the Figma reference. Use when someone shares a `figma.com` link and wants it built. *(Web/React path.)* |
| **[figjam-to-use-case-narrative](skills/figjam-to-use-case-narrative/SKILL.md)** | FigJam → narrative *(step 1)* | Reads a user-flow diagram from FigJam and writes a structured **use-case-narrative (UCN)** markdown doc. Read-only; never edits the board. |
| **[use-case-narrative-to-prototype](skills/use-case-narrative-to-prototype/SKILL.md)** | narrative → code *(step 3)* | Turns a UCN doc into a walkable, clickable code prototype (behavioral fidelity, not pixel fidelity; React by default, stack-aware). |

**Pipeline at a glance:**

```
  FigJam flow  ──▶  figjam-to-use-case-narrative  ──▶  UCN.md  ──▶  use-case-narrative-to-prototype  ──▶  clickable prototype
  Figma frame  ──▶  implement-figma-design  ──▶  pixel-perfect build (standalone)
```

> `implement-figma-design` is the pixel-fidelity path; `use-case-narrative-to-prototype` is the behavior-fidelity path. When a finished design exists and you need 1:1 accuracy, reach for the former.

---

## Requirements

- **Claude Code** (CLI, desktop, or IDE extension).
- The **Figma MCP server** connected, so the skills can read from Figma/FigJam. The skills use the read tools `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, and `get_figjam`. See Figma's [MCP / Dev Mode docs](https://www.figma.com/) to connect it.
- For screenshot-based verification in `implement-figma-design`: any browser/screenshot tooling available in your project (e.g. Playwright).

---

## Install

### Option A — one-liner (no clone)

```bash
curl -fsSL https://raw.githubusercontent.com/Peeradonte48/FIGMA-IMPLEMENT/main/install.sh | bash
```

Installs all three skills into your user skills directory, `~/.claude/skills/`.

### Option B — clone and run the installer

```bash
git clone https://github.com/Peeradonte48/FIGMA-IMPLEMENT.git
cd FIGMA-IMPLEMENT
./install.sh                 # user-level   → ~/.claude/skills
./install.sh --project       # project-only → ./.claude/skills (run from your project root)
./install.sh --dir <path>    # custom skills directory
./install.sh --force         # overwrite existing copies without prompting
./install.sh --uninstall     # remove the three skills
```

### Option C — copy by hand

Each skill is a self-contained folder. Copy the three directories under [`skills/`](skills/) into any skills directory Claude Code reads:

```bash
cp -R skills/* ~/.claude/skills/        # user-level
# or, per project:
cp -R skills/* /path/to/project/.claude/skills/
```

After installing, restart Claude Code (or run `/doctor`) so it discovers the new skills.

**User-level vs project-level:** install to `~/.claude/skills` to use the skills in every project; install to a project's `.claude/skills` to scope them to that repo (and commit them with the project).

---

## Usage

Once installed, the skills trigger automatically from natural language — you generally don't need to name them:

- **Build a Figma design:**
  > "Implement this frame: `https://figma.com/design/…?node-id=…`"
  → `implement-figma-design`

- **Document a FigJam flow:**
  > "Turn this FigJam flow into a use-case narrative: `https://figma.com/board/…`"
  → `figjam-to-use-case-narrative`

- **Prototype from a narrative:**
  > "Build a clickable prototype from `docs/flows/checkout.ucn.md`"
  → `use-case-narrative-to-prototype`

You can also invoke a skill explicitly by name, e.g. *"use the use-case-narrative-to-prototype skill on …"*.

### End-to-end pipeline example

```text
1.  "Document this FigJam flow → UCN"        →  figjam-to-use-case-narrative  →  checkout.ucn.md
2.  (review/edit the UCN doc)
3.  "Prototype checkout.ucn.md"              →  use-case-narrative-to-prototype  →  walkable screens
```

---

## How the skills are structured

```
skills/
├── implement-figma-design/
│   └── SKILL.md
├── figjam-to-use-case-narrative/
│   ├── SKILL.md
│   └── references/
│       ├── figjam-mapping.md                # FigJam primitive → UCN section mapping
│       └── use-case-narrative-format.md     # canonical UCN template (shared contract)
└── use-case-narrative-to-prototype/
    ├── SKILL.md
    └── references/
        ├── prototype-mapping.md             # UCN section → prototype element mapping
        └── use-case-narrative-format.md     # identical copy of the UCN template
```

> **Shared format contract:** the two `references/use-case-narrative-format.md` files are byte-identical on purpose — one skill writes the format, the other reads it. **If you edit one, edit the other to match.**

---

## Contributing / editing the skills

Keep these conventions (see [`CLAUDE.md`](CLAUDE.md) for the full list):

- **Stay stack-agnostic.** Skills detect the target project's framework, file layout, components, styling, and token system and conform to them. Don't bake in a specific stack, design system, or domain.
- **Honor the target project's own conventions** (token systems, accessibility/ergonomics rules) — and surface a conflict rather than silently shipping something that breaks a rule.
- **Reuse over reinvention; match every breakpoint.** A match at one width that breaks at another is not a match.
- **Clarify until clear.** A wrong guess that looks right silently corrupts the spec — don't proceed past an unresolved ambiguity.
- **Keep the two UCN format copies in sync.**

---

## License

MIT — see [`LICENSE`](LICENSE).
