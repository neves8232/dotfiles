cdf() {
  local show_hidden=false
  local eza_base_flags=(-lh --group-directories-first --color=always)
  local use_icons=false
  local is_zsh=false
  if [ -n "$ZSH_VERSION" ]; then
    is_zsh=true
  fi
  for arg in "$@"; do
    case "$arg" in
    -a | --all)
      show_hidden=true
      ;;
    -h | --help)
      echo "Uso: cdf [-a]"
      echo "  -a, --all    Mostrar ficheiros e directórios ocultos"
      echo ""
      echo "Navegação dentro do fzf:"
      echo "  Enter: entrar em directório ou abrir ficheiro"
      echo "  Ctrl-u: subir para directório pai"
      echo "  Ctrl-p: alternar pré-visualização"
      echo "  Esc: sair"
      return 0
      ;;
    *)
      echo "Opção inválida: $arg" >&2
      echo "Use 'cdf -h' para ajuda"
      return 1
      ;;
    esac
  done
  while true; do
    local current_path=$(pwd)
    local path_display="${current_path/#$HOME/\~}"
    local max_prompt_len=30
    if ((${#path_display} > max_prompt_len)); then
      path_display="…${path_display: -$((max_prompt_len - 1))}"
    fi
    local term_height=$(tput lines)
    local term_width=$(tput cols)
    if command -v eza >/dev/null 2>&1; then
      if ((term_width >= 60)); then
        use_icons=true
        if $show_hidden; then
          eza_base_flags=(-lah --group-directories-first --icons --color=always)
        else
          eza_base_flags=(-lh --group-directories-first --icons --color=always)
        fi
      else
        use_icons=false
        if $show_hidden; then
          eza_base_flags=(-lah --group-directories-first --color=always)
        else
          eza_base_flags=(-lh --group-directories-first --color=always)
        fi
      fi
    else
      use_icons=false
    fi
    local items=""
    if [ "$current_path" != "/" ]; then
      items=".."$'\n'
    fi
    if command -v eza >/dev/null 2>&1 && ((term_width >= 60)); then
      items+=$(eza "${eza_base_flags[@]}" 2>/dev/null | tail -n +2)
    else
      if $show_hidden; then
        items+=$(ls -A1 2>/dev/null)
      else
        items+=$(ls -1 2>/dev/null | sed '/^\./d')
      fi
    fi
    local preview_position
    if ((term_height < 25 || term_width < 80)); then
      preview_position="down:40%"
    else
      preview_position="right:50%"
    fi
    local preview_cmd="
      ph=\$(tput lines 2>/dev/null || echo 24)
      if (( ph < 30 )); then
        preview_lines=5
      else
        preview_lines=10
      fi
      item=\$(echo {} | awk '{print \$NF}')
      if [ \"\$item\" = \"..\" ]; then
        parent=\$(dirname \"\$(pwd)\")
        echo \"⬆️  Directório pai: \$parent\"
        echo
        echo \"Conteúdo (até \$preview_lines linhas):\"
        if command -v eza >/dev/null 2>&1; then
          eza -lah --color=always \"\$parent\" 2>/dev/null | head -n \$preview_lines
        else
          ls -la \"\$parent\" 2>/dev/null | head -n \$preview_lines
        fi
      elif [ -d \"\$item\" ]; then
        echo \"📁 \$item/\"
        echo
        echo \"Conteúdo (até \$preview_lines linhas):\"
        if command -v eza >/dev/null 2>&1; then
          eza -lah --color=always \"\$item\" 2>/dev/null | head -n \$preview_lines
        else
          ls -la \"\$item\" 2>/dev/null | head -n \$preview_lines
        fi
      elif [ -f \"\$item\" ]; then
        size=\$(stat -f%z \"\$item\" 2>/dev/null || stat -c%s \"\$item\" 2>/dev/null)
        if command -v numfmt >/dev/null 2>&1; then
          hsize=\$(numfmt --to=iec \"\$size\" 2>/dev/null)
        else
          hsize=\$size
        fi
        echo \"📄 \$item (\$hsize bytes)\"
        ftype=\$(file -b \"\$item\" 2>/dev/null)
        echo \"🔍 \$ftype\"
        if file \"\$item\" 2>/dev/null | grep -qE \"text|ASCII|UTF-8\"; then
          echo
          echo \"📖 Pré-visualização (até \$preview_lines linhas):\"
          head -n \$preview_lines \"\$item\" 2>/dev/null
        fi
      fi
    "
    local fzf_height="--height=80%"
    local fzf_layout="--layout=reverse"
    local prompt_suffix=""
    if $show_hidden; then
      prompt_suffix=" (incluindo ocultos)"
    fi
    local fzf_prompt="📁 [${path_display}]${prompt_suffix} > "
    local selection
    selection=$(
      printf "%s\n" "$items" |
        fzf --ansi --exact $fzf_height $fzf_layout \
          --prompt="$fzf_prompt" \
          --bind="ctrl-u:execute-silent(echo ..)+accept" \
          --bind="ctrl-p:toggle-preview" \
          --preview="$preview_cmd" \
          --preview-window="$preview_position" \
          --header="Enter: entrar directório / abrir ficheiro | Ctrl-u: pai | Ctrl-p: toggle pré-visualização | Esc: sair"
    )
    if [ -z "$selection" ]; then
      break
    fi
    local item_sel
    item_sel=$(echo "$selection" | awk '{print $NF}')
    if [ "$item_sel" = ".." ]; then
      cd .. 2>/dev/null || break
    elif [ -d "$item_sel" ]; then
      cd "$item_sel" 2>/dev/null || echo "Não foi possível entrar em '$item_sel'"
    elif [ -f "$item_sel" ]; then
      ${EDITOR:-nvim} "$item_sel"
    fi
  done
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cdf "$@"
fi
