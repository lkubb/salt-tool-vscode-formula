# Vscode Formula
Sets up, configures and updates VSCode.

## Usage
Applying `tool-vscode` will make sure `vscode` is configured as specified.

### Execution module and state
This formula provides a custom execution module and state to manage VSCode extensions. The functions are self-explanatory, please see the source code for comments. Currently, the following states are supported:
* `vscode.installed(name, user)`
* `vscode.absent(name, user)`

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-vscode` pillar configuration. Namespace it to `tool:users` and/or `tool:vscode:users`.
```yaml
user:
  xdg: true                         # force xdg dirs
  dotconfig: true                   # sync this user's config from a dotfiles repo available as salt://dotconfig/<user>/vscode or salt://dotconfig/vscode
  persistenv: '.config/zsh/zshenv'  # persist env vars specified in salt to this file (will be appended to file relative to $HOME)
  rchook: '.config/zsh/zshrc'       # add runcom hooks to this file (will be appended to file relative to $HOME)
  vscode:
    extensions:
      - ms-vscode.cpptools
```

#### Formula-specific
```yaml
tool:
  vscode:
    defaults:                           # default formula configuration for all users
      extensions:
        - ms-vscode.go
```

### Dotfiles
`tool-vscode.configsync` will recursively apply templates from 

- `salt://dotconfig/<user>/vscode` or
- `salt://dotconfig/vscode`

to the user's config dir for every user that has it enabled (see `user.dotconfig`). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).


## Todo
This formula has not been tested and mostly exists as documentation atm. Especially the dotfiles and xdg parts might be flaky.
