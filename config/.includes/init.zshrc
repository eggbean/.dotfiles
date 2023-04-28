# # ~/.zshrc sources this file at the end if binaries have been stowed
# # (therefore no further conditional statements required)

# Don't initialise these tools a second time, as it causes
# starship to show a background job when changing directories
if [[ ! "$init_bashrc_sourced" == true ]]; then

  # Direnv hook
  eval "$(direnv hook bash)"

  # Add zoxide to shell
  # (and add directory changes to pushd stack for CD-Deluxe)
  eval "$(zoxide init bash)"

  # Set marker to say that these have already been initialised
  init_bashrc_sourced=true

fi
