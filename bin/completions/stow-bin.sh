_stow-bin.sh()
{
  local switches
  COMPREPLY=()
  switches=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($( compgen -W '--nosudo --remove --logname' -- $switches ) )
}
complete -F _stow-bin.sh stow-bin.sh
