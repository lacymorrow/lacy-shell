# Lacy Shell Examples

This document provides practical examples of using Lacy Shell in different modes.

## Quick Start

After installation, try these examples to get familiar with the three modes:

### Shell Mode Examples
```bash
# Switch to shell mode
[SHELL] → ls -la
[SHELL] → git status
[SHELL] → npm install
[SHELL] → cd /path/to/project
```

### Agent Mode Examples
```bash
# Switch to agent mode (Ctrl+A)
[AGENT] → What files were modified in the last week?
[AGENT] → Help me write a Python script to process CSV files
[AGENT] → Explain what this git repository does
[AGENT] → How do I optimize this React component?
[AGENT] → Find all TODO comments in my code
```

### Auto Mode Examples
```bash
# Auto mode detects intent automatically
[AUTO] → ls -la                           # → Shell execution
[AUTO] → what files are in this directory # → Agent response
[AUTO] → git commit -m "fix bug"          # → Shell execution  
[AUTO] → how do I revert last commit      # → Agent response
[AUTO] → npm test                         # → Shell execution
[AUTO] → explain this error message       # → Agent response
```

## Keybinding Examples

### Mode Switching
- `Alt+Enter`: Cycle through modes (shell → agent → auto → shell...)
- `Ctrl+A`: Direct switch to Agent mode
- `Ctrl+S`: Direct switch to Shell mode  
- `Alt+A`: Direct switch to Auto mode
- `Alt+H`: Show help

### Example Workflow
```bash
# Start in auto mode
[AUTO] → ls
# Files are listed normally

# Switch to agent mode for help
# Press Ctrl+A
[AGENT] → how do I find large files?
# AI explains: "You can use the 'find' command with size parameters..."

# Switch back to shell to execute the suggestion
# Press Ctrl+S  
[SHELL] → find . -size +100M
```

## Advanced Usage

### Using Built-in Aliases
```bash
# Direct AI queries (works in any mode)
ask "what's the difference between git merge and rebase?"

# Get help with context
aihelp "docker compose"

# AI-powered command completion
aicomplete "git log --"

# Search command history with AI
hisearch "deploy"
```

### Configuration Examples

#### Basic API Setup
```yaml
# ~/.lacy-shell/config.yaml
api_keys:
  openai: "sk-your-openai-key-here"
  # or
  anthropic: "your-anthropic-key-here"

modes:
  default: "auto"
```

#### Advanced MCP Configuration
```yaml
mcp:
  servers:
    - name: "filesystem"
      command: "npx"
      args: ["@modelcontextprotocol/server-filesystem", "/Users/username/projects"]
    - name: "web"
      command: "npx"
      args: ["@modelcontextprotocol/server-web"]
    - name: "git"
      command: "npx" 
      args: ["@modelcontextprotocol/server-git", "--repository", "."]
```

#### Custom Detection Keywords
```yaml
detection:
  agent_keywords:
    - "help"
    - "explain"
    - "what"
    - "how"
    - "debug"
    - "analyze"
    - "optimize"
    - "tutorial"
  
  shell_commands:
    - "ls"
    - "cd"
    - "git"
    - "npm"
    - "docker"
    - "kubectl"
    - "terraform"
```

## Integration Examples

### With Starship Prompt
The mode indicator automatically integrates with Starship:
```bash
❯ [AUTO] your-command-here
```

### With Oh My Zsh
Works seamlessly with existing Oh My Zsh themes:
```bash
➜ project git:(main) [AGENT] help me with this error
```

### With tmux
Use in tmux sessions for enhanced development workflow:
```bash
# Terminal 1: Development 
[AUTO] → npm run dev

# Terminal 2: AI assistance
[AGENT] → explain this error in the logs

# Terminal 3: Shell operations
[SHELL] → git add . && git commit
```

## Real-world Scenarios

### Debugging Workflow
```bash
# Start with an error
[AUTO] → npm test
# Test fails...

# Get AI help
[AGENT] → This test is failing with "Cannot read property 'id' of undefined". How do I debug this?
# AI suggests debugging steps...

# Execute suggestions  
[SHELL] → node --inspect-brk ./node_modules/.bin/jest specific-test.js
```

### DevOps Tasks
```bash
# Check system status
[AUTO] → docker ps
# Shows running containers

# Ask for optimization advice
[AGENT] → My Docker containers are using too much memory. How can I optimize them?
# AI provides specific recommendations...

# Apply suggestions
[SHELL] → docker system prune
[SHELL] → docker build --memory=512m .
```

### Learning New Technologies  
```bash
# Explore a new project
[AUTO] → ls
# See project structure

# Get oriented
[AGENT] → This looks like a Rust project. Can you explain the structure and how to get started?
# AI explains Cargo.toml, src/ directory, etc...

# Follow AI guidance
[SHELL] → cargo build
[SHELL] → cargo test
```

## Troubleshooting Examples

### Test Detection Logic
```bash
lacy_shell_test_detection
```

### Check Configuration
```bash
lacy_shell_test_mcp
```

### Debug Mode Issues
```bash
# Check current mode
echo $LACY_SHELL_CURRENT_MODE

# Manually test mode switching
lacy_shell_set_mode "agent"
lacy_shell_set_mode "shell" 
lacy_shell_set_mode "auto"
```

### API Key Issues
```bash
# Check if keys are loaded
env | grep LACY_SHELL_API

# Test AI connectivity
ask "hello"
```

## Tips and Best Practices

1. **Start with Auto Mode**: Let the system learn your patterns
2. **Use Agent Mode for Learning**: Great for exploring new technologies
3. **Shell Mode for Precision**: When you know exactly what command to run
4. **Combine with Existing Tools**: Works great with your current shell setup
5. **Customize Detection**: Adjust keywords based on your workflow

## Community Examples

Share your own examples by contributing to the repository!

### Data Science Workflow
```bash
[AGENT] → I have a CSV with sales data. Help me create a Python script to analyze trends
[SHELL] → python analyze_sales.py
[AGENT] → The script shows a dip in Q3. What could cause this?
```

### System Administration
```bash
[AGENT] → Server is running slow. Help me diagnose the issue
[SHELL] → top
[SHELL] → df -h
[AGENT] → Based on these outputs, what should I do next?
```
