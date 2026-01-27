# ChiLLLix Animator

A FiveM script using QBCore framework to test player animations and scenarios.

## Features

- Play GTA V animations and scenarios using simple commands
- Input dialog for easy animation name entry
- Automatic validation of animation existence
- Stop animations with a simple command
- Cleans up animations and props properly

## Installation

1. Download or clone this repository
2. Place the `chilllixhub-animator` folder in your FiveM server's `resources` directory
3. Add `ensure chilllixhub-animator` to your `server.cfg`
4. Restart your server

## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core) - QBCore Framework
- [qb-input](https://github.com/qbcore-framework/qb-input) - QBCore Input Dialog

## Usage

### Playing Animations

1. Type `/animator` in chat
2. Enter the animation name in the popup dialog
3. Click "Play" or press Enter
4. If the animation exists, it will play; otherwise, you'll see an error notification

### Stopping Animations

Type `/animator stop` in chat to stop the current animation and clean up any props.

## Examples

Try these animation names:

- `WORLD_HUMAN_CLIPBOARD` - Clipboard scenario
- `WORLD_HUMAN_MUSCLE_FREE_WEIGHTS` - Free weights scenario
- `WORLD_HUMAN_SMOKING` - Smoking scenario
- `WORLD_HUMAN_DRINKING` - Drinking scenario
- `WORLD_HUMAN_AA_COFFEE` - Coffee drinking scenario

## Configuration

Edit `config.lua` to customize:

```lua
Config.CommandName = 'animator' -- Change the command name
Config.StopCommand = 'stop' -- Change the stop subcommand
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
