#!/usr/bin/env zsh

# Lacy Shell - Smart shell plugin with MCP support
# Main plugin file

# Plugin directory
LACY_SHELL_DIR="${0:A:h}"

# Load configuration
source "$LACY_SHELL_DIR/lib/config.zsh"
source "$LACY_SHELL_DIR/lib/modes.zsh"
source "$LACY_SHELL_DIR/lib/mcp.zsh"
source "$LACY_SHELL_DIR/lib/detection.zsh"
source "$LACY_SHELL_DIR/lib/keybindings.zsh"
source "$LACY_SHELL_DIR/lib/prompt.zsh"
source "$LACY_SHELL_DIR/lib/execute.zsh"

# Initialize the plugin
lacy_shell_init() {
    # Load configuration
    lacy_shell_load_config
    
    # Set up keybindings
    lacy_shell_setup_keybindings
    
    # Initialize MCP connections
    lacy_shell_init_mcp
    
    # Set up prompt modifications
    lacy_shell_setup_prompt
    
    # Set default mode
    lacy_shell_set_mode "${LACY_SHELL_DEFAULT_MODE:-auto}"
    
    # Quiet initialization - mode shows in prompt
}

# Clean up function
lacy_shell_cleanup() {
    lacy_shell_cleanup_mcp
    unset LACY_SHELL_CURRENT_MODE
    unset LACY_SHELL_CONFIG
}

# Set up smart execution and prompt hooks
zle -N accept-line lacy_shell_smart_accept_line
precmd_functions+=(lacy_shell_precmd)

# Initialize on load
lacy_shell_init

# Add cleanup on shell exit
trap lacy_shell_cleanup EXIT
