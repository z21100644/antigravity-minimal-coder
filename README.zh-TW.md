[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

# Antigravity Minimal Coder (`minimal-coder`)

專為官方 Google Antigravity（已於 `44.9.1` / App `2.31.2` 實測）設計的極簡主代理（Custom Main Agent）設定，定位對齊 Codex 的精簡系統提示體驗：透過官方支援的 `excludeDefaultComponents: true` 與最小工具白名單，裁掉預設提示中冗長的非寫碼區塊，同時以極簡條款保留計畫審核、代碼品質複查、專案規則讀取與動態 Subagents。

> 本專案僅使用 Antigravity 官方支援的自訂代理機制，無二進位修補、無客戶端偽裝、無 Prompt 混淆或外掛破解。

---

## 多語言設定版本

- **English**：[agents/en/minimal-coder/agent.md](agents/en/minimal-coder/agent.md)
- **简体中文**：[agents/zh-CN/minimal-coder/agent.md](agents/zh-CN/minimal-coder/agent.md)
- **繁體中文**：[agents/zh-TW/minimal-coder/agent.md](agents/zh-TW/minimal-coder/agent.md)

---

## 解決的問題與設計取捨

Antigravity 預設主代理會注入大量系統段落（`<artifacts>` 詳細格式規範、`<featured_plugins>`、`<skills>` 列表、`<slash_commands>`、內建 `<subagents>` 說明、MCP 工具定義與各類長篇準則），在純寫碼情境下會消耗大量初始 context 並稀釋注意力。

`minimal-coder` 在 `agent.md` 中採用以下設定：

- `mainAgent: true`：註冊為對話輸入欄可切換的主代理。
- `excludeDefaultComponents: true`：移除 Antigravity 預設系統提示元件與內建子代理註冊。
- `inheritMcp: false`：不繼承外部 MCP server 工具定義，維持最低工具噪音。
- **精簡工具白名單**（宣告 `9` 項，實際注入 `10` 項；掛載 `run_command` 時後端會自動配對 `manage_task`）：
  - 讀寫與執行：`read_file`、`edit_file`、`write_file`、`run_command`（自動附帶 `manage_task`）
  - 聯網查證：`search_web`
  - 動態子代理：`define_subagent`、`invoke_subagent`、`manage_subagents`、`send_message`

### 在極簡前提下保留的核心工作流

- **Artifact 計畫審核（`Proceed` 按鈕）**：涉及架構取捨、需求存在實質歧義或高風險變更時（需求明確的常規跨檔任務直接推進完成），先在當前對話的 `brain/<conversation-id>/implementation_plan.md` 建立計畫並帶入 `ArtifactMetadata`（`UserFacing: true`、`RequestFeedback: true`），於 UI 呈現計畫卡片與 `Proceed` 按鈕，待確認後再實作。
- **`<code_quality>` 與交付前 `git diff` 複查**：保留去重、小函式與淺巢狀、mapping／table 統一處理變體、局部重構等資深審閱準則；常規修改直接自檢 `git diff`，複雜邏輯或大規模變更可派唯讀子代理獨立複查並於修正與複測後交付。
- **執行過程簡述（Codex 式步驟旁白）**：多步驟排查或修改時，於下一批工具呼叫同一輪附帶 1–2 句簡短說明（剛確認的線索 + 下一步目的），讓思考脈絡直接呈現在 `Worked for ...` 紀錄中且不中斷執行。
- **專案規則按需補讀**：動手修改特定目錄前，主動檢查並讀取工作區根目錄與目標目錄的 `AGENTS.md`／`GEMINI.md`。
- **可替換的 `# Global Agent Baseline`**：內建完整工程與回應規範段落，可視個人習慣直接修改或替換。

---

## 前置環境建議

由於 `minimal-coder` 移除了內建搜尋／網頁封裝工具，並引導模型在 `run_command` 中優先使用 `git`（`git grep`、`git ls-files`、`git diff`）、[`ripgrep`](https://github.com/BurntSushi/ripgrep)（`rg`）以及 `python` 或 `curl`（讀取指定 URL），建議預先確保這些工具已在系統 `PATH` 中，避免（尤其是預設未裝 `rg` 與 Python 的 Windows 環境）模型第一輪呼叫就撞上 `CommandNotFound` 而白費一次往返 fallback：

- **安裝 `ripgrep`（`rg`）**：
  - Windows：`winget install BurntSushi.ripgrep.MSVC`
  - macOS：`brew install ripgrep`
  - Debian / Ubuntu：`sudo apt install ripgrep`
- **Windows 環境排錯細節**：
  - **安裝後重啟 Antigravity**：例如透過 `winget install BurntSushi.ripgrep.MSVC` 裝好後，需完全關閉並重開 Antigravity 應用程式，讓後續啟動的 PowerShell 子行程繼承到更新後的系統 `PATH`。
  - **確認避開 Microsoft Store 的 Python 空殼別名**：Windows 10/11 未裝 Python 時，`PATH` 預設帶有導向商店的 `python.exe` 捷徑（App Execution Alias），Agent 在背景呼叫會直接失敗。建議安裝官方 Python（或於「設定 → 應用程式 → 進階應用程式設定 → 應用程式執行別名」關閉該別名），並在終端機實測 `git --version`、`rg --version` 與 `python --version` 都能正常印出版本號最穩妥。

---

## 快速安裝與移除

### 方式一：全域安裝（推薦，適用所有工作區）

- **Windows**：雙擊執行 `install.bat` 互動選擇語言，或直接透過命令列傳參安裝：

  ```bat
  install.bat en
  install.bat zh-CN
  install.bat zh-TW
  ```

  移除執行 `uninstall.bat`。

- **macOS / Linux**：執行 `./install.sh`（互動終端下可選擇語言，非互動預設 `en`），或直接傳參指定語言：

  ```sh
  ./install.sh en
  ./install.sh zh-CN
  ./install.sh zh-TW
  ```

  移除執行 `./uninstall.sh`。

安裝腳本會將選定語言的 `agent.md` 複製到 `~/.gemini/config/agents/minimal-coder/agent.md`（Windows 為 `%USERPROFILE%\.gemini\config\agents\minimal-coder\agent.md`）。安裝後於 Antigravity 新開對話（或重載視窗），在對話輸入框左下角代理選單切換為 `minimal-coder` 即可使用。

### 方式二：工作區限定安裝（團隊共用）

將所選語言目錄下的 `minimal-coder` 資料夾複製到目標專案內的：

```text
<repo>/.agents/agents/minimal-coder/agent.md
```

---

## 實測行為與限制說明

以下均為在 Antigravity `44.9.1`（App `2.31.2`）實測確認的行為特性：

1. **`excludeDefaultComponents: true` 會停用規則自動注入與內建子代理**
   - 開啟後不會自動載入全域 `~/.gemini/config/AGENTS.md` 或工作區 `AGENTS.md`，也不會掛載預設的 `self`、`research`、`browser`、`image-generator` 子代理。
   - 本設定透過在 `agent.md` 內嵌 `# Global Agent Baseline` 並要求主動讀取目錄 `AGENTS.md`／`GEMINI.md` 來補償。
2. **動態子代理的 `EnableWriteTools` 工具邊界**
   - 實測透過 `define_subagent` 建立且設為 `EnableWriteTools: false` 的子代理，僅會拿到 `read_file` 與 `search_web`，沒有列目錄或執行命令的工具。
   - 若子代理需要列目錄、搜尋檔案或執行唯讀命令（例如 `git diff`），須設為 `EnableWriteTools: true` 並在子代理提示詞中明確要求禁止修改任何檔案。
3. **與 Codex 客戶端權限層的差異**
   - `agent.md` 僅能調整模型提示與工具暴露，無法取代 Antigravity 客戶端層的 `Local Permissions: Auto` 決策機制（例如 Codex 客戶端的語意式命令自動審批代理）。如需以腳本攔截或預審命令，須另行搭配 `hooks.json`（`PreToolUse`）與客戶端白名單，不包含於本單檔極簡設定內。

---

## 自訂建議

- **更換個人全域規範**：直接編輯 `agent.md` 中的 `# Global Agent Baseline`（第 `19`–`64` 行）即可，或將自己原本的 `~/.gemini/config/AGENTS.md` 內容貼入該區塊。
- **需要 MCP 或額外內建工具**：將 frontmatter 的 `inheritMcp: false` 改為 `true`，或在 `tools:` 補上所需工具名稱。

---

## 目錄結構

```text
antigravity-minimal-coder/
├─ agents/
│  ├─ en/minimal-coder/agent.md      # 英文版設定
│  ├─ zh-CN/minimal-coder/agent.md   # 簡體中文版設定
│  └─ zh-TW/minimal-coder/agent.md   # 繁體中文版設定
├─ install.bat                       # Windows 全域安裝腳本
├─ uninstall.bat                     # Windows 移除腳本
├─ install.sh                        # macOS / Linux 全域安裝腳本
├─ uninstall.sh                      # macOS / Linux 移除腳本
├─ .gitattributes
├─ .gitignore
├─ LICENSE                           # MIT License
├─ README.md                         # 英文文件
├─ README.zh-CN.md                   # 簡體中文文件
└─ README.zh-TW.md                   # 繁體中文文件
```
