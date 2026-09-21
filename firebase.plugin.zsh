function firebase_project() {
	local project_id=$(get_firebase_project)

	if [[ -n $project_id ]]
	then
		## Set color
		[[ "$FIREBASE_ZSH_TEXT" = "bold" ]] && color=$fg_bold[yellow] || color=$fg[yellow]

		local fire="\U1F525"
		if [[ "$FIREBASE_ZSH_ICON" == "true" ]]
		then
			project_id="$fire $project_id"
		fi

		project_id=$(decorate_str "$project_id" "$FIREBASE_ZSH_STYLE")
		
		### Set Prompt  ###
		project_id="%{$color%}"$project_id"%{$reset_color%}"

		# Add trailing space
		if [[ "$FIREBASE_ZSH_TRAILING_SPACE" == "true" ]]
		then
			echo "$project_id "
		elif [[ "$FIREBASE_ZSH_LEADING_SPACE" == "true" ]]
		then
			echo " $project_id"
		else
			echo $project_id
		fi
	fi
}

function decorate_str() {
	local project_id=$1
	local style=$2

	if [[ $style == 'plain' ]]
	then
		echo "$project_id"

	# [project]
	elif [[ $style == 'square' ]]
	then
		echo "[$project_id]"

	# fb:project
	elif [[ $style == 'prefix' ]]
	then
		echo "fb:$project_id"

	# fb:(project)
	elif [[ $style == 'prefix-round' ]]
	then
		echo "fb:($project_id)"

	# fb:[project]
	elif [[ $style == 'prefix-square' ]]
	then
		echo "fb:[$project_id]"

	# (project)
	else 			
		echo "($project_id)"
	fi
}

function get_firebase_project() {
	if [[ $(is_firebase_project) ]]
	then		
		# Check the global firebase config file as priority
		local config_project_id=$(get_config_project_id)
		if [[ -n $config_project_id ]]
		then
			# Show the selected env (alias) when one is set, e.g. "firebase use staging"
			local project_alias=$(get_firebase_env "$config_project_id")
			local out=${project_alias:-$config_project_id}

			# At the project root: append modules whose env differs from the root's
			if [[ $(pwd -P) == $(get_firebase_dir) ]]
			then
				local modules_diff=$(get_modules_env_diff "$out")
				[[ -n $modules_diff ]] && out="$out $modules_diff"
			fi

			echo "$out"
		fi
		# No explicit "firebase use" selection -> show nothing
	fi
}

function get_modules_env_diff() {
	local root_env=$1
	local root=$(get_firebase_dir)

	sed -n '/"activeProjects"[[:space:]]*:[[:space:]]*{/,/^[[:space:]]*}/p' ~/.config/configstore/firebase-tools.json \
		| grep -Eos "\"$root/[^\"]+\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
		| awk -F'"' -v root_env="$root_env" '{
				n = split($2, a, "/")
				module = a[n]
				if ($4 != root_env && !seen[module]++) {
					out = out (out ? " " : "") module ":" $4
				}
			}
			END { print out }'
}

function is_firebase_project() {
	local firebase_dir=$(get_firebase_dir)
	if [[ -n $firebase_dir ]]
	then
		echo 1
	fi
}

function get_firebase_dir() {
	local dir="$(pwd)"
	
	# Keep checking up, we may be in a subdir
	while [[ $dir != '/' ]]
	do
		local target="$dir/firebase.json"

		if [[ -e $target ]]
		then
				echo ${dir:A}
				break
		else
				dir=$(dirname ${dir:A})
		fi
	done
}

function get_config_project_id() {
	if [[ -e ~/.config/configstore/firebase-tools.json ]]
	then
		# May be either the project id itself or an alias (which lives in .firebaserc)
		# Scope to the activeProjects block: other sections (activeAccounts, etc.) reuse dir keys
		local target=$(get_firebase_dir)
		sed -n '/"activeProjects"[[:space:]]*:[[:space:]]*{/,/^[[:space:]]*}/p' ~/.config/configstore/firebase-tools.json \
			| grep -Eos "\"$target\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
			| head -n 1 | cut -d'"' -f 4
	fi
}

function get_firebase_env() {
	local rc_path="$(get_firebase_dir)/.firebaserc"

	# The active selection may be an alias itself (e.g. "firebase use staging")
	if grep -qs "\"$1\"[[:space:]]*:" "$rc_path"
	then
		echo "$1"
		return
	fi

	# Otherwise, resolve the alias that points to this project id
	grep -Eos "\"[^\"]+\"[[:space:]]*:[[:space:]]*\"$1\"" "$rc_path" | head -n 1 | cut -d'"' -f 2
}