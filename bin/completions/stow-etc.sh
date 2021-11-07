_stow-etc.sh()
{
  local switches
  COMPREPLY=()
  switches=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($( compgen -W '-- --remove' -- $switches ) )
}
complete -F _stow-etc.sh stow-etc.sh
