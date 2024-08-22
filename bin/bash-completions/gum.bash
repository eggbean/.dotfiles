# bash completion for gum                                  -*- shell-script -*-

__gum_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__gum_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__gum_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__gum_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__gum_handle_go_custom_completion()
{
    __gum_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly gum allows to handle aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="GUM_ACTIVE_HELP=0 ${words[0]} completion completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __gum_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __gum_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __gum_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __gum_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __gum_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __gum_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __gum_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __gum_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __gum_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __gum_debug "Listing directories in $subdir"
            __gum_handle_subdirs_in_dir_flag "$subdir"
        else
            __gum_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__gum_handle_reply()
{
    __gum_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __gum_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __gum_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __gum_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __gum_custom_func >/dev/null; then
            # try command name qualified custom func
            __gum_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__gum_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__gum_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__gum_handle_flag()
{
    __gum_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __gum_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __gum_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __gum_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __gum_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __gum_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__gum_handle_noun()
{
    __gum_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __gum_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __gum_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__gum_handle_command()
{
    __gum_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_gum_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __gum_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__gum_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __gum_handle_reply
        return
    fi
    __gum_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __gum_handle_flag
    elif __gum_contains_word "${words[c]}" "${commands[@]}"; then
        __gum_handle_command
    elif [[ $c -eq 0 ]]; then
        __gum_handle_command
    elif __gum_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __gum_handle_command
        else
            __gum_handle_noun
        fi
    else
        __gum_handle_noun
    fi
    __gum_handle_word
}

_gum_choose()
{
    last_command="gum_choose"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--limit")
    flags+=("--no-limit")
    flags+=("--ordered")
    flags+=("--height")
    flags+=("--cursor=")
    two_word_flags+=("--cursor")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--cursor-prefix=")
    two_word_flags+=("--cursor-prefix")
    flags+=("--selected-prefix=")
    two_word_flags+=("--selected-prefix")
    flags+=("--unselected-prefix=")
    two_word_flags+=("--unselected-prefix")
    flags+=("--selected")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.border=")
    two_word_flags+=("--cursor.border")
    flags+=("--cursor.border-background=")
    two_word_flags+=("--cursor.border-background")
    flags+=("--cursor.border-foreground=")
    two_word_flags+=("--cursor.border-foreground")
    flags+=("--cursor.align=")
    two_word_flags+=("--cursor.align")
    flags+=("--cursor.height")
    flags+=("--cursor.width")
    flags+=("--cursor.margin=")
    two_word_flags+=("--cursor.margin")
    flags+=("--cursor.padding=")
    two_word_flags+=("--cursor.padding")
    flags+=("--cursor.bold")
    flags+=("--cursor.faint")
    flags+=("--cursor.italic")
    flags+=("--cursor.strikethrough")
    flags+=("--cursor.underline")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.border=")
    two_word_flags+=("--header.border")
    flags+=("--header.border-background=")
    two_word_flags+=("--header.border-background")
    flags+=("--header.border-foreground=")
    two_word_flags+=("--header.border-foreground")
    flags+=("--header.align=")
    two_word_flags+=("--header.align")
    flags+=("--header.height")
    flags+=("--header.width")
    flags+=("--header.margin=")
    two_word_flags+=("--header.margin")
    flags+=("--header.padding=")
    two_word_flags+=("--header.padding")
    flags+=("--header.bold")
    flags+=("--header.faint")
    flags+=("--header.italic")
    flags+=("--header.strikethrough")
    flags+=("--header.underline")
    flags+=("--item.background=")
    two_word_flags+=("--item.background")
    flags+=("--item.foreground=")
    two_word_flags+=("--item.foreground")
    flags+=("--item.border=")
    two_word_flags+=("--item.border")
    flags+=("--item.border-background=")
    two_word_flags+=("--item.border-background")
    flags+=("--item.border-foreground=")
    two_word_flags+=("--item.border-foreground")
    flags+=("--item.align=")
    two_word_flags+=("--item.align")
    flags+=("--item.height")
    flags+=("--item.width")
    flags+=("--item.margin=")
    two_word_flags+=("--item.margin")
    flags+=("--item.padding=")
    two_word_flags+=("--item.padding")
    flags+=("--item.bold")
    flags+=("--item.faint")
    flags+=("--item.italic")
    flags+=("--item.strikethrough")
    flags+=("--item.underline")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.border=")
    two_word_flags+=("--selected.border")
    flags+=("--selected.border-background=")
    two_word_flags+=("--selected.border-background")
    flags+=("--selected.border-foreground=")
    two_word_flags+=("--selected.border-foreground")
    flags+=("--selected.align=")
    two_word_flags+=("--selected.align")
    flags+=("--selected.height")
    flags+=("--selected.width")
    flags+=("--selected.margin=")
    two_word_flags+=("--selected.margin")
    flags+=("--selected.padding=")
    two_word_flags+=("--selected.padding")
    flags+=("--selected.bold")
    flags+=("--selected.faint")
    flags+=("--selected.italic")
    flags+=("--selected.strikethrough")
    flags+=("--selected.underline")

    noun_aliases=()
}

_gum_confirm()
{
    last_command="gum_confirm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--affirmative=")
    two_word_flags+=("--affirmative")
    flags+=("--negative=")
    two_word_flags+=("--negative")
    flags+=("--default")
    flags+=("--timeout")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.border=")
    two_word_flags+=("--prompt.border")
    flags+=("--prompt.border-background=")
    two_word_flags+=("--prompt.border-background")
    flags+=("--prompt.border-foreground=")
    two_word_flags+=("--prompt.border-foreground")
    flags+=("--prompt.align=")
    two_word_flags+=("--prompt.align")
    flags+=("--prompt.height")
    flags+=("--prompt.width")
    flags+=("--prompt.margin=")
    two_word_flags+=("--prompt.margin")
    flags+=("--prompt.padding=")
    two_word_flags+=("--prompt.padding")
    flags+=("--prompt.bold")
    flags+=("--prompt.faint")
    flags+=("--prompt.italic")
    flags+=("--prompt.strikethrough")
    flags+=("--prompt.underline")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.border=")
    two_word_flags+=("--selected.border")
    flags+=("--selected.border-background=")
    two_word_flags+=("--selected.border-background")
    flags+=("--selected.border-foreground=")
    two_word_flags+=("--selected.border-foreground")
    flags+=("--selected.align=")
    two_word_flags+=("--selected.align")
    flags+=("--selected.height")
    flags+=("--selected.width")
    flags+=("--selected.margin=")
    two_word_flags+=("--selected.margin")
    flags+=("--selected.padding=")
    two_word_flags+=("--selected.padding")
    flags+=("--selected.bold")
    flags+=("--selected.faint")
    flags+=("--selected.italic")
    flags+=("--selected.strikethrough")
    flags+=("--selected.underline")
    flags+=("--unselected.background=")
    two_word_flags+=("--unselected.background")
    flags+=("--unselected.foreground=")
    two_word_flags+=("--unselected.foreground")
    flags+=("--unselected.border=")
    two_word_flags+=("--unselected.border")
    flags+=("--unselected.border-background=")
    two_word_flags+=("--unselected.border-background")
    flags+=("--unselected.border-foreground=")
    two_word_flags+=("--unselected.border-foreground")
    flags+=("--unselected.align=")
    two_word_flags+=("--unselected.align")
    flags+=("--unselected.height")
    flags+=("--unselected.width")
    flags+=("--unselected.margin=")
    two_word_flags+=("--unselected.margin")
    flags+=("--unselected.padding=")
    two_word_flags+=("--unselected.padding")
    flags+=("--unselected.bold")
    flags+=("--unselected.faint")
    flags+=("--unselected.italic")
    flags+=("--unselected.strikethrough")
    flags+=("--unselected.underline")

    noun_aliases=()
}

_gum_file()
{
    last_command="gum_file"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cursor=")
    two_word_flags+=("--cursor")
    two_word_flags+=("-c")
    flags+=("--all")
    flags+=("-a")
    flags+=("--file")
    flags+=("--directory")
    flags+=("--height")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.border=")
    two_word_flags+=("--cursor.border")
    flags+=("--cursor.border-background=")
    two_word_flags+=("--cursor.border-background")
    flags+=("--cursor.border-foreground=")
    two_word_flags+=("--cursor.border-foreground")
    flags+=("--cursor.align=")
    two_word_flags+=("--cursor.align")
    flags+=("--cursor.height")
    flags+=("--cursor.width")
    flags+=("--cursor.margin=")
    two_word_flags+=("--cursor.margin")
    flags+=("--cursor.padding=")
    two_word_flags+=("--cursor.padding")
    flags+=("--cursor.bold")
    flags+=("--cursor.faint")
    flags+=("--cursor.italic")
    flags+=("--cursor.strikethrough")
    flags+=("--cursor.underline")
    flags+=("--symlink.background=")
    two_word_flags+=("--symlink.background")
    flags+=("--symlink.foreground=")
    two_word_flags+=("--symlink.foreground")
    flags+=("--symlink.border=")
    two_word_flags+=("--symlink.border")
    flags+=("--symlink.border-background=")
    two_word_flags+=("--symlink.border-background")
    flags+=("--symlink.border-foreground=")
    two_word_flags+=("--symlink.border-foreground")
    flags+=("--symlink.align=")
    two_word_flags+=("--symlink.align")
    flags+=("--symlink.height")
    flags+=("--symlink.width")
    flags+=("--symlink.margin=")
    two_word_flags+=("--symlink.margin")
    flags+=("--symlink.padding=")
    two_word_flags+=("--symlink.padding")
    flags+=("--symlink.bold")
    flags+=("--symlink.faint")
    flags+=("--symlink.italic")
    flags+=("--symlink.strikethrough")
    flags+=("--symlink.underline")
    flags+=("--directory.background=")
    two_word_flags+=("--directory.background")
    flags+=("--directory.foreground=")
    two_word_flags+=("--directory.foreground")
    flags+=("--directory.border=")
    two_word_flags+=("--directory.border")
    flags+=("--directory.border-background=")
    two_word_flags+=("--directory.border-background")
    flags+=("--directory.border-foreground=")
    two_word_flags+=("--directory.border-foreground")
    flags+=("--directory.align=")
    two_word_flags+=("--directory.align")
    flags+=("--directory.height")
    flags+=("--directory.width")
    flags+=("--directory.margin=")
    two_word_flags+=("--directory.margin")
    flags+=("--directory.padding=")
    two_word_flags+=("--directory.padding")
    flags+=("--directory.bold")
    flags+=("--directory.faint")
    flags+=("--directory.italic")
    flags+=("--directory.strikethrough")
    flags+=("--directory.underline")
    flags+=("--file.background=")
    two_word_flags+=("--file.background")
    flags+=("--file.foreground=")
    two_word_flags+=("--file.foreground")
    flags+=("--file.border=")
    two_word_flags+=("--file.border")
    flags+=("--file.border-background=")
    two_word_flags+=("--file.border-background")
    flags+=("--file.border-foreground=")
    two_word_flags+=("--file.border-foreground")
    flags+=("--file.align=")
    two_word_flags+=("--file.align")
    flags+=("--file.height")
    flags+=("--file.width")
    flags+=("--file.margin=")
    two_word_flags+=("--file.margin")
    flags+=("--file.padding=")
    two_word_flags+=("--file.padding")
    flags+=("--file.bold")
    flags+=("--file.faint")
    flags+=("--file.italic")
    flags+=("--file.strikethrough")
    flags+=("--file.underline")
    flags+=("--permissions.background=")
    two_word_flags+=("--permissions.background")
    flags+=("--permissions.foreground=")
    two_word_flags+=("--permissions.foreground")
    flags+=("--permissions.border=")
    two_word_flags+=("--permissions.border")
    flags+=("--permissions.border-background=")
    two_word_flags+=("--permissions.border-background")
    flags+=("--permissions.border-foreground=")
    two_word_flags+=("--permissions.border-foreground")
    flags+=("--permissions.align=")
    two_word_flags+=("--permissions.align")
    flags+=("--permissions.height")
    flags+=("--permissions.width")
    flags+=("--permissions.margin=")
    two_word_flags+=("--permissions.margin")
    flags+=("--permissions.padding=")
    two_word_flags+=("--permissions.padding")
    flags+=("--permissions.bold")
    flags+=("--permissions.faint")
    flags+=("--permissions.italic")
    flags+=("--permissions.strikethrough")
    flags+=("--permissions.underline")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.border=")
    two_word_flags+=("--selected.border")
    flags+=("--selected.border-background=")
    two_word_flags+=("--selected.border-background")
    flags+=("--selected.border-foreground=")
    two_word_flags+=("--selected.border-foreground")
    flags+=("--selected.align=")
    two_word_flags+=("--selected.align")
    flags+=("--selected.height")
    flags+=("--selected.width")
    flags+=("--selected.margin=")
    two_word_flags+=("--selected.margin")
    flags+=("--selected.padding=")
    two_word_flags+=("--selected.padding")
    flags+=("--selected.bold")
    flags+=("--selected.faint")
    flags+=("--selected.italic")
    flags+=("--selected.strikethrough")
    flags+=("--selected.underline")
    flags+=("--file-size.background=")
    two_word_flags+=("--file-size.background")
    flags+=("--file-size.foreground=")
    two_word_flags+=("--file-size.foreground")
    flags+=("--file-size.border=")
    two_word_flags+=("--file-size.border")
    flags+=("--file-size.border-background=")
    two_word_flags+=("--file-size.border-background")
    flags+=("--file-size.border-foreground=")
    two_word_flags+=("--file-size.border-foreground")
    flags+=("--file-size.align=")
    two_word_flags+=("--file-size.align")
    flags+=("--file-size.height")
    flags+=("--file-size.width")
    flags+=("--file-size.margin=")
    two_word_flags+=("--file-size.margin")
    flags+=("--file-size.padding=")
    two_word_flags+=("--file-size.padding")
    flags+=("--file-size.bold")
    flags+=("--file-size.faint")
    flags+=("--file-size.italic")
    flags+=("--file-size.strikethrough")
    flags+=("--file-size.underline")

    noun_aliases=()
}

_gum_filter()
{
    last_command="gum_filter"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--indicator=")
    two_word_flags+=("--indicator")
    flags+=("--indicator.background=")
    two_word_flags+=("--indicator.background")
    flags+=("--indicator.foreground=")
    two_word_flags+=("--indicator.foreground")
    flags+=("--indicator.border=")
    two_word_flags+=("--indicator.border")
    flags+=("--indicator.border-background=")
    two_word_flags+=("--indicator.border-background")
    flags+=("--indicator.border-foreground=")
    two_word_flags+=("--indicator.border-foreground")
    flags+=("--indicator.align=")
    two_word_flags+=("--indicator.align")
    flags+=("--indicator.height")
    flags+=("--indicator.width")
    flags+=("--indicator.margin=")
    two_word_flags+=("--indicator.margin")
    flags+=("--indicator.padding=")
    two_word_flags+=("--indicator.padding")
    flags+=("--indicator.bold")
    flags+=("--indicator.faint")
    flags+=("--indicator.italic")
    flags+=("--indicator.strikethrough")
    flags+=("--indicator.underline")
    flags+=("--limit")
    flags+=("--no-limit")
    flags+=("--strict")
    flags+=("--selected-prefix=")
    two_word_flags+=("--selected-prefix")
    flags+=("--selected-indicator.background=")
    two_word_flags+=("--selected-indicator.background")
    flags+=("--selected-indicator.foreground=")
    two_word_flags+=("--selected-indicator.foreground")
    flags+=("--selected-indicator.border=")
    two_word_flags+=("--selected-indicator.border")
    flags+=("--selected-indicator.border-background=")
    two_word_flags+=("--selected-indicator.border-background")
    flags+=("--selected-indicator.border-foreground=")
    two_word_flags+=("--selected-indicator.border-foreground")
    flags+=("--selected-indicator.align=")
    two_word_flags+=("--selected-indicator.align")
    flags+=("--selected-indicator.height")
    flags+=("--selected-indicator.width")
    flags+=("--selected-indicator.margin=")
    two_word_flags+=("--selected-indicator.margin")
    flags+=("--selected-indicator.padding=")
    two_word_flags+=("--selected-indicator.padding")
    flags+=("--selected-indicator.bold")
    flags+=("--selected-indicator.faint")
    flags+=("--selected-indicator.italic")
    flags+=("--selected-indicator.strikethrough")
    flags+=("--selected-indicator.underline")
    flags+=("--unselected-prefix=")
    two_word_flags+=("--unselected-prefix")
    flags+=("--unselected-prefix.background=")
    two_word_flags+=("--unselected-prefix.background")
    flags+=("--unselected-prefix.foreground=")
    two_word_flags+=("--unselected-prefix.foreground")
    flags+=("--unselected-prefix.border=")
    two_word_flags+=("--unselected-prefix.border")
    flags+=("--unselected-prefix.border-background=")
    two_word_flags+=("--unselected-prefix.border-background")
    flags+=("--unselected-prefix.border-foreground=")
    two_word_flags+=("--unselected-prefix.border-foreground")
    flags+=("--unselected-prefix.align=")
    two_word_flags+=("--unselected-prefix.align")
    flags+=("--unselected-prefix.height")
    flags+=("--unselected-prefix.width")
    flags+=("--unselected-prefix.margin=")
    two_word_flags+=("--unselected-prefix.margin")
    flags+=("--unselected-prefix.padding=")
    two_word_flags+=("--unselected-prefix.padding")
    flags+=("--unselected-prefix.bold")
    flags+=("--unselected-prefix.faint")
    flags+=("--unselected-prefix.italic")
    flags+=("--unselected-prefix.strikethrough")
    flags+=("--unselected-prefix.underline")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.border=")
    two_word_flags+=("--header.border")
    flags+=("--header.border-background=")
    two_word_flags+=("--header.border-background")
    flags+=("--header.border-foreground=")
    two_word_flags+=("--header.border-foreground")
    flags+=("--header.align=")
    two_word_flags+=("--header.align")
    flags+=("--header.height")
    flags+=("--header.width")
    flags+=("--header.margin=")
    two_word_flags+=("--header.margin")
    flags+=("--header.padding=")
    two_word_flags+=("--header.padding")
    flags+=("--header.bold")
    flags+=("--header.faint")
    flags+=("--header.italic")
    flags+=("--header.strikethrough")
    flags+=("--header.underline")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--text.background=")
    two_word_flags+=("--text.background")
    flags+=("--text.foreground=")
    two_word_flags+=("--text.foreground")
    flags+=("--text.border=")
    two_word_flags+=("--text.border")
    flags+=("--text.border-background=")
    two_word_flags+=("--text.border-background")
    flags+=("--text.border-foreground=")
    two_word_flags+=("--text.border-foreground")
    flags+=("--text.align=")
    two_word_flags+=("--text.align")
    flags+=("--text.height")
    flags+=("--text.width")
    flags+=("--text.margin=")
    two_word_flags+=("--text.margin")
    flags+=("--text.padding=")
    two_word_flags+=("--text.padding")
    flags+=("--text.bold")
    flags+=("--text.faint")
    flags+=("--text.italic")
    flags+=("--text.strikethrough")
    flags+=("--text.underline")
    flags+=("--match.background=")
    two_word_flags+=("--match.background")
    flags+=("--match.foreground=")
    two_word_flags+=("--match.foreground")
    flags+=("--match.border=")
    two_word_flags+=("--match.border")
    flags+=("--match.border-background=")
    two_word_flags+=("--match.border-background")
    flags+=("--match.border-foreground=")
    two_word_flags+=("--match.border-foreground")
    flags+=("--match.align=")
    two_word_flags+=("--match.align")
    flags+=("--match.height")
    flags+=("--match.width")
    flags+=("--match.margin=")
    two_word_flags+=("--match.margin")
    flags+=("--match.padding=")
    two_word_flags+=("--match.padding")
    flags+=("--match.bold")
    flags+=("--match.faint")
    flags+=("--match.italic")
    flags+=("--match.strikethrough")
    flags+=("--match.underline")
    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.border=")
    two_word_flags+=("--prompt.border")
    flags+=("--prompt.border-background=")
    two_word_flags+=("--prompt.border-background")
    flags+=("--prompt.border-foreground=")
    two_word_flags+=("--prompt.border-foreground")
    flags+=("--prompt.align=")
    two_word_flags+=("--prompt.align")
    flags+=("--prompt.height")
    flags+=("--prompt.width")
    flags+=("--prompt.margin=")
    two_word_flags+=("--prompt.margin")
    flags+=("--prompt.padding=")
    two_word_flags+=("--prompt.padding")
    flags+=("--prompt.bold")
    flags+=("--prompt.faint")
    flags+=("--prompt.italic")
    flags+=("--prompt.strikethrough")
    flags+=("--prompt.underline")
    flags+=("--width")
    flags+=("--height")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--reverse")
    flags+=("--fuzzy")

    noun_aliases=()
}

_gum_format()
{
    last_command="gum_format"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--theme=")
    two_word_flags+=("--theme")
    flags+=("--language=")
    two_word_flags+=("--language")
    two_word_flags+=("-l")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")

    noun_aliases=()
}

_gum_input()
{
    last_command="gum_input"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.border=")
    two_word_flags+=("--prompt.border")
    flags+=("--prompt.border-background=")
    two_word_flags+=("--prompt.border-background")
    flags+=("--prompt.border-foreground=")
    two_word_flags+=("--prompt.border-foreground")
    flags+=("--prompt.align=")
    two_word_flags+=("--prompt.align")
    flags+=("--prompt.height")
    flags+=("--prompt.width")
    flags+=("--prompt.margin=")
    two_word_flags+=("--prompt.margin")
    flags+=("--prompt.padding=")
    two_word_flags+=("--prompt.padding")
    flags+=("--prompt.bold")
    flags+=("--prompt.faint")
    flags+=("--prompt.italic")
    flags+=("--prompt.strikethrough")
    flags+=("--prompt.underline")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.border=")
    two_word_flags+=("--cursor.border")
    flags+=("--cursor.border-background=")
    two_word_flags+=("--cursor.border-background")
    flags+=("--cursor.border-foreground=")
    two_word_flags+=("--cursor.border-foreground")
    flags+=("--cursor.align=")
    two_word_flags+=("--cursor.align")
    flags+=("--cursor.height")
    flags+=("--cursor.width")
    flags+=("--cursor.margin=")
    two_word_flags+=("--cursor.margin")
    flags+=("--cursor.padding=")
    two_word_flags+=("--cursor.padding")
    flags+=("--cursor.bold")
    flags+=("--cursor.faint")
    flags+=("--cursor.italic")
    flags+=("--cursor.strikethrough")
    flags+=("--cursor.underline")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--char-limit")
    flags+=("--width")
    flags+=("--password")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.border=")
    two_word_flags+=("--header.border")
    flags+=("--header.border-background=")
    two_word_flags+=("--header.border-background")
    flags+=("--header.border-foreground=")
    two_word_flags+=("--header.border-foreground")
    flags+=("--header.align=")
    two_word_flags+=("--header.align")
    flags+=("--header.height")
    flags+=("--header.width")
    flags+=("--header.margin=")
    two_word_flags+=("--header.margin")
    flags+=("--header.padding=")
    two_word_flags+=("--header.padding")
    flags+=("--header.bold")
    flags+=("--header.faint")
    flags+=("--header.italic")
    flags+=("--header.strikethrough")
    flags+=("--header.underline")

    noun_aliases=()
}

_gum_join()
{
    last_command="gum_join"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--align=")
    two_word_flags+=("--align")
    flags+=("--horizontal")
    flags+=("--vertical")

    noun_aliases=()
}

_gum_pager()
{
    last_command="gum_pager"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--background=")
    two_word_flags+=("--background")
    flags+=("--foreground=")
    two_word_flags+=("--foreground")
    flags+=("--border=")
    two_word_flags+=("--border")
    flags+=("--border-background=")
    two_word_flags+=("--border-background")
    flags+=("--border-foreground=")
    two_word_flags+=("--border-foreground")
    flags+=("--align=")
    two_word_flags+=("--align")
    flags+=("--height")
    flags+=("--width")
    flags+=("--margin=")
    two_word_flags+=("--margin")
    flags+=("--padding=")
    two_word_flags+=("--padding")
    flags+=("--bold")
    flags+=("--faint")
    flags+=("--italic")
    flags+=("--strikethrough")
    flags+=("--underline")
    flags+=("--help.background=")
    two_word_flags+=("--help.background")
    flags+=("--help.foreground=")
    two_word_flags+=("--help.foreground")
    flags+=("--help.border=")
    two_word_flags+=("--help.border")
    flags+=("--help.border-background=")
    two_word_flags+=("--help.border-background")
    flags+=("--help.border-foreground=")
    two_word_flags+=("--help.border-foreground")
    flags+=("--help.align=")
    two_word_flags+=("--help.align")
    flags+=("--help.height")
    flags+=("--help.width")
    flags+=("--help.margin=")
    two_word_flags+=("--help.margin")
    flags+=("--help.padding=")
    two_word_flags+=("--help.padding")
    flags+=("--help.bold")
    flags+=("--help.faint")
    flags+=("--help.italic")
    flags+=("--help.strikethrough")
    flags+=("--help.underline")
    flags+=("--show-line-numbers")
    flags+=("--line-number.background=")
    two_word_flags+=("--line-number.background")
    flags+=("--line-number.foreground=")
    two_word_flags+=("--line-number.foreground")
    flags+=("--line-number.border=")
    two_word_flags+=("--line-number.border")
    flags+=("--line-number.border-background=")
    two_word_flags+=("--line-number.border-background")
    flags+=("--line-number.border-foreground=")
    two_word_flags+=("--line-number.border-foreground")
    flags+=("--line-number.align=")
    two_word_flags+=("--line-number.align")
    flags+=("--line-number.height")
    flags+=("--line-number.width")
    flags+=("--line-number.margin=")
    two_word_flags+=("--line-number.margin")
    flags+=("--line-number.padding=")
    two_word_flags+=("--line-number.padding")
    flags+=("--line-number.bold")
    flags+=("--line-number.faint")
    flags+=("--line-number.italic")
    flags+=("--line-number.strikethrough")
    flags+=("--line-number.underline")
    flags+=("--soft-wrap")

    noun_aliases=()
}

_gum_spin()
{
    last_command="gum_spin"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--show-output")
    flags+=("--spinner=")
    two_word_flags+=("--spinner")
    two_word_flags+=("-s")
    flags+=("--spinner.background=")
    two_word_flags+=("--spinner.background")
    flags+=("--spinner.foreground=")
    two_word_flags+=("--spinner.foreground")
    flags+=("--spinner.border=")
    two_word_flags+=("--spinner.border")
    flags+=("--spinner.border-background=")
    two_word_flags+=("--spinner.border-background")
    flags+=("--spinner.border-foreground=")
    two_word_flags+=("--spinner.border-foreground")
    flags+=("--spinner.align=")
    two_word_flags+=("--spinner.align")
    flags+=("--spinner.height")
    flags+=("--spinner.width")
    flags+=("--spinner.margin=")
    two_word_flags+=("--spinner.margin")
    flags+=("--spinner.padding=")
    two_word_flags+=("--spinner.padding")
    flags+=("--spinner.bold")
    flags+=("--spinner.faint")
    flags+=("--spinner.italic")
    flags+=("--spinner.strikethrough")
    flags+=("--spinner.underline")
    flags+=("--title=")
    two_word_flags+=("--title")
    flags+=("--title.background=")
    two_word_flags+=("--title.background")
    flags+=("--title.foreground=")
    two_word_flags+=("--title.foreground")
    flags+=("--title.border=")
    two_word_flags+=("--title.border")
    flags+=("--title.border-background=")
    two_word_flags+=("--title.border-background")
    flags+=("--title.border-foreground=")
    two_word_flags+=("--title.border-foreground")
    flags+=("--title.align=")
    two_word_flags+=("--title.align")
    flags+=("--title.height")
    flags+=("--title.width")
    flags+=("--title.margin=")
    two_word_flags+=("--title.margin")
    flags+=("--title.padding=")
    two_word_flags+=("--title.padding")
    flags+=("--title.bold")
    flags+=("--title.faint")
    flags+=("--title.italic")
    flags+=("--title.strikethrough")
    flags+=("--title.underline")
    flags+=("--align=")
    two_word_flags+=("--align")
    two_word_flags+=("-a")

    noun_aliases=()
}

_gum_style()
{
    last_command="gum_style"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--background=")
    two_word_flags+=("--background")
    flags+=("--foreground=")
    two_word_flags+=("--foreground")
    flags+=("--border=")
    two_word_flags+=("--border")
    flags+=("--border-background=")
    two_word_flags+=("--border-background")
    flags+=("--border-foreground=")
    two_word_flags+=("--border-foreground")
    flags+=("--align=")
    two_word_flags+=("--align")
    flags+=("--height")
    flags+=("--width")
    flags+=("--margin=")
    two_word_flags+=("--margin")
    flags+=("--padding=")
    two_word_flags+=("--padding")
    flags+=("--bold")
    flags+=("--faint")
    flags+=("--italic")
    flags+=("--strikethrough")
    flags+=("--underline")

    noun_aliases=()
}

_gum_table()
{
    last_command="gum_table"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--separator=")
    two_word_flags+=("--separator")
    two_word_flags+=("-s")
    flags+=("--columns")
    flags+=("-c")
    flags+=("--widths")
    flags+=("-w")
    flags+=("--height")
    flags+=("--cell.background=")
    two_word_flags+=("--cell.background")
    flags+=("--cell.foreground=")
    two_word_flags+=("--cell.foreground")
    flags+=("--cell.border=")
    two_word_flags+=("--cell.border")
    flags+=("--cell.border-background=")
    two_word_flags+=("--cell.border-background")
    flags+=("--cell.border-foreground=")
    two_word_flags+=("--cell.border-foreground")
    flags+=("--cell.align=")
    two_word_flags+=("--cell.align")
    flags+=("--cell.height")
    flags+=("--cell.width")
    flags+=("--cell.margin=")
    two_word_flags+=("--cell.margin")
    flags+=("--cell.padding=")
    two_word_flags+=("--cell.padding")
    flags+=("--cell.bold")
    flags+=("--cell.faint")
    flags+=("--cell.italic")
    flags+=("--cell.strikethrough")
    flags+=("--cell.underline")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.border=")
    two_word_flags+=("--header.border")
    flags+=("--header.border-background=")
    two_word_flags+=("--header.border-background")
    flags+=("--header.border-foreground=")
    two_word_flags+=("--header.border-foreground")
    flags+=("--header.align=")
    two_word_flags+=("--header.align")
    flags+=("--header.height")
    flags+=("--header.width")
    flags+=("--header.margin=")
    two_word_flags+=("--header.margin")
    flags+=("--header.padding=")
    two_word_flags+=("--header.padding")
    flags+=("--header.bold")
    flags+=("--header.faint")
    flags+=("--header.italic")
    flags+=("--header.strikethrough")
    flags+=("--header.underline")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.border=")
    two_word_flags+=("--selected.border")
    flags+=("--selected.border-background=")
    two_word_flags+=("--selected.border-background")
    flags+=("--selected.border-foreground=")
    two_word_flags+=("--selected.border-foreground")
    flags+=("--selected.align=")
    two_word_flags+=("--selected.align")
    flags+=("--selected.height")
    flags+=("--selected.width")
    flags+=("--selected.margin=")
    two_word_flags+=("--selected.margin")
    flags+=("--selected.padding=")
    two_word_flags+=("--selected.padding")
    flags+=("--selected.bold")
    flags+=("--selected.faint")
    flags+=("--selected.italic")
    flags+=("--selected.strikethrough")
    flags+=("--selected.underline")
    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")

    noun_aliases=()
}

_gum_write()
{
    last_command="gum_write"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--width")
    flags+=("--height")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--show-cursor-line")
    flags+=("--show-line-numbers")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--char-limit")
    flags+=("--base.background=")
    two_word_flags+=("--base.background")
    flags+=("--base.foreground=")
    two_word_flags+=("--base.foreground")
    flags+=("--base.border=")
    two_word_flags+=("--base.border")
    flags+=("--base.border-background=")
    two_word_flags+=("--base.border-background")
    flags+=("--base.border-foreground=")
    two_word_flags+=("--base.border-foreground")
    flags+=("--base.align=")
    two_word_flags+=("--base.align")
    flags+=("--base.height")
    flags+=("--base.width")
    flags+=("--base.margin=")
    two_word_flags+=("--base.margin")
    flags+=("--base.padding=")
    two_word_flags+=("--base.padding")
    flags+=("--base.bold")
    flags+=("--base.faint")
    flags+=("--base.italic")
    flags+=("--base.strikethrough")
    flags+=("--base.underline")
    flags+=("--cursor-line-number.background=")
    two_word_flags+=("--cursor-line-number.background")
    flags+=("--cursor-line-number.foreground=")
    two_word_flags+=("--cursor-line-number.foreground")
    flags+=("--cursor-line-number.border=")
    two_word_flags+=("--cursor-line-number.border")
    flags+=("--cursor-line-number.border-background=")
    two_word_flags+=("--cursor-line-number.border-background")
    flags+=("--cursor-line-number.border-foreground=")
    two_word_flags+=("--cursor-line-number.border-foreground")
    flags+=("--cursor-line-number.align=")
    two_word_flags+=("--cursor-line-number.align")
    flags+=("--cursor-line-number.height")
    flags+=("--cursor-line-number.width")
    flags+=("--cursor-line-number.margin=")
    two_word_flags+=("--cursor-line-number.margin")
    flags+=("--cursor-line-number.padding=")
    two_word_flags+=("--cursor-line-number.padding")
    flags+=("--cursor-line-number.bold")
    flags+=("--cursor-line-number.faint")
    flags+=("--cursor-line-number.italic")
    flags+=("--cursor-line-number.strikethrough")
    flags+=("--cursor-line-number.underline")
    flags+=("--cursor-line.background=")
    two_word_flags+=("--cursor-line.background")
    flags+=("--cursor-line.foreground=")
    two_word_flags+=("--cursor-line.foreground")
    flags+=("--cursor-line.border=")
    two_word_flags+=("--cursor-line.border")
    flags+=("--cursor-line.border-background=")
    two_word_flags+=("--cursor-line.border-background")
    flags+=("--cursor-line.border-foreground=")
    two_word_flags+=("--cursor-line.border-foreground")
    flags+=("--cursor-line.align=")
    two_word_flags+=("--cursor-line.align")
    flags+=("--cursor-line.height")
    flags+=("--cursor-line.width")
    flags+=("--cursor-line.margin=")
    two_word_flags+=("--cursor-line.margin")
    flags+=("--cursor-line.padding=")
    two_word_flags+=("--cursor-line.padding")
    flags+=("--cursor-line.bold")
    flags+=("--cursor-line.faint")
    flags+=("--cursor-line.italic")
    flags+=("--cursor-line.strikethrough")
    flags+=("--cursor-line.underline")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.border=")
    two_word_flags+=("--cursor.border")
    flags+=("--cursor.border-background=")
    two_word_flags+=("--cursor.border-background")
    flags+=("--cursor.border-foreground=")
    two_word_flags+=("--cursor.border-foreground")
    flags+=("--cursor.align=")
    two_word_flags+=("--cursor.align")
    flags+=("--cursor.height")
    flags+=("--cursor.width")
    flags+=("--cursor.margin=")
    two_word_flags+=("--cursor.margin")
    flags+=("--cursor.padding=")
    two_word_flags+=("--cursor.padding")
    flags+=("--cursor.bold")
    flags+=("--cursor.faint")
    flags+=("--cursor.italic")
    flags+=("--cursor.strikethrough")
    flags+=("--cursor.underline")
    flags+=("--end-of-buffer.background=")
    two_word_flags+=("--end-of-buffer.background")
    flags+=("--end-of-buffer.foreground=")
    two_word_flags+=("--end-of-buffer.foreground")
    flags+=("--end-of-buffer.border=")
    two_word_flags+=("--end-of-buffer.border")
    flags+=("--end-of-buffer.border-background=")
    two_word_flags+=("--end-of-buffer.border-background")
    flags+=("--end-of-buffer.border-foreground=")
    two_word_flags+=("--end-of-buffer.border-foreground")
    flags+=("--end-of-buffer.align=")
    two_word_flags+=("--end-of-buffer.align")
    flags+=("--end-of-buffer.height")
    flags+=("--end-of-buffer.width")
    flags+=("--end-of-buffer.margin=")
    two_word_flags+=("--end-of-buffer.margin")
    flags+=("--end-of-buffer.padding=")
    two_word_flags+=("--end-of-buffer.padding")
    flags+=("--end-of-buffer.bold")
    flags+=("--end-of-buffer.faint")
    flags+=("--end-of-buffer.italic")
    flags+=("--end-of-buffer.strikethrough")
    flags+=("--end-of-buffer.underline")
    flags+=("--line-number.background=")
    two_word_flags+=("--line-number.background")
    flags+=("--line-number.foreground=")
    two_word_flags+=("--line-number.foreground")
    flags+=("--line-number.border=")
    two_word_flags+=("--line-number.border")
    flags+=("--line-number.border-background=")
    two_word_flags+=("--line-number.border-background")
    flags+=("--line-number.border-foreground=")
    two_word_flags+=("--line-number.border-foreground")
    flags+=("--line-number.align=")
    two_word_flags+=("--line-number.align")
    flags+=("--line-number.height")
    flags+=("--line-number.width")
    flags+=("--line-number.margin=")
    two_word_flags+=("--line-number.margin")
    flags+=("--line-number.padding=")
    two_word_flags+=("--line-number.padding")
    flags+=("--line-number.bold")
    flags+=("--line-number.faint")
    flags+=("--line-number.italic")
    flags+=("--line-number.strikethrough")
    flags+=("--line-number.underline")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.border=")
    two_word_flags+=("--header.border")
    flags+=("--header.border-background=")
    two_word_flags+=("--header.border-background")
    flags+=("--header.border-foreground=")
    two_word_flags+=("--header.border-foreground")
    flags+=("--header.align=")
    two_word_flags+=("--header.align")
    flags+=("--header.height")
    flags+=("--header.width")
    flags+=("--header.margin=")
    two_word_flags+=("--header.margin")
    flags+=("--header.padding=")
    two_word_flags+=("--header.padding")
    flags+=("--header.bold")
    flags+=("--header.faint")
    flags+=("--header.italic")
    flags+=("--header.strikethrough")
    flags+=("--header.underline")
    flags+=("--placeholder.background=")
    two_word_flags+=("--placeholder.background")
    flags+=("--placeholder.foreground=")
    two_word_flags+=("--placeholder.foreground")
    flags+=("--placeholder.border=")
    two_word_flags+=("--placeholder.border")
    flags+=("--placeholder.border-background=")
    two_word_flags+=("--placeholder.border-background")
    flags+=("--placeholder.border-foreground=")
    two_word_flags+=("--placeholder.border-foreground")
    flags+=("--placeholder.align=")
    two_word_flags+=("--placeholder.align")
    flags+=("--placeholder.height")
    flags+=("--placeholder.width")
    flags+=("--placeholder.margin=")
    two_word_flags+=("--placeholder.margin")
    flags+=("--placeholder.padding=")
    two_word_flags+=("--placeholder.padding")
    flags+=("--placeholder.bold")
    flags+=("--placeholder.faint")
    flags+=("--placeholder.italic")
    flags+=("--placeholder.strikethrough")
    flags+=("--placeholder.underline")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.border=")
    two_word_flags+=("--prompt.border")
    flags+=("--prompt.border-background=")
    two_word_flags+=("--prompt.border-background")
    flags+=("--prompt.border-foreground=")
    two_word_flags+=("--prompt.border-foreground")
    flags+=("--prompt.align=")
    two_word_flags+=("--prompt.align")
    flags+=("--prompt.height")
    flags+=("--prompt.width")
    flags+=("--prompt.margin=")
    two_word_flags+=("--prompt.margin")
    flags+=("--prompt.padding=")
    two_word_flags+=("--prompt.padding")
    flags+=("--prompt.bold")
    flags+=("--prompt.faint")
    flags+=("--prompt.italic")
    flags+=("--prompt.strikethrough")
    flags+=("--prompt.underline")

    noun_aliases=()
}

_gum_root_command()
{
    last_command="gum"

    command_aliases=()

    commands=()
    commands+=("choose")
    commands+=("confirm")
    commands+=("file")
    commands+=("filter")
    commands+=("format")
    commands+=("input")
    commands+=("join")
    commands+=("pager")
    commands+=("spin")
    commands+=("style")
    commands+=("table")
    commands+=("write")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    flags+=("--version")
    flags+=("-v")

    noun_aliases=()
}

__start_gum()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __gum_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("gum")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __gum_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_gum gum
else
    complete -o default -o nospace -F __start_gum gum
fi

# ex: ts=4 sw=4 et filetype=sh
