# MG Admin - Secure Mobile Command Line

A lightweight, secure, and mobile-friendly administration system built for Roblox games using Luau.

## Features
- **Mobile First:** Built-in floating gear button (`⚙️`) designed for mobile screens to toggle the command line and invoke the native keyboard.
- **PC Support:** Press `;` (Semicolon) on your keyboard to quick-open the input bar.
- **Server Authority:** Complete anti-exploit structure. Verification is handled strictly server-side using a hardcoded UserID dictionary.
- **Arguments Support:** Allows custom strings for commands (e.g., passing specific kick reasons).

## Built-in Commands
- `kick [player] [reason]` - Kicks the target with an optional custom message.
- `kill [player]` - Instantly kills the target.
- `punish [player]` - Makes the target invisible and disables character collisions safely.
- `bring [player]` - Teleports the target in front of you.
- `jail [player]` - Teleports the target to a secure isolated coordinate.
- `shutdown` - Safely kicks all players and shuts down the active server instance.

## Installation Guide

### 1. Server Setup
1. Create a regular **Script** inside `ServerScriptService`.
2. Paste the `server_script.luau` code into it.
3. Add your Roblox UserID into the `AllowedAdmins` dictionary at the top of the script.

### 2. Client Setup
1. Create a **LocalScript** inside `StarterPlayer` ➔ `StarterPlayerScripts`.
2. Paste the `MGCmdBar.luau` code into it.

Both scripts will automatically look for and configure the required `RemoteEvent` inside `ReplicatedStorage` upon server initialization.
