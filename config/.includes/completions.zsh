# completions for zsh

nginx_ensite() {
  unfunction "$0"
  source ../../bin/bash-completions/nginx_ensite.bash
  $0 "$@"
}

nginx_dissite() {
  unfunction "$0"
  source ../../bin/bash-completions/nginx_dissite.bash
  $0 "$@"
}
