# Epoch-Autologin

Patch for the Project Epoch client that adds auto login saving features.

<img width="1751" height="980" alt="image" src="https://github.com/user-attachments/assets/a6214f9a-409a-40c7-aec6-ab55b8458547" />

## Features:

- Account select panel on the login screen
- Automatically adds account saved login info to the list
- Select accounts to log in (double-click to log in directly)
- Check "Auto-login this character" in the character select screen to always automatically load into game with this character selected in future logins
- Remove saved characters and accounts with controls at the bottom

## Installation:
1. [Download](https://github.com/Bennylavaa/Epoch-Autologin/archive/refs/heads/master.zip)
2. Unpack the Zip file
3. Open the archive "Epoch-Autologin-main"
4. Copy the Interface folder into your Project Epoch Directory
5. Launch WoW- Enter your login and password, set checked 'Remember Account Name'

## Note:
Password is saved in plain text under `accountName` in the /WTF/config.wtf file.

format:

```
<name> <password> <character-index?>;
```

Each entry ends with a `;` symbol. To disable character auto login, omit the third value and the space.
