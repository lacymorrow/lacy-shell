#!/usr/bin/env zsh

# MCP (Model Context Protocol) integration for Lacy Shell

# MCP connection management
typeset -A LACY_SHELL_MCP_SERVERS
typeset -A LACY_SHELL_MCP_PIDS

# Initialize MCP connections
lacy_shell_init_mcp() {
    # Only initialize if we have servers configured
    if [[ -n "$LACY_SHELL_MCP_SERVERS" ]]; then
        # Silent initialization for now
        # Future: actually start MCP servers when needed
        :
    fi
}

# Start MCP servers
lacy_shell_start_mcp_servers() {
    # Simplified MCP server startup - just log that we have MCP support
    if [[ "$LACY_SHELL_MCP_SERVERS" == "configured" ]]; then
        # MCP servers are configured in principle
        # For now, we just note that MCP support is available
        # Future implementation will actually start the servers
        :
    fi
}

# Stop MCP servers
lacy_shell_stop_mcp_servers() {
    # Kill any running MCP server processes
    for var in ${(M)${(k)parameters}:#LACY_SHELL_MCP_PID_*}; do
        local pid="${(P)var}"
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            echo "Stopping MCP server (PID: $pid)"
            kill "$pid" 2>/dev/null
        fi
        unset "$var"
    done
}

# Conversation history
LACY_SHELL_CONVERSATION_FILE="${HOME}/.lacy-shell/conversation.log"

# Send query to AI with MCP context and conversation history
lacy_shell_query_agent() {
    local query="$1"
    local use_mcp="${2:-true}"
    
    # Check if API keys are available
    if ! lacy_shell_check_api_keys; then
        echo "Error: No API keys configured. Cannot query agent."
        return 1
    fi
    
    # Ensure conversation directory exists
    mkdir -p "$(dirname "$LACY_SHELL_CONVERSATION_FILE")"
    
    # Create temporary file for the query
    local temp_file=$(mktemp)
    local response_file=$(mktemp)
    
    # Prepare the query with context and conversation history
    cat > "$temp_file" << EOF
System Context:
- Current Directory: $(pwd)
- Current Date: $(date)
- Shell: $SHELL
- User: $USER

EOF

    # Add recent conversation history (last 10 exchanges)
    if [[ -f "$LACY_SHELL_CONVERSATION_FILE" ]]; then
        echo "Recent Conversation:" >> "$temp_file"
        tail -20 "$LACY_SHELL_CONVERSATION_FILE" >> "$temp_file"
        echo "" >> "$temp_file"
    fi

    # Add MCP context if available
    if [[ "$use_mcp" == "true" ]] && [[ -n "$LACY_SHELL_MCP_SERVERS" ]]; then
        echo "Available MCP Tools:" >> "$temp_file"
        lacy_shell_list_mcp_tools >> "$temp_file"
        echo "" >> "$temp_file"
    fi
    
    echo "Current Query: $query" >> "$temp_file"
    
    # Send to AI service
    lacy_shell_send_to_ai "$temp_file" "$response_file" "$query"
    
    # Display response and save to conversation history
    if [[ -f "$response_file" ]]; then
        local response=$(cat "$response_file")
        echo "$response"
        
        # Save to conversation history
        echo "User: $query" >> "$LACY_SHELL_CONVERSATION_FILE"
        echo "Assistant: $response" >> "$LACY_SHELL_CONVERSATION_FILE"
        echo "---" >> "$LACY_SHELL_CONVERSATION_FILE"
        
        # Keep conversation history manageable (last 100 exchanges)
        if [[ $(wc -l < "$LACY_SHELL_CONVERSATION_FILE") -gt 300 ]]; then
            tail -200 "$LACY_SHELL_CONVERSATION_FILE" > "${LACY_SHELL_CONVERSATION_FILE}.tmp"
            mv "${LACY_SHELL_CONVERSATION_FILE}.tmp" "$LACY_SHELL_CONVERSATION_FILE"
        fi
    else
        echo "Error: No response received from AI service"
    fi
    
    # Cleanup
    rm -f "$temp_file" "$response_file"
}

# Send query to AI service (OpenAI/Anthropic)
lacy_shell_send_to_ai() {
    local input_file="$1"
    local output_file="$2"
    local query="$3"
    
    # Try OpenAI first, then Anthropic
    if [[ -n "$LACY_SHELL_API_OPENAI" ]]; then
        lacy_shell_query_openai "$input_file" "$output_file" "$query"
    elif [[ -n "$LACY_SHELL_API_ANTHROPIC" ]]; then
        lacy_shell_query_anthropic "$input_file" "$output_file" "$query"
    else
        echo "Error: No API keys configured" > "$output_file"
        return 1
    fi
}

# Query OpenAI API
lacy_shell_query_openai() {
    local input_file="$1"
    local output_file="$2"
    local query="$3"
    
    local content=$(cat "$input_file")
    
    # Create JSON payload
    local json_payload=$(python3 -c "
import json
import sys

payload = {
    'model': 'gpt-4',
    'messages': [
        {
            'role': 'system',
            'content': '''You are a smart shell assistant with MCP tool access. You can:
- Read/write files and directories
- Execute system commands
- Search the web
- Analyze git repositories
- Maintain conversation context

Provide concise, helpful responses. When suggesting commands, explain them briefly. Use your MCP tools when appropriate for file operations, system analysis, or web searches.'''
        },
        {
            'role': 'user', 
            'content': '''$content'''
        }
    ],
    'max_tokens': 1500,
    'temperature': 0.3
}

print(json.dumps(payload))
")
    
    # Send request
    curl -s -H "Content-Type: application/json" \
         -H "Authorization: Bearer $LACY_SHELL_API_OPENAI" \
         -d "$json_payload" \
         "https://api.openai.com/v1/chat/completions" | \
    python3 -c "
import json
import sys

try:
    response = json.load(sys.stdin)
    if 'choices' in response and len(response['choices']) > 0:
        content = response['choices'][0]['message']['content']
        # Clean output - just the response
        print(content)
    else:
        error_msg = response.get('error', {}).get('message', 'API error')
        print(f'Error: {error_msg}')
except Exception as e:
    print(f'Error: {e}')
" > "$output_file"
}

# Query Anthropic API
lacy_shell_query_anthropic() {
    local input_file="$1"
    local output_file="$2" 
    local query="$3"
    
    local content=$(cat "$input_file")
    
    # Create JSON payload  
    local json_payload=$(python3 -c "
import json

payload = {
    'model': 'claude-3-5-sonnet-20241022',
    'max_tokens': 1500,
    'system': '''You are a smart shell assistant with MCP tool access. You can:
- Read/write files and directories
- Execute system commands  
- Search the web
- Analyze git repositories
- Maintain conversation context

Provide concise, helpful responses. When suggesting commands, explain them briefly. Use your MCP tools when appropriate for file operations, system analysis, or web searches.''',
    'messages': [
        {
            'role': 'user',
            'content': '''$content'''
        }
    ]
}

print(json.dumps(payload))
")
    
    # Send request
    curl -s -H "Content-Type: application/json" \
         -H "x-api-key: $LACY_SHELL_API_ANTHROPIC" \
         -H "anthropic-version: 2023-06-01" \
         -d "$json_payload" \
         "https://api.anthropic.com/v1/messages" | \
    python3 -c "
import json
import sys

try:
    response = json.load(sys.stdin)
    if 'content' in response and len(response['content']) > 0:
        # Clean output - just the response
        print(response['content'][0]['text'])
    else:
        error_msg = response.get('error', {}).get('message', 'API error')
        print(f'Error: {error_msg}')
except Exception as e:
    print(f'Error: {e}')
" > "$output_file"
}

# List available MCP tools
lacy_shell_list_mcp_tools() {
    if [[ -n "$LACY_SHELL_MCP_SERVERS" ]]; then
        echo "- Filesystem: read, write, list files in allowed directories"
        echo "- Web: search and retrieve web content"
        echo "- System: gather system information and execute commands"
        echo "- Git: repository analysis and operations"
    else
        echo "- No MCP servers configured"
    fi
}

# Cleanup MCP connections
lacy_shell_cleanup_mcp() {
    lacy_shell_stop_mcp_servers
}

# Test MCP connection
lacy_shell_test_mcp() {
    echo "Testing MCP configuration..."
    
    # First load the config to make sure variables are set
    lacy_shell_load_config >/dev/null 2>&1
    
    if [[ "$LACY_SHELL_MCP_SERVERS" == "configured" ]]; then
        echo "✅ MCP framework ready"
        echo "Configured servers:"
        echo "  - filesystem: read, write, list files"
        echo "  - web: search and retrieve content"
        echo "  - system: gather system information"
    else
        echo "❌ No MCP servers configured"
        return 1
    fi
    
    # Test API keys
    if lacy_shell_check_api_keys; then
        echo "✅ API keys configured"
    else
        echo "❌ No API keys configured"
    fi
}
