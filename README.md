English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

# Antigravity Minimal Coder (`minimal-coder`)

A minimal custom main agent for official Google Antigravity (tested on `44.9.1` / App `2.31.2`), designed to provide a Codex-lean system prompt experience. By enabling `excludeDefaultComponents: true` and a minimal tool allowlist, it strips bloated default prompt sections while keeping Artifact plan review, code quality self-review, project rule loading, and dynamic subagents.

> This configuration uses only Antigravity's official custom agent mechanism—no binary patching, no client spoofing, no prompt cloaking, and no unofficial harnesses.

---

## Available Language Presets

- **English**: [agents/en/minimal-coder/agent.md](agents/en/minimal-coder/agent.md)
- **简体中文**: [agents/zh-CN/minimal-coder/agent.md](agents/zh-CN/minimal-coder/agent.md)
- **繁體中文**: [agents/zh-TW/minimal-coder/agent.md](agents/zh-TW/minimal-coder/agent.md)

---

## Problem Solved & Design Trade-offs

Antigravity's default main agent injects large prompt sections (`<artifacts>` formatting manuals, `<featured_plugins>`, `<skills>`, `<slash_commands>`, built-in `<subagents>`, MCP schemas, and verbose policies) on every new session, adding token overhead and noise for pure coding workflows.

`minimal-coder` configures `agent.md` with:

- `mainAgent: true`: Registers `minimal-coder` in the chat composer's agent switcher.
- `excludeDefaultComponents: true`: Drops default system prompt components and built-in subagent registrations.
- `inheritMcp: false`: Excludes external MCP server tool definitions to minimize tool clutter.
- **Minimal tool allowlist** (`9` declared tools, `10` exposed at runtime because `run_command` automatically pairs with `manage_task`):
  - File I/O & Execution: `read_file`, `edit_file`, `write_file`, `run_command` (`manage_task` auto-added)
  - Web Lookup: `search_web`
  - Dynamic Subagents: `define_subagent`, `invoke_subagent`, `manage_subagents`, `send_message`

### Preserved Workflows Without Bloat

- **Artifact Plan Review (`Proceed` button)**: When tasks involve architectural trade-offs, material ambiguity, or high-risk changes (clear routine tasks execute straight through even across files), writes `implementation_plan.md` under `brain/<conversation-id>/` with `ArtifactMetadata` (`UserFacing: true`, `RequestFeedback: true`), surfacing the `Proceed` button in the UI before edits begin.
- **`<code_quality>` & Pre-Delivery `git diff` Review**: Preserves senior-reviewer standards (deduplication, small functions & shallow nesting, table-driven variants, local refactors), checking `git diff` directly for routine edits and optionally spawning a read-only subagent review for complex or large-scale changes.
- **Step Commentary (Codex-Style Progress Narration)**: Emits 1–2 concise sentences alongside multi-step tool batches stating newly confirmed clues and the next inspection, edit, or verification target so the reasoning trajectory stays visible inside `Worked for ...` without pausing execution.
- **On-Demand Project Rules**: Checks and reads `AGENTS.md` / `GEMINI.md` at the workspace root and target directory before editing.
- **Customizable `# Global Agent Baseline`**: Ships a built-in engineering baseline directly inside `agent.md` so you can freely adapt or replace it.

---

## Quick Install & Uninstall

### Option 1: Global Install (Recommended, All Workspaces)

- **Windows**: Double-click `install.bat` to pick a language interactively, or pass a language argument directly:

  ```bat
  install.bat en
  install.bat zh-CN
  install.bat zh-TW
  ```

  To uninstall, run `uninstall.bat`.

- **macOS / Linux**: Run `./install.sh` (interactive prompt in TTY; defaults to `en` when non-interactive) or pass the language explicitly:

  ```sh
  ./install.sh en
  ./install.sh zh-CN
  ./install.sh zh-TW
  ```

  To uninstall, run `./uninstall.sh`.

Both installers copy the selected `agent.md` to `~/.gemini/config/agents/minimal-coder/agent.md` (`%USERPROFILE%\.gemini\config\agents\minimal-coder\agent.md` on Windows). Start a new chat (or reload the window) and select `minimal-coder` in the bottom-left agent menu.

### Option 2: Workspace-Local Install (Team Sharing)

Copy the `minimal-coder` directory from your chosen language preset into your repository:

```text
<repo>/.agents/agents/minimal-coder/agent.md
```

---

## Observed Behavior & Caveats

Verified on Antigravity `44.9.1` (App `2.31.2`):

1. **`excludeDefaultComponents: true` disables auto-discovery and built-in subagents**
   - Antigravity will not auto-inject `~/.gemini/config/AGENTS.md` or workspace `AGENTS.md`, and built-in subagents (`self`, `research`, `browser`, `image-generator`) are omitted.
   - `minimal-coder` compensates by embedding `# Global Agent Baseline` in `agent.md` and explicitly reading root/directory `AGENTS.md` or `GEMINI.md` on demand.
2. **Subagent `EnableWriteTools` boundary**
   - Subagents created via `define_subagent` with `EnableWriteTools: false` receive only `read_file` and `search_web` (no directory listing or command runner).
   - Therefore, read-only inspection or `git diff` review subagents use `EnableWriteTools: true` with strict prompt instructions forbidding edits.
3. **Difference from Codex client permission layer**
   - `agent.md` controls model prompts and exposed tools only; it does not replace Antigravity App's client-side `Local Permissions: Auto` logic (such as Codex's semantic command auto-approval agent). Command interception requires pairing with `hooks.json` (`PreToolUse`) or client allowlists, which are outside this single-file preset.

---

## Customization

- **Edit `# Global Agent Baseline`**: Modify lines `19`–`64` in `agent.md`, or paste your existing `~/.gemini/config/AGENTS.md` rules there.
- **Re-enable MCP tools**: Change `inheritMcp: false` to `true` in frontmatter, or append extra tool names under `tools:`.

---

## Repository Layout

```text
antigravity-minimal-coder/
├─ agents/
│  ├─ en/minimal-coder/agent.md      # English preset
│  ├─ zh-CN/minimal-coder/agent.md   # Simplified Chinese preset
│  └─ zh-TW/minimal-coder/agent.md   # Traditional Chinese preset
├─ install.bat                       # Windows global installer
├─ uninstall.bat                     # Windows uninstaller
├─ install.sh                        # macOS / Linux global installer
├─ uninstall.sh                      # macOS / Linux uninstaller
├─ .gitattributes
├─ .gitignore
├─ LICENSE                           # MIT License
├─ README.md                         # English documentation
├─ README.zh-CN.md                   # Simplified Chinese documentation
└─ README.zh-TW.md                   # Traditional Chinese documentation
```
