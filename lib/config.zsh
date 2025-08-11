#!/usr/bin/env zsh

# Configuration management for Lacy Shell

# Default configuration
typeset -A LACY_SHELL_CONFIG
LACY_SHELL_CONFIG_FILE="${HOME}/.lacy-shell/config.yaml"

# Load configuration from file
lacy_shell_load_config() {
    # Set defaults
    LACY_SHELL_DEFAULT_MODE="auto"
    LACY_SHELL_CURRENT_MODE="auto"
    
    # Create config directory if it doesn't exist
    if [[ ! -d "${HOME}/.lacy-shell" ]]; then
        mkdir -p "${HOME}/.lacy-shell"
    fi
    
    # Create default config if it doesn't exist
    if [[ ! -f "$LACY_SHELL_CONFIG_FILE" ]]; then
        lacy_shell_create_default_config
    fi
    
    # Try to load config using Python with YAML, fallback to basic parsing
    if command -v python3 >/dev/null 2>&1; then
        local config_exports=$(python3 -c "
import sys
import os
import json

config_file = '$LACY_SHELL_CONFIG_FILE'
if os.path.exists(config_file):
    try:
        # Try importing yaml first
        try:
            import yaml
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
        except ImportError:
            # Fallback: simple line-by-line parsing for basic YAML
            config = {}
            current_section = None
            with open(config_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    if line.endswith(':') and not line.startswith(' '):
                        current_section = line[:-1]
                        config[current_section] = {}
                    elif ':' in line and current_section:
                        key, value = line.split(':', 1)
                        key = key.strip()
                        value = value.strip()
                        # Remove inline comments
                        if '#' in value:
                            value = value.split('#')[0].strip()
                        # Remove quotes
                        if value.startswith('\"') and value.endswith('\"'):
                            value = value[1:-1]
                        config[current_section][key] = value
        
        # Export environment variables for shell
        if 'modes' in config and isinstance(config['modes'], dict) and 'default' in config['modes']:
            print(f'export LACY_SHELL_DEFAULT_MODE=\"{config[\"modes\"][\"default\"]}\"')
        
        if 'api_keys' in config and isinstance(config['api_keys'], dict):
            for key, value in config['api_keys'].items():
                if value and not value.startswith('#'):
                    print(f'export LACY_SHELL_API_{key.upper()}=\"{value}\"')
        
        # Set MCP servers flag (avoid complex JSON export issues)
        print('LACY_SHELL_MCP_SERVERS=configured')
            
    except Exception as e:
        print(f'# Warning: Error loading config: {e}', file=sys.stderr)
else:
    print('# Config file not found, using defaults', file=sys.stderr)
" 2>/dev/null)
        
        # Only eval if we got valid output
        if [[ -n "$config_exports" ]]; then
            eval "$config_exports"
        fi
    else
        echo "Warning: Python3 not found. Using default configuration."
    fi
}

# Create default configuration file
lacy_shell_create_default_config() {
    cat > "$LACY_SHELL_CONFIG_FILE" << 'EOF'
# Lacy Shell Configuration

api_keys:
  # openai: "your-openai-api-key"
  # anthropic: "your-anthropic-api-key"

mcp:
  servers:
    - name: "filesystem"
      command: "npx"
      args: ["@modelcontextprotocol/server-filesystem", "/tmp"]
    # - name: "web"
    #   command: "npx"  
    #   args: ["@modelcontextprotocol/server-web"]

modes:
  default: "auto"  # shell, agent, auto

keybindings:
  toggle_mode: "^[^M"     # Alt+Enter
  agent_mode: "^A"       # Ctrl+A  
  shell_mode: "^S"       # Ctrl+S

# Auto-detection settings
detection:
  # Keywords that suggest agent mode
  agent_keywords:
    - "help"
    - "how"
    - "what"
    - "why"
    - "explain"
    - "show me"
    - "find"
    - "search"
  
  # Commands that should always use shell mode
  shell_commands:
    - "ls"
    - "cd"
    - "pwd"
    - "cp"
    - "mv"
    - "rm"
    - "mkdir"
    - "rmdir"
    - "chmod"
    - "chown"
    - "ps"
    - "kill"
    - "top"
    - "htop"
    - "grep"
    - "sed"
    - "awk"
    - "git"
    - "npm"
    - "yarn"
    - "pip"
    - "cargo"
EOF
    
    # Quiet config creation - user can edit later if needed
}

# Get configuration value
lacy_shell_get_config() {
    local key="$1"
    echo "${LACY_SHELL_CONFIG[$key]:-}"
}

# Check if API keys are configured
lacy_shell_check_api_keys() {
    if [[ -z "$LACY_SHELL_API_OPENAI" && -z "$LACY_SHELL_API_ANTHROPIC" ]]; then
        echo "Warning: No API keys configured. Agent mode will not work."
        echo "Please add API keys to $LACY_SHELL_CONFIG_FILE"
        return 1
    fi
    return 0
}
