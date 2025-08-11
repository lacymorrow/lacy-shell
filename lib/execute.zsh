#!/usr/bin/env zsh

# Command execution logic for Lacy Shell

# Smart accept-line widget that handles agent queries
lacy_shell_smart_accept_line() {
    local input="$BUFFER"
    
    # Skip empty commands
    if [[ -z "$input" ]]; then
        zle .accept-line
        return
    fi
    
    # Determine which mode to use
    local execution_mode=$(lacy_shell_detect_mode "$input")
    
    # Handle based on mode
    case "$execution_mode" in
        "agent")
            # Clear the line and execute via agent
            BUFFER=""
            zle .accept-line
            lacy_shell_execute_agent "$input"
            ;;
        *)
            # Normal shell execution
            zle .accept-line
            ;;
    esac
}

# Execute command via AI agent
lacy_shell_execute_agent() {
    local query="$1"
    
    # Query the agent with minimal output
    lacy_shell_query_agent "$query"
    
    # Reset the command line
    zle && zle reset-prompt
}

# Precmd hook - called before each prompt
lacy_shell_precmd() {
    # Update prompt with current mode
    lacy_shell_update_prompt
}

# Enhanced command execution with confirmation for dangerous commands
lacy_shell_execute_with_confirmation() {
    local command="$1"
    local dangerous_commands=("rm -rf" "sudo rm" "mkfs" "dd if=" ">" "truncate")
    
    # Check if command contains dangerous patterns
    for pattern in "${dangerous_commands[@]}"; do
        if [[ "$command" == *"$pattern"* ]]; then
            echo ""
            echo "%F{red}⚠️  Potentially dangerous command detected:%f"
            echo "   $command"
            echo ""
            read "response?Continue? (y/N): "
            if [[ "$response" != "y" && "$response" != "Y" ]]; then
                echo "Command cancelled."
                return 1
            fi
            break
        fi
    done
    
    # Execute the command
    eval "$command"
}

# Suggest command corrections using AI
lacy_shell_suggest_correction() {
    local failed_command="$1"
    local exit_code="$2"
    
    if [[ "$LACY_SHELL_CURRENT_MODE" == "auto" || "$LACY_SHELL_CURRENT_MODE" == "agent" ]]; then
        echo ""
        echo "%F{yellow}💡 Getting AI suggestion for failed command...%f"
        
        local suggestion_query="The command '$failed_command' failed with exit code $exit_code. Please suggest a corrected version or alternative approach."
        lacy_shell_query_agent "$suggestion_query"
    fi
}

# Command history integration with AI
lacy_shell_ai_history_search() {
    local search_term="$1"
    
    if [[ -z "$search_term" ]]; then
        echo "Usage: lacy_shell_ai_history_search <search_term>"
        return 1
    fi
    
    # Get recent history
    local recent_history=$(fc -l -100 | tail -20)
    
    # Query AI for relevant commands
    local query="Based on my recent command history, suggest relevant commands for: $search_term

Recent history:
$recent_history

Please suggest specific commands that would help with '$search_term'."
    
    echo "%F{blue}🔍 Searching command history with AI...%f"
    lacy_shell_query_agent "$query"
}

# Auto-complete enhancement with AI
lacy_shell_ai_complete() {
    local partial_command="$1"
    
    if [[ ${#partial_command} -lt 3 ]]; then
        return 0  # Don't trigger for very short inputs
    fi
    
    # Query AI for completion suggestions
    local query="Complete this shell command: $partial_command

Provide 3-5 most likely completions, considering:
- Current directory: $(pwd)
- Available files: $(ls -1 | head -10)
- Common shell patterns

Format as a simple list of completions."
    
    echo ""
    echo "%F{blue}🔮 AI completion suggestions:%f"
    lacy_shell_query_agent "$query"
}

# Context-aware help system
lacy_shell_context_help() {
    local topic="$1"
    
    local context_info="
Current directory: $(pwd)
Files in directory: $(ls -1 | head -10)
Shell: $SHELL
OS: $(uname -s)
"
    
    local query="Provide help for: $topic

Context:
$context_info

Please provide:
1. Brief explanation
2. Usage examples
3. Common options/flags
4. Related commands
"
    
    echo "%F{blue}📖 Context-aware help for: $topic%f"
    lacy_shell_query_agent "$query"
}

# Conversation management
lacy_shell_clear_conversation() {
    rm -f "$LACY_SHELL_CONVERSATION_FILE"
    echo "Conversation history cleared"
}

lacy_shell_show_conversation() {
    if [[ -f "$LACY_SHELL_CONVERSATION_FILE" ]]; then
        cat "$LACY_SHELL_CONVERSATION_FILE"
    else
        echo "No conversation history found"
    fi
}

# Mode switching commands (work in any mode)
lacy_shell_mode() {
    case "$1" in
        "shell"|"s")
            lacy_shell_set_mode "shell"
            echo "Switched to shell mode (\$)"
            ;;
        "agent"|"a")
            lacy_shell_set_mode "agent"
            echo "Switched to agent mode (?)"
            ;;
        "auto"|"u")
            lacy_shell_set_mode "auto"
            echo "Switched to auto mode (~)"
            ;;
        "toggle"|"t")
            lacy_shell_toggle_mode
            ;;
        *)
            echo "Usage: mode [shell|agent|auto|toggle] or [s|a|u|t]"
            echo "Current mode: $LACY_SHELL_CURRENT_MODE"
            ;;
    esac
}

# Export functions for direct use
alias ask="lacy_shell_query_agent"
alias suggest="lacy_shell_suggest_correction"
alias aihelp="lacy_shell_context_help"
alias aicomplete="lacy_shell_ai_complete"
alias hisearch="lacy_shell_ai_history_search"
alias clear_chat="lacy_shell_clear_conversation"
alias show_chat="lacy_shell_show_conversation"
alias mode="lacy_shell_mode"
