# Epoch-Autologin

Enhanced login system for Project Epoch client with account management and character sorting features.

<img width="1751" height="983" alt="image" src="https://github.com/user-attachments/assets/c39b3708-af70-4600-b44e-cca8e058c095" />

Feel free to push Pull requests for any features or fixes you want. 

## Features:

- Account select panel on the login screen
- Automatically adds account saved login info to the list
- Select accounts to log in (double-click to log in directly)
- Check "Auto-login this character" in the character select screen to always automatically load into game with this character selected in future logins
- Remove saved characters and accounts with controls at the bottom
- Auto Login retry system

## Installation:
1. [Download](https://github.com/Bennylavaa/Epoch-Autologin/archive/refs/heads/master.zip)
2. Unpack the Zip file
3. Open the archive "Epoch-Autologin-main"
4. Copy the Interface folder into your Project Epoch Directory
5. Launch WoW- Enter your login and password.

## Optional:
For advanced users, you can pre-configure accounts and character sorting:

Edit `Interface/GlueXML/Config.lua`:
```lua
AutoLoginAccounts = {
  { 
    name = "account1", 
    password = "password1", 
    character = "-",  -- "-" for no auto-character, or character slot number
    characterOrder = { "character1", "character2", "character3" }
  },
  { 
    name = "account2", 
    password = "password2", 
    character = "2",  -- Auto-login to character slot 2
    characterOrder = { "character1", "character2", "character3" }
  },
}

AutologinRetry = {
    autoStart = false, -- Automatically start the autologin process
    checkInterval = 1.0,
}
```

- **`characterOrder`** - List character names in your preferred display order
- Characters not listed will appear after sorted ones in default order
- Each account can have its own unique character ordering
- Leave out `characterOrder` to use default WoW sorting

## Note:
Password is saved in plain text with XOR-based encryption under `accountName` in the /WTF/config.wtf file.

format:

```
<name> <password> <character-index?>;
```

Each entry ends with a `;` symbol. To disable character auto login, omit the third value and the space.
