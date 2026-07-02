# AGENTS.md — Piero Proietti's Development Environment
> This file is in ~/AGENTS.md and provides global context for AI agents
> working across the five repositories in this workspace.

## Author
- **Name:** Piero Proietti (artisan)
- **GitHub:** https://github.com/pieroproietti
- **Web:** https://penguins-eggs.net

---

## Workspace Layout

```
~/
├── fresh-eggs/      # Installer/configurator scripts for penguins-eggs and penguins-eggs-legacy)
├── penguins-eggs/   # Next-generation remastering engine (C + Go)
├── penguins-eggs-legacy/   # Stable production remastering tool (TypeScript)
└── penguins-blog/   # Official website (Docusaurus)
```

---

## Repositories

### penguins-eggs 
- **Path:** ~/penguins-eggs
- **GitHub:** https://github.com/pieroproietti/penguins-eggs
- **Languages:** C (engine `oa`) + Go (orchestrator `coa`)
- **Purpose:** High-performance successor to penguins-eggs. Generates fully
  bootable hybrid ISOs (UEFI + BIOS) for Alpine, Arch, Debian, Fedora,
  Manjaro, openSUSE and derivatives.
- **Key docs:**
  - https://github.com/pieroproietti/penguins-eggs/blob/main/AGENTS.md
  - https://github.com/pieroproietti/penguins-eggs/blob/main/AI-CONTEXT.md
  - https://github.com/pieroproietti/penguins-eggs/blob/main/DOCS/COA.md
  - https://github.com/pieroproietti/penguins-eggs/blob/main/DOCS/COA_ARCHITECTURE.md
  - https://github.com/pieroproietti/penguins-eggs/blob/main/DOCS/COA_UNIVERSAL_STRATEGY.md

### oa-wardrobe — Costumes for coa (data repository)
- **Path:** ~/oa-wardrobe
- **GitHub:** https://github.com/pieroproietti/oa-wardrobe
- **Content:** YAML + bash only — no compiled code.
- **Purpose:** Declarative "costumes" used by `coa wardrobe wear` to dress
  a minimal CLI system ("naked") into a complete system: packages,
  filesystem overlay (`sysroot/`), post-install commands.
- **Consumed by:** `coa wardrobe get|list|show|wear` — parser lives in
  `~/penguins-eggs/coa/pkg/tailor/` (struct `Suit`). `get` clones the repo
  to `~/.oa-wardrobe`.
- **Current costumes:** albatros, chicks, colibri, duck, eagle, gypaetus,
  owl, seagull.
- **Status:** format migration in progress — only `colibri` uses the new
  flat `index.yaml` schema; the others still carry the legacy
  `sequence/finalize` format that the new parser ignores.
- **Key docs:**
  - `~/oa-wardrobe/AGENTS.md` (format spec, transition notes, conventions)
  - https://penguins-eggs.net/docs/Tutorial/wardrobe-users-guide (outdated, old format)

### penguins-eggs-legacy — Stable Production (maintained)
- **Path:** ~/penguins-eggs-legacy
- **GitHub:** https://github.com/pieroproietti/penguins-eggs-legacy
- **Language:** TypeScript (Node.js + oclif)
- **Purpose:** Battle-tested remastering tool, 500+ stars. Will continue
  to be maintained as the reference tool for historical and legacy
  distributions. NOT abandoned — complementary to penguins-eggs.
- **Key docs:**
  - https://penguins-eggs.net/docs/Tutorial/eggs-users-guide
  - https://penguins-eggs.net/docs/Tutorial/eggs-5-minutes
  - https://github.com/pieroproietti/penguins-eggs/blob/master/CHANGELOG.md

### fresh-eggs — Installer & Configurator (bash scripts)
- **Path:** ~/fresh-eggs
- **GitHub:** https://github.com/pieroproietti/fresh-eggs
- **Content:** bash scripts only — no compiled code.
- **Purpose:** Installs and configures penguins-eggs (and refreshes
  penguins-eggs) on AlmaLinux, AlpineLinux, Arch, Debian, Devuan, Fedora,
  Manjaro, Openmamba, openSUSE, RockyLinux, Ubuntu and most derivatives.
  Ensures Node.js >= 22.x (via nodesource if needed) and sets up the
  native repositories (penguins-eggs-repo, ppa, Chaotic-AUR).
- **Key scripts:** `fresh-eggs.sh` (main installer), `refresh.sh`
  (server-side: `basket|sourceforge`, both targets carry penguins-eggs
  + penguins-eggs; `refresh-basket.sh`/`refresh-sourceforge.sh` are wrappers),
  `ensure-node.sh`, `distros.yaml`
- **Key docs:**
  - https://github.com/pieroproietti/fresh-eggs/blob/main/README.md
  - https://github.com/pieroproietti/fresh-eggs/blob/main/SUPPORTED-DISTROS.md

### penguins-blog — Official Website
- **Path:** ~/penguins-blog
- **GitHub:** https://github.com/pieroproietti/penguins-blog
- **Stack:** Docusaurus (React/Node.js)
- **Purpose:** Official documentation and blog for penguins-eggs and penguins-eggs.
  Served at https://penguins-eggs.net
- **Key convention:** Static files go in `static/` to be served at root
  (e.g. `static/llms.txt` → `penguins-eggs.net/llms.txt`)

---

## Relationship Between Projects

```
penguins-eggs (TypeScript, stable)
    ├── installed/configured by → fresh-eggs (bash scripts)
    └── successor → penguins-eggs (C + Go, next-gen)
                         ├── uses costumes from → oa-wardrobe (YAML + bash)
                         ├── refreshed by → fresh-eggs (refresh-penguins-eggs.sh)
                         └── documented on → penguins-blog (Docusaurus)
```

- **penguins-eggs-legacy** and **penguins-eggs** have a strict package conflict —
  they cannot be installed on the same system simultaneously.
- **penguins-eggs** is the recommended tool for production
- **penguins-eggs-legacy** is recommended on legacy distributions.

---

## Common Tasks Across Repos

### Update website after penguins-eggs changes
1. Edit docs in `~/penguins-blog/docs/` or `~/penguins-blog/blog/`
2. Test locally: `cd ~/penguins-blog && npm start`
3. Commit and push — CI deploys automatically

### Keep llms.txt in sync
- Source of truth: `~/penguins-blog/static/llms.txt`
- Served at: https://penguins-eggs.net/llms.txt
- Update when: new penguins-eggs features, new docs, new supported distros

### Cross-repo changelog
- penguins-eggs releases: via GitHub releases and `coa version`
- penguins-eggs-legacy changelog: `~/penguins-eggs-legacy/CHANGELOG.md`

---

## AI Agent Rules

1. **Never mix** penguins-eggs and penguins-eggs CLI commands — `coa` is penguins-eggs,
   `eggs` is penguins-eggs. They are separate tools.
2. **Read repo-specific AGENTS.md** before working inside `~/penguins-eggs/` —
   it contains strict coding style rules (logging, exec wrappers, etc.) —
   and inside `~/oa-wardrobe/` — it documents the current `index.yaml`
   schema and the ongoing format migration.
3. **Never install both** penguins-eggs and penguins-eggs on the same system.
4. **Docusaurus conventions** apply inside `~/penguins-blog/` —
   static assets in `static/`, docs in `docs/`, blog posts in `blog/`.
5. For penguins-eggs Go code, always use `utils.LogNormal/Success/Warning/Error`
   and `utils.Exec/ExecQuiet/ExecCapture` — never raw fmt or exec.Command.
