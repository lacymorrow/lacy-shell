#!/usr/bin/env zsh

# Prompt modifications for Lacy Shell

# Store original prompts
LACY_SHELL_ORIGINAL_PS1="$PS1"
LACY_SHELL_ORIGINAL_RPS1="$RPS1"

# Setup prompt integration
lacy_shell_setup_prompt() {
    # Add to precmd functions to update prompt
    precmd_functions+=(lacy_shell_update_prompt)
}

# Update prompt with mode indicator
lacy_shell_update_prompt() {
    # Get mode indicator
    local mode_indicator=$(lacy_shell_get_mode_indicator)
    
    # Simple approach: always use RPS1 for the mode indicator
    RPS1="$mode_indicator"
}

# Get a simple text mode indicator (for scripts)
lacy_shell_get_mode_text() {
    case "$LACY_SHELL_CURRENT_MODE" in
        "shell")
            echo "SHELL"
            ;;
        "agent")
            echo "AGENT"
            ;;
        "auto")
            echo "AUTO"
            ;;
        *)
            echo "UNKNOWN"
            ;;
    esac
}

# Restore original prompt
lacy_shell_restore_prompt() {
    PS1="$LACY_SHELL_ORIGINAL_PS1"
    RPS1="$LACY_SHELL_ORIGINAL_RPS1"
}

# Integration with Oh My Zsh themes
lacy_shell_setup_omz_integration() {
    # If Oh My Zsh is detected, integrate with themes
    if [[ -n "$ZSH" && -d "$ZSH" ]]; then
        # Create a custom prompt element that themes can use
        function lacy_shell_prompt_info() {
            echo "$(lacy_shell_get_mode_indicator)"
        }
        
        # Add to Oh My Zsh prompt functions
        if [[ -z "${PROMPT_FUNCTIONS[(r)lacy_shell_prompt_info]}" ]]; then
            PROMPT_FUNCTIONS+=(lacy_shell_prompt_info)
        fi
    fi
}

# Integration with Powerlevel10k
lacy_shell_setup_p10k_integration() {
    # Check if Powerlevel10k is being used
    if [[ -n "$POWERLEVEL9K_MODE" || -n "$POWERLEVEL10K_MODE" ]]; then
        # Define custom prompt segment for P10k
        function prompt_lacy_shell() {
            local mode_text=$(lacy_shell_get_mode_text)
            local color
            
            case "$LACY_SHELL_CURRENT_MODE" in
                "shell")
                    color="green"
                    ;;
                "agent")
                    color="blue"
                    ;;
                "auto")
                    color="yellow"
                    ;;
                *)
                    color="red"
                    ;;
            esac
            
            p10k segment -f "$color" -t "$mode_text"
        }
        
        # Register the segment
        if typeset -f p10k >/dev/null; then
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(lacy_shell)
        fi
    fi
}

# Auto-detect and integrate with various prompt systems
lacy_shell_auto_integrate_prompt() {
    # Try different integration methods
    lacy_shell_setup_omz_integration
    lacy_shell_setup_p10k_integration
    
    # Fallback to simple prompt modification
    lacy_shell_update_prompt
}
