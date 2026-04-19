# OpenCode Agent Configuration

This directory contains the agent definitions and model configuration for the OpenCode multi-agent development workflow.

## 📁 Structure

```
opencode/
├── README.md              # This file
├── opencode.json          # Main configuration (models, provider, permissions)
└── agents/                # Agent definitions
    ├── dev-team.md        # Primary orchestrator
    ├── coder.md           # Specialized coding subagent
    ├── reviewer.md        # Code quality review
    ├── tester.md          # Test execution
    ├── checkpoint.md      # Human review facilitator
    ├── documentation.md   # Documentation review
    └── workflow-state.json # Workflow state tracking
```

## ⚙️ Configuration

The `opencode.json` file (installed at `~/.config/opencode/opencode.json`) defines the provider, models, and agent permissions.

### Provider

| Field | Value |
|-------|-------|
| Provider ID | `bailian-coding-plan` |
| Name | Model Studio Coding Plan |
| NPM package | `@ai-sdk/anthropic` |
| Base URL | `https://coding-intl.dashscope.aliyuncs.com/apps/anthropic/v1` |

> **Note:** Replace `YOUR_API_KEY_HERE` in `~/.config/opencode/opencode.json` with your actual API key before use.

### Models

| Model ID | Name | Input | Output | Context | Output Limit |
|----------|------|-------|--------|---------|--------------|
| `glm-5` | GLM-5 | text | text | 202,752 | 16,384 |
| `kimi-k2.5` | Kimi K2.5 | text, image | text | 262,144 | 32,768 |
| `MiniMax-M2.5` | MiniMax M2.5 | text | text | 200,000 | 16,384 |

### Agent Permissions

All agents run with the following permissions enabled:

| Permission | Status |
|------------|--------|
| `edit` | allow |
| `bash` | allow |
| `webfetch` | allow |
| `doom_loop` | allow |
| `external_directory` | allow |

## 🤖 Agent Model Assignments

| Agent | Model | Mode | Temperature |
|-------|-------|------|-------------|
| **dev-team** | `bailian-coding-plan/glm-5` | primary | 0.2 |
| **coder** | `bailian-coding-plan/kimi-k2.5` | subagent | 0.2 |
| **reviewer** | `bailian-coding-plan/MiniMax-M2.5` | subagent | 0.1 |
| **tester** | `bailian-coding-plan/MiniMax-M2.5` | subagent | 0.1 |
| **checkpoint** | `bailian-coding-plan/glm-5` | subagent | 0.1 |
| **documentation** | `bailian-coding-plan/glm-5` | subagent | 0.2 |

## 🚀 Setup

### 1. Configure API Key

Edit `~/.config/opencode/opencode.json` and replace `YOUR_API_KEY_HERE` with your API key.

### 2. Download Agent Configurations

Download the agent files directly from the repository:

```bash
AGENTS_URL="https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/opencode/agents"
AGENTS_DIR="$HOME/.config/opencode/agents"
mkdir -p "$AGENTS_DIR"

curl -fsSL "$AGENTS_URL/dev-team.md" -o "$AGENTS_DIR/dev-team.md"
curl -fsSL "$AGENTS_URL/coder.md" -o "$AGENTS_DIR/coder.md"
curl -fsSL "$AGENTS_URL/reviewer.md" -o "$AGENTS_DIR/reviewer.md"
curl -fsSL "$AGENTS_URL/tester.md" -o "$AGENTS_DIR/tester.md"
curl -fsSL "$AGENTS_URL/checkpoint.md" -o "$AGENTS_DIR/checkpoint.md"
curl -fsSL "$AGENTS_URL/documentation.md" -o "$AGENTS_DIR/documentation.md"
curl -fsSL "$AGENTS_URL/workflow-state.json" -o "$AGENTS_DIR/workflow-state.json"
```

### 3. Agent Setup

Run the primary agent to validate that the configured models match each agent's requirements:

```bash
opencode run --agent dev-team 'Evaluate all models listed in ~/.config/opencode/opencode.json, research their capabilities, then review the agent definitions in ~/.config/opencode/agents and confirm (or adjust) the best model assignment for each agent based on its requirements and goals'
```

### 4. Verify Installation

```bash
# List available agents
opencode agent list

# Test with a specific agent
opencode run --agent dev-team "Your task here"
```

## 🔄 Workflow Overview

```
User Request
    ↓
┌─────────────────────────────────────────────────────────┐
│  DEV-TEAM (Primary) - orchestrates the entire workflow  │
│  ├── Creates implementation plan                        │
│  ├── Implements code                                    │
│  ├── Calls REVIEWER (MANDATORY) → Code quality check    │
│  ├── Calls TESTER (parallel) → Test execution           │
│  ├── Calculates confidence score                        │
│  ├── Calls CHECKPOINT if confidence < 70%               │
│  └── Calls DOCUMENTATION (optional, after completion)   │
└─────────────────────────────────────────────────────────┘
```

### Confidence Thresholds

| Score | Action |
|-------|--------|
| 90-100% | ✅ Auto-approve |
| 70-89% | ⚠️ Optional checkpoint |
| <70% | 🛑 Mandatory checkpoint |
