# Lacy Shell

A smart shell plugin that provides three modes of operation:

- **Shell Mode**: Normal shell behavior
- **Agent Mode**: AI-powered command assistance via MCP
- **Auto Mode**: Automatically detects whether to use shell or agent

## Features

- 🔄 Seamless mode switching with keyboard shortcuts
- 🤖 MCP (Model Context Protocol) integration
- 🧠 Smart auto-detection of commands vs natural language
- ⚡ Works with your existing zsh/starship setup
- 🔐 Secure API key management

## Installation

```bash
# Clone the repository
git clone https://github.com/username/lacy-shell.git ~/.lacy-shell

# Add to your .zshrc
echo 'source ~/.lacy-shell/lacy-shell.plugin.zsh' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

## Configuration

Create `~/.lacy-shell/config.yaml`:

```yaml
api_keys:
  openai: "your-api-key"
  anthropic: "your-api-key"
  
mcp:
  servers:
    - name: "filesystem"
      command: "npx"
      args: ["@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    - name: "web"
      command: "npx"  
      args: ["@modelcontextprotocol/server-web"]

modes:
  default: "auto"  # shell, agent, auto
  
keybindings:
  toggle_mode: "ctrl-t"
  agent_mode: "ctrl-x ctrl-a"
  shell_mode: "ctrl-x ctrl-s"
```

## Usage

### Mode Switching:
- **`Ctrl+T`**: Toggle through modes (easiest)
- **`mode shell`** or **`mode s`**: Switch to Shell mode
- **`mode agent`** or **`mode a`**: Switch to Agent mode  
- **`mode auto`** or **`mode u`**: Switch to Auto mode
- **`Ctrl+X Ctrl+H`**: Show help

### Advanced Keybindings:
- `Ctrl+X Ctrl+M`: Toggle mode
- `Ctrl+X Ctrl+A`: Agent mode
- `Ctrl+X Ctrl+S`: Shell mode
- `Ctrl+X Ctrl+U`: Auto mode

Mode indicator shows on right side of prompt: `~` (auto), `$` (shell), `?` (agent)

### Examples

**Agent Mode:**
```bash
[AGENT] → What files were modified in the last week?
[AGENT] → Help me write a Python script to process CSV files
```

**Auto Mode:**
```bash
[AUTO] → ls -la                    # Executes as shell command
[AUTO] → show me recent git commits # Routes to agent
```
