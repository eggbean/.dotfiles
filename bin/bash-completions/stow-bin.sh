_stow-bin.sh()
{
  local switches
  COMPREPLY=()
  switches=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($( compgen -W '--nosudo --unstow' -- $switches ) )
}
complete -F _stow-bin.sh stow-bin.sh
