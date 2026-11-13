[English](README.md) | 简体中文 | [繁體中文](README.zh-TW.md)

# Antigravity Minimal Coder (`minimal-coder`)

专为官方 Google Antigravity（已于 `44.9.1` / App `2.31.2` 实测）设计的极简主代理（Custom Main Agent）配置，定位对齐 Codex 的精简系统提示体验：通过官方支持的 `excludeDefaultComponents: true` 与最小工具白名单，裁掉默认提示中冗长的非编码区块，同时以极简条款保留计划审核、代码质量复查、项目规则读取与动态 Subagents。

> 本项目仅使用 Antigravity 官方支持的自定义代理机制，无二进制修补、无客户端伪装、无 Prompt 混淆或外挂破解。

---

## 多语言配置版本

- **English**：[agents/en/minimal-coder/agent.md](agents/en/minimal-coder/agent.md)
- **简体中文**：[agents/zh-CN/minimal-coder/agent.md](agents/zh-CN/minimal-coder/agent.md)
- **繁體中文**：[agents/zh-TW/minimal-coder/agent.md](agents/zh-TW/minimal-coder/agent.md)

---

## 解决的问题与设计取舍

Antigravity 默认主代理会注入大量系统段落（`<artifacts>` 详细格式规范、`<featured_plugins>`、`<skills>` 列表、`<slash_commands>`、内置 `<subagents>` 说明、MCP 工具定义与各类长篇准则），在纯编码场景下会消耗大量初始 context 并稀释注意力。

`minimal-coder` 在 `agent.md` 中采用以下设置：

- `mainAgent: true`：注册为对话输入栏可切换的主代理。
- `excludeDefaultComponents: true`：移除 Antigravity 默认系统提示组件与内置子代理注册。
- `inheritMcp: false`：不继承外部 MCP server 工具定义，维持最低工具噪音。
- **精简工具白名单**（声明 `9` 项，实际注入 `10` 项；挂载 `run_command` 时后端会自动配对 `manage_task`）：
  - 读写与执行：`read_file`、`edit_file`、`write_file`、`run_command`（自动附带 `manage_task`）
  - 联网查证：`search_web`
  - 动态子代理：`define_subagent`、`invoke_subagent`、`manage_subagents`、`send_message`

### 在极简前提下保留的核心工作流

- **Artifact 计划审核（`Proceed` 按钮）**：跨文件或具架构影响的任务前，先在当前对话的 `brain/<conversation-id>/implementation_plan.md` 建立计划并带入 `ArtifactMetadata`（`UserFacing: true`、`RequestFeedback: true`），于 UI 呈现计划卡片与 `Proceed` 按钮，待确认后再实现。
- **`<code_quality>` 与交付前 `git diff` 自动复查**：保留去重、小函数与浅嵌套、mapping／table 统一处理变体、局部重构等资深审阅准则；Git 工作区完成多文件或关键修改后，派只读子代理检查 `git diff` 并在修正与复测后交付。
- **执行过程简述（Codex 式步骤旁白）**：多步骤排查或修改时，在下一批工具调用同一轮附带 1–2 句简短说明（刚确认的线索 + 下一步目的），让思考脉络直接呈现在 `Worked for ...` 记录中且不中断执行。
- **项目规则按需补读**：动手修改特定目录前，主动检查并读取工作区根目录与目标目录的 `AGENTS.md`／`GEMINI.md`。
- **可替换的 `# Global Agent Baseline`**：内置完整工程与回应规范段落，可按个人习惯直接修改或替换。

---

## 快速安装与卸载

### 方式一：全局安装（推荐，适用所有工作区）

- **Windows**：双击运行 `install.bat` 交互选择语言，或直接通过命令行传参安装：

  ```bat
  install.bat en
  install.bat zh-CN
  install.bat zh-TW
  ```

  卸载运行 `uninstall.bat`。

- **macOS / Linux**：运行 `./install.sh`（交互终端下可选择语言，非交互默认 `en`），或直接传参指定语言：

  ```sh
  ./install.sh en
  ./install.sh zh-CN
  ./install.sh zh-TW
  ```

  卸载运行 `./uninstall.sh`。

安装脚本会将选定语言的 `agent.md` 复制到 `~/.gemini/config/agents/minimal-coder/agent.md`（Windows 为 `%USERPROFILE%\.gemini\config\agents\minimal-coder\agent.md`）。安装后在 Antigravity 新开对话（或重载窗口），于输入框左下角代理菜单切换为 `minimal-coder` 即可使用。

### 方式二：工作区限定安装（团队共享）

将所选语言目录下的 `minimal-coder` 文件夹复制到目标项目内的：

```text
<repo>/.agents/agents/minimal-coder/agent.md
```

---

## 实测行为与限制说明

以下均为在 Antigravity `44.9.1`（App `2.31.2`）实测确认的行为特性：

1. **`excludeDefaultComponents: true` 会停用规则自动注入与内置子代理**
   - 开启后不会自动加载全局 `~/.gemini/config/AGENTS.md` 或工作区 `AGENTS.md`，也不会挂载默认的 `self`、`research`、`browser`、`image-generator` 子代理。
   - 本配置通过在 `agent.md` 内嵌 `# Global Agent Baseline` 并要求主动读取目录 `AGENTS.md`／`GEMINI.md` 来补偿。
2. **动态子代理的 `EnableWriteTools` 工具边界**
   - 实测通过 `define_subagent` 建立且设为 `EnableWriteTools: false` 的子代理，仅会拿到 `read_file` 与 `search_web`，没有列目录或执行命令的工具。
   - 若子代理需要列目录、搜索文件或执行只读命令（例如 `git diff`），须设为 `EnableWriteTools: true` 并在子代理提示词中明确要求禁止修改任何文件。
3. **与 Codex 客户端权限层的差异**
   - `agent.md` 仅能调整模型提示与工具暴露，无法取代 Antigravity 客户端层的 `Local Permissions: Auto` 决策机制（例如 Codex 客户端的语义式命令自动审批代理）。如需以脚本拦截或预审命令，须另行搭配 `hooks.json`（`PreToolUse`）与客户端白名单，不包含于本单文件极简配置内。

---

## 自定义建议

- **更换个人全局规范**：直接编辑 `agent.md` 中的 `# Global Agent Baseline`（第 `19`–`64` 行）即可，或将自己原本的 `~/.gemini/config/AGENTS.md` 内容贴入该区块。
- **需要 MCP 或额外内置工具**：将 frontmatter 的 `inheritMcp: false` 改为 `true`，或在 `tools:` 补上所需工具名称。

---

## 目录结构

```text
antigravity-minimal-coder/
├─ agents/
│  ├─ en/minimal-coder/agent.md      # 英文版配置
│  ├─ zh-CN/minimal-coder/agent.md   # 简体中文版配置
│  └─ zh-TW/minimal-coder/agent.md   # 繁体中文版配置
├─ install.bat                       # Windows 全局安装脚本
├─ uninstall.bat                     # Windows 卸载脚本
├─ install.sh                        # macOS / Linux 全局安装脚本
├─ uninstall.sh                      # macOS / Linux 卸载脚本
├─ .gitattributes
├─ .gitignore
├─ LICENSE                           # MIT License
├─ README.md                         # 英文文档
├─ README.zh-CN.md                   # 简体中文文档
└─ README.zh-TW.md                   # 繁体中文文档
```
