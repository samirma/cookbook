# OpenCode Agent Configuration

Agent definitions and configuration for the OpenCode multi-agent development workflow.

## 🚀 Setup

### 1. Install Configuration

Download the OpenCode configuration file:

```bash
mkdir -p ~/.config/opencode && \
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/opencode/opencode.json \
  -o ~/.config/opencode/opencode.json
```

Edit the file and replace `YOUR_API_KEY_HERE` with your actual API key.

### 2. Install Agents

Download the agent definitions:

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

### 3. Refine Installation

```bash
opencode run --agent dev-team 'Evaluate all models listed in ~/.config/opencode/opencode.json, research their capabilities, then review the agent definitions in ~/.config/opencode/agents and confirm (or adjust) the best model assignment for each agent based on its requirements and goals'
```

### 4. Run

```bash
opencode run --agent dev-team "Your task here"
```
