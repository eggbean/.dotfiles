#!/bin/bash

# TO DO:
# simplify using functions, including for colours

set -euo pipefail

# Set variables
if [ ! "$XDG_CONFIG_HOME" ]; then XDG_CONFIG_HOME="$HOME/.config"; fi
if [ ! "$XDG_DATA_HOME" ]; then XDG_DATA_HOME="$HOME/.local/share"; fi
declare -a shellad=()
declare -a adopted=()
declare -a hasdata=()
redc=$(tput setaf 1)
gren=$(tput setaf 2)
yelw=$(tput setaf 3)
bold=$(tput bold)
norm=$(tput sgr0)

# Print explanatory text
cat << EOF

$bold=== Config adopt script ===$norm
This script will create a dotfiles repository if it does not already exist and
then go through your shell dotfiles and application configuration directories
in \$XDG_CONFIG_HOME and ask you if you want to move them into it. It's
probably best to start with just a handful of configuration directories at
first, as it will be easier for you to manage.

EOF

read -rp "Press Enter to continue   "

# Make dotfiles repository if required
if [ ! -d ~/.dotfiles ]; then
	( mkdir ~/.dotfiles && cd ~/.dotfiles && git init )
	printf "\n%s\n" "There was no ~/.dotfiles repository, so it has been created for you"
fi
mkdir -p ~/.dotfiles/shell
mkdir -p ~/.dotfiles/config/.config
mkdir -p ~/.dotfiles/config/.local/share

# Adopt shell configuration files
pushd "$HOME" >/dev/null
for f in .bash_aliases .bash_logout .bash_profile .bashrc .inputrc .profile; do
	if [ -f $f ] && [ ! -L $f ]; then
		while read -N 1 -rp "Do you want to add your existing ~/$f to the dotfiles repostitory?   " yn; do
			printf "\n"
			case $yn in
				[Yy]* ) mv $f "$HOME/.dotfiles/shell" \
						&& shellad+=( "$f" ) \
						&& printf "\n%s%s%-9s%s%s\n" "$bold" "$gren" "MOVED:" "$norm" "$f"
						break ;;
				[Nn]* ) printf "\n%s%-9s%s%s" "$bold" "SKIPPED:" "$norm" "$f"
						break ;;
					* ) printf "\n%s%s%s\n\n" "$bold" "Answer yes or no" "$norm" ;;
			esac
		done
	fi
done

# Adopt application configuration directories
pushd "$XDG_CONFIG_HOME" >/dev/null
items=(*)
for r in "${items[@]}"; do
	if [ -L "$r" ]; then
		for i in "${!items[@]}"; do if [[ ${items[i]} == "$r" ]]; then unset 'items[i]'; fi; done
	fi
done
for t in "${items[@]}"; do
	printf "\n"
	while read -N 1 -rp "Do you want to adopt ${yelw}$t${norm} in the dotfiles repository? (y/n)   " yn; do
		case $yn in
			[Yy]* ) if [ -d "$HOME/.dotfiles/config/.config/$t" ]; then
						printf "\n%s\n" "You already have a ${yelw}$t${norm} directory in your dotfiles repository"
						while read -N 1 -rp "Do you want to delete and replace it? (y/n)   " yn; do
							case $yn in
								[Yy]* ) rm -rf "$HOME/.dotfiles/config/.config/$t" \
										&& printf "\n%s%s%-9s%s%s" "$bold" "$redc" "DELETED:" "$norm" "$HOME/.dotfiles/config/.config/$t" \
										&& mv "$t" "$HOME/.dotfiles/config/.config" \
										&& adopted+=( "$t" ) \
										&& if [ -d "$XDG_DATA_HOME/$t" ]; then hasdata+=( "$t" ); fi \
										&& printf "\n%s%s%-9s%s%s\n" "$bold" "$gren" "MOVED:" "$norm" "$t"
										break ;;
								[Nn]* ) printf "\n%s%-9s%s%s\n" "$bold" "SKIPPED:" "$norm" "$t"
										break ;;
									* ) printf "\n%s%s%s\n\n" "$bold" "Answer yes or no" "$norm" ;;
							esac
						done
					else
						mv "$t" "$HOME/.dotfiles/config/.config" \
						&& adopted+=( "$t" ) \
						&& if [ -d "$XDG_DATA_HOME/$t" ]; then hasdata+=( "$t" ); fi \
						&& printf "\n%s%s%-9s%s%s\n" "$bold" "$gren" "MOVED:" "$norm" "$t"
					fi
					break ;;
			[Nn]* ) printf "\n%s%-9s%s%s\n" "$bold" "SKIPPED:" "$norm" "$t"
					break ;;
				* ) printf "\n%s%s%s\n\n" "$bold" "Answer yes or no" "$norm";;
		esac
	done
done
printf "\n"

# Stow adopted files and print summaries of results
pushd "$HOME/.dotfiles" >/dev/null

if [ "${#shellad[@]}" -gt 0 ]; then
	stow -St ~ shell
	echo "These shell configuration files were stowed to the dotfiles repository:"
	for a in "${shellad[@]}"; do
		printf "\t%s%s%s\n" "$yelw" "$a" "$norm"
	done
	printf "\n"
fi

if [ "${#adopted[@]}" -gt 0 ]; then
	stow -St ~ config
	echo "These configurations were stowed to the dotfiles repository:"
	for b in "${adopted[@]}"; do
		printf "\t%s%s%s\n" "$yelw" "$b" "$norm"
	done
	printf "\n"
fi

if [ "${#hasdata[@]}" -gt 0 ]; then
	echo "These programs also have directories in \$XDG_DATA_HOME which you may want to look at:"
	for c in "${hasdata[@]}"; do
		printf "\t%s%s%s\n" "$yelw" "$c" "$norm"
	done
	printf "\n"
fi

printf "%s%s%s\n\n" "$bold" "Finished." "$norm"
exit
