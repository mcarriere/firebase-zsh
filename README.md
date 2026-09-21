# firebase-zsh :fire: 

firebase-zsh is a configurable plugin for Zsh that displays the Firebase environment currently selected with `firebase use` when you're inside a Firebase project directory or one of its subdirectories. Never push to production accidentally again!

![](https://i.imgur.com/wGwuTH7.png)

## Features

- Shows the **selected environment** (alias) — e.g. `dev`, `staging`, `prod` — resolved from your `.firebaserc` aliases
- Works whether you selected an alias (`firebase use staging`) or a raw project id (`firebase use my-project`): raw ids are resolved back to their alias when one exists
- **Hidden entirely** when no environment has been explicitly selected with `firebase use`
- At the **project root**, lists any submodules whose selected env differs from the root's — e.g. `dev watson:prod`

## Installation

Clone the repository into your oh-my-zsh plugin folder:

`git clone https://github.com/mcarriere/firebase-zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/firebase`

Then add it to your list of plugins in your `~/.zshrc`

`plugins=(git firebase)`

## Adding it to your prompt

### Classic `PROMPT` / oh-my-zsh themes

Open your theme and add the `firebase_project` output.

For example, 

`PROMPT='%{$fg[cyan]%}%n%{$reset_color%}:$(git_prompt_info) %(!.#.$) '`

becomes

`PROMPT='%{$fg[cyan]%}%n%{$reset_color%}:$(firebase_project) $(git_prompt_info)%(!.#.$) '`

### Powerlevel10k

Add a user-defined segment to your `~/.p10k.zsh`:

```zsh
function prompt_firebase() {
  p10k segment -t "$(firebase_project)" -c "$(firebase_project)"
}
```

and reference it by adding `firebase` to `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` (or `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`).

Restart Zsh for the changes to take effect.

## How the environment is resolved

1. The `activeProjects` entry for your current directory in `~/.config/configstore/firebase-tools.json` (set by `firebase use <project-or-alias>`)
2. If that value is a raw project id, the alias in `.firebaserc` that points to it is displayed instead
3. If no selection exists for the current directory, the prompt segment is not shown

## Configuration

firebase-zsh has a few customisation options to get it to fit with whatever theme you are using. These can be configured through environment variables. These options are:

### `FIREBASE_ZSH_TEXT`
Configures the font style of the text.

Options:
- `bold` - makes the text bold

Defaults to **non-bold**

### `FIREBASE_ZSH_ICON`
Whether or not to show the 🔥 icon.

Options:
- `true`

Defaults to **false**

### `FIREBASE_ZSH_STYLE`
The format of the text itself to help match with your current zsh theme.

Options:
- `plain`: output as `my-firebase-project`
- `round`: output as `(my-firebase-project)`
- `square`: output as `[my-firebase-project]`
- `prefix`: output as `fb:my-firebase-project`
- `prefix-round`: output as `fb:(my-firebase-project)`
- `prefix-square`: output as `fb:[my-firebase-project]`

Defaults to **round**

### `FIREBASE_ZSH_TRAILING_SPACE`
Adds a trailing space to the output.

### `FIREBASE_ZSH_LEADING_SPACE`
Adds a leading space to the output.

## Contributing

Changes are welcomed. If you have an issue, please feel free to raise it in the issues section. If you wish to make a contribution, please create a corresponding issue. 

## License 
[MIT](https://choosealicense.com/licenses/mit/)
