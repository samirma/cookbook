# OpenCode Multi-Agent Configuration

This directory contains the complete configuration for the OpenCode multi-agent development workflow.

## 📁 Structure

```
opencode/
├── README.md                   # This file
├── install-agents.sh          # Installation script
├── config.json.template       # Configuration template
└── agents/                    # Agent definitions
    ├── dev-team.md           # Primary orchestrator (planning, coding, quality)
    ├── coder.md              # Specialized coding subagent
    ├── reviewer.md           # Code quality review (MANDATORY step)
    ├── tester.md             # Test execution
    ├── checkpoint.md         # Human review facilitator
    ├── documentation.md      # Documentation review
    └── workflow-state.json   # Workflow configuration
```

## 🚀 Quick Start

### 1. Install OpenCode CLI

#### macOS (Homebrew)
```bash
brew install opencode
```

#### Linux
```bash
curl -fsSL https://opencode.ai/install.sh | bash
```

#### Or download directly:
Visit [https://opencode.ai](https://opencode.ai) for latest release

### 2. Install Agent Configurations

Run the installation script from this directory:

```bash
git clone git@github.com:samirma/cookbook.git 
cd cookbook/opencode
chmod +x install-agents.sh
./install-agents.sh
```

This will:
- Copy all agent definitions to `~/.opencode/agents/`
- Create `~/.opencode/config.json` (if it doesn't exist)
- Backup any existing agents

### 3. Configure API Keys

Edit `~/.opencode/config.json` and add your API keys:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "alibaba-coding-plan/MiniMax-M2.5",
  "provider": {
    "alibaba-coding-plan": {
      "options": {
        "apiKey": "sk-your-api-key-here"
      }
    },
    "bailian-coding-plan": {
      "options": {
        "apiKey": "sk-your-bailian-key-here"
      }
    }
  }
}
```

**Note**: The agents use models from `bailian-coding-plan` provider:
- `glm-5` (dev-team - Primary, Checkpoint, Documentation)
- `kimi-k2.5` (Coder)
- `MiniMax-M2.5` (Reviewer, Tester)

### 4. Verify Installation

```bash
# Check CLI installation
opencode --version

# List available agents
opencode agent list

# Test with a simple task
opencode run --agent coder "Hello world"
```

## 🎯 Available Agents

| Agent | Purpose | Model | Capabilities |
|-------|---------|-------|--------------|
| **dev-team** | Primary orchestrator (planning + coding) | glm-5 | write, edit, bash, glob, grep, web_search |
| **coder** | Specialized coding subagent | kimi-k2.5 | write, edit, bash, glob, grep, web_search |
| **reviewer** | Code quality review (MANDATORY) | MiniMax-M2.5 | write, edit, bash, glob, grep, web_search |
| **tester** | Test execution | MiniMax-M2.5 | write, edit, bash, glob, grep, web_search |
| **checkpoint** | Human review | glm-5 | write, edit, bash, glob, grep, web_search |
| **documentation** | Docs review | glm-5 | write, edit, bash, glob, grep, web_search |

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

### Key Changes:
- **dev-team** is now the primary agent (combines planning + coding)
- **Code Review is MANDATORY** - cannot be skipped
- All agents have full tool access (write, edit, bash, glob, grep, web_search)

## 📝 Usage Examples

### Basic Usage
```bash
# Run with a specific task
opencode run --agent dev-team "Implement user authentication with JWT"

# Interactive mode
opencode --agent dev-team

# Continue last session
opencode --agent dev-team --continue
```

### Architecture Planning Only
```bash
opencode run --agent dev-team "Design microservices architecture"
```

### Web Interface
```bash
opencode web --agent dev-team
```

## ⚙️ Configuration Details

### Agent Tools Breakdown

| Agent | write | edit | bash | glob | grep | web_search |
|-------|:-----:|:----:|:----:|:----:|:----:|:----------:|
| dev-team | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| coder | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| reviewer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| tester | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| checkpoint | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| documentation | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**All agents now have full tool access for maximum flexibility.**

### Confidence Thresholds

| Score | Action |
|-------|--------|
| 90-100% | ✅ Auto-approve |
| 70-89% | ⚠️ Optional checkpoint |
| <70% | 🛑 Mandatory checkpoint |

## 🔧 Customization

### Modifying Agent Behavior

Edit files in `~/.opencode/agents/` after installation:

```bash
# Example: Adjust dev-team's temperature
vim ~/.opencode/agents/dev-team.md
```

### Adding Custom Agents

1. Create a new `.md` file in `~/.opencode/agents/`
2. Follow the frontmatter format:
```yaml
---
description: Your agent description
mode: subagent
model: your-model-name
temperature: 0.2
tools:
  write: false
  edit: false
  bash: false
  glob: true
  grep: true
---
```

## 🐛 Troubleshooting

### Agent not found
```bash
# Verify agents are installed
ls -la ~/.opencode/agents/

# Re-run installation
./install-agents.sh
```

### API key issues
```bash
# Check config
opencode config show

# Edit config
vim ~/.opencode/config.json
```

### Permission denied
```bash
chmod +x install-agents.sh
```

## 📚 Additional Resources

- [OpenCode Documentation](https://opencode.ai/docs)
- [Agent Workflow Guide](./agents/WORKFLOW_USAGE_GUIDE.md) (if available)
- [Model Assignments](./agents/MODEL_ASSIGNMENTS.md) (if available)

## 🔄 Updating Agents

To update to the latest agent configurations:

```bash
cd /Users/U124317/cookbook/opencode
git pull  # If using git
./install-agents.sh
```

The script will automatically backup your existing agents before installing updates.

## 📝 License

This configuration follows the same license as the OpenCode project.
