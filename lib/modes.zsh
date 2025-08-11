#!/usr/bin/env zsh

# Mode management for Lacy Shell

# Available modes
LACY_SHELL_MODES=("shell" "agent" "auto")
LACY_SHELL_CURRENT_MODE="auto"

# Mode descriptions
typeset -A LACY_SHELL_MODE_DESCRIPTIONS
LACY_SHELL_MODE_DESCRIPTIONS[shell]="Normal shell execution"
LACY_SHELL_MODE_DESCRIPTIONS[agent]="AI agent assistance via MCP"
LACY_SHELL_MODE_DESCRIPTIONS[auto]="Smart auto-detection"

# Set the current mode
lacy_shell_set_mode() {
    local new_mode="$1"
    
    # Validate mode
    if [[ ! " ${LACY_SHELL_MODES[@]} " =~ " ${new_mode} " ]]; then
        echo "Invalid mode: $new_mode. Available modes: ${LACY_SHELL_MODES[*]}"
        return 1
    fi
    
    LACY_SHELL_CURRENT_MODE="$new_mode"
    
    # Update prompt if function exists
    if typeset -f lacy_shell_update_prompt > /dev/null; then
        lacy_shell_update_prompt
    fi
    
    # Quiet mode switching - indicator shows in prompt
}

# Get current mode
lacy_shell_get_mode() {
    echo "$LACY_SHELL_CURRENT_MODE"
}

# Toggle between modes
lacy_shell_toggle_mode() {
    local current_index=0
    local next_index=0
    
    # Find current mode index
    for i in {1..${#LACY_SHELL_MODES}}; do
        if [[ "${LACY_SHELL_MODES[$i]}" == "$LACY_SHELL_CURRENT_MODE" ]]; then
            current_index=$i
            break
        fi
    done
    
    # Calculate next mode index (wrap around)
    next_index=$(( (current_index % ${#LACY_SHELL_MODES}) + 1 ))
    
    # Set new mode
    lacy_shell_set_mode "${LACY_SHELL_MODES[$next_index]}"
}

# Switch directly to agent mode
lacy_shell_agent_mode() {
    lacy_shell_set_mode "agent"
}

# Switch directly to shell mode  
lacy_shell_shell_mode() {
    lacy_shell_set_mode "shell"
}

# Switch directly to auto mode
lacy_shell_auto_mode() {
    lacy_shell_set_mode "auto"
}

# Get mode indicator for prompt
lacy_shell_get_mode_indicator() {
    case "$LACY_SHELL_CURRENT_MODE" in
        "shell")
            echo "%F{green}$%f"
            ;;
        "agent")
            echo "%F{blue}?%f"
            ;;
        "auto")
            echo "%F{yellow}~%f"
            ;;
        *)
            echo "%F{red}!%f"
            ;;
    esac
}
