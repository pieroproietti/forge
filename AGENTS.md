# AGENTS.md — Piero Proietti's Development Environment
> This file is in ~/AGENTS.md and provides global context for AI agents
> working across all three repositories in this workspace.

## Author
- **Name:** Piero Proietti (artisan)
- **GitHub:** https://github.com/pieroproietti
- **Web:** https://penguins-eggs.net

---

## Workspace Layout

```
~/
├── oa-tools/        # Next-generation remastering engine (C + Go)
├── oa-wardrobe/     # Costumes (YAML) + scripts consumed by coa wardrobe
├── penguins-eggs/   # Stable production remastering tool (TypeScript)
└── penguins-blog/   # Official website (Docusaurus)
```

---

## Repositories

### oa-tools — Next Generation (active development)
- **Path:** ~/oa-tools
- **GitHub:** https://github.com/pieroproietti/oa-tools
- **Languages:** C (engine `oa`) + Go (orchestrator `coa`)
- **Purpose:** High-performance successor to penguins-eggs. Generates fully
  bootable hybrid ISOs (UEFI + BIOS) for Alpine, Arch, Debian, Fedora,
  Manjaro, openSUSE and derivatives.
- **Key docs:**
  - https://github.com/pieroproietti/oa-tools/blob/main/AGENTS.md
  - https://github.com/pieroproietti/oa-tools/blob/main/AI-CONTEXT.md
  - https://github.com/pieroproietti/oa-tools/blob/main/DOCS/COA.md
  - https://github.com/pieroproietti/oa-tools/blob/main/DOCS/COA_ARCHITECTURE.md
  - https://github.com/pieroproietti/oa-tools/blob/main/DOCS/COA_UNIVERSAL_STRATEGY.md

### oa-wardrobe — Costumes for coa (data repository)
- **Path:** ~/oa-wardrobe
- **GitHub:** https://github.com/pieroproietti/oa-wardrobe
- **Content:** YAML + bash only — no compiled code.
- **Purpose:** Declarative "costumes" used by `coa wardrobe wear` to dress
  a minimal CLI system ("naked") into a complete system: packages,
  filesystem overlay (`sysroot/`), post-install commands.
- **Consumed by:** `coa wardrobe get|list|show|wear` — parser lives in
  `~/oa-tools/coa/pkg/tailor/` (struct `Suit`). `get` clones the repo
  to `~/.oa-wardrobe`.
- **Current costumes:** albatros, chicks, colibri, duck, eagle, gypaetus,
  owl, seagull.
- **Status:** format migration in progress — only `colibri` uses the new
  flat `index.yaml` schema; the others still carry the legacy
  `sequence/finalize` format that the new parser ignores.
- **Key docs:**
  - `~/oa-wardrobe/AGENTS.md` (format spec, transition notes, conventions)
  - https://oa-tools.net/docs/Tutorial/wardrobe-users-guide (outdated, old format)

### penguins-eggs — Stable Production (maintained)
- **Path:** ~/penguins-eggs
- **GitHub:** https://github.com/pieroproietti/penguins-eggs
- **Language:** TypeScript (Node.js + oclif)
- **Purpose:** Battle-tested remastering tool, 500+ stars. Will continue
  to be maintained as the reference tool for historical and legacy
  distributions. NOT abandoned — complementary to oa-tools.
- **Key docs:**
  - https://penguins-eggs.net/docs/Tutorial/eggs-users-guide
  - https://penguins-eggs.net/docs/Tutorial/eggs-5-minutes
  - https://github.com/pieroproietti/penguins-eggs/blob/master/CHANGELOG.md

### penguins-blog — Official Website
- **Path:** ~/penguins-blog
- **GitHub:** https://github.com/pieroproietti/penguins-blog
- **Stack:** Docusaurus (React/Node.js)
- **Purpose:** Official documentation and blog for penguins-eggs and oa-tools.
  Served at https://penguins-eggs.net
- **Key convention:** Static files go in `static/` to be served at root
  (e.g. `static/llms.txt` → `penguins-eggs.net/llms.txt`)

---

## Relationship Between Projects

```
penguins-eggs (TypeScript, stable)
    └── successor → oa-tools (C + Go, next-gen)
                         ├── uses costumes from → oa-wardrobe (YAML + bash)
                         └── documented on → penguins-blog (Docusaurus)
```

- **oa-tools** and **penguins-eggs** have a strict package conflict —
  they cannot be installed on the same system simultaneously.
- **penguins-eggs** remains the recommended tool for production and
  legacy distributions.
- **oa-tools** is recommended for performance, cutting-edge use, and
  contributing to the future of Linux remastering.

---

## Common Tasks Across Repos

### Update website after oa-tools changes
1. Edit docs in `~/penguins-blog/docs/` or `~/penguins-blog/blog/`
2. Test locally: `cd ~/penguins-blog && npm start`
3. Commit and push — CI deploys automatically

### Keep llms.txt in sync
- Source of truth: `~/penguins-blog/static/llms.txt`
- Served at: https://penguins-eggs.net/llms.txt
- Update when: new oa-tools features, new docs, new supported distros

### Cross-repo changelog
- penguins-eggs changelog: `~/penguins-eggs/CHANGELOG.md`
- oa-tools releases: via GitHub releases and `coa version`

---

## AI Agent Rules

1. **Never mix** oa-tools and penguins-eggs CLI commands — `coa` is oa-tools,
   `eggs` is penguins-eggs. They are separate tools.
2. **Read repo-specific AGENTS.md** before working inside `~/oa-tools/` —
   it contains strict coding style rules (logging, exec wrappers, etc.) —
   and inside `~/oa-wardrobe/` — it documents the current `index.yaml`
   schema and the ongoing format migration.
3. **Never install both** oa-tools and penguins-eggs on the same system.
4. **Docusaurus conventions** apply inside `~/penguins-blog/` —
   static assets in `static/`, docs in `docs/`, blog posts in `blog/`.
5. For oa-tools Go code, always use `utils.LogNormal/Success/Warning/Error`
   and `utils.Exec/ExecQuiet/ExecCapture` — never raw fmt or exec.Command.
