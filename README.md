<p align="center">
  <a href="https://github.com/swiftly-solution/admins">
    <img src="https://cdn.swiftlycs2.net/swiftly-logo.png" alt="SwiftlyLogo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] Admin System - Core</h3>

  <p align="center">
    A simple plugin for Swiftly that implements an Admin System.
    <br/>
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/github/downloads/swiftly-solution/admins/total" alt="Downloads"> 
  <img src="https://img.shields.io/github/contributors/swiftly-solution/admins?color=dark-green" alt="Contributors">
  <img src="https://img.shields.io/github/issues/swiftly-solution/admins" alt="Issues">
  <img src="https://img.shields.io/github/license/swiftly-solution/admins" alt="License">
</p>

---

### Installation 👀

1. Download the newest [release](https://github.com/swiftly-solution/admins/releases).
2. Everything is drag & drop, so I think you can do it!
3. Setup database connection in `addons/swiftly/configs/databases.json` with the key `swiftly_admins` like in the following example:
```json
{
    "swiftly_admins": {
        "hostname": "...",
        "username": "...",
        "password": "...",
        "database": "...",
        "port": 3306
    }
}
```
> [!WARNING]
> Don't forget to replace the `...` with the actual values !!

### Configuring the plugin 🧐

* After installing the plugin, you need to change the prefix from `addons/swiftly/configs/plugins` (optional) and if you want, you can change the messages from `addons/swiftly/translations`.

### Adding Admins ⚙️

* To add admins on server, you need to add a new row in admin tables set in `addons/swiftly/configs/plugin/admins.json` respecting the following conditions:

```
steamid => SteamID 64 of the player
flags => The flags provided below (example: abcd)
immunity => A number greater or equal than 0
```

* Or, you can use `sw_admins add` in server console, respecting the following conditions:

```
steamid => SteamID 64 of the player
username => SteamID 64 of the player
flags => The flags provided below (example: abcd)
immunity => A number greater or equal than 0
group => Optional, Group Name
```

### Admin Flags 🛡️

* Currently supported flags are the following:

| Flag | Script Name |                             Description                             |
|:----:|:---:|:-------------------------------------------------------------------:|
|   a  | ADMFLAG_RESERVATION |                            Reserved Slot                            |
|   b  | ADMFLAG_GENERIC |                     Generic Admin; Access to u@                     |
|   c  | ADMFLAG_KICK |                             Kick players                            |
|   d  | ADMFLAG_BAN |                             Ban players                             |
|   e  | ADMFLAG_UNBAN |                            Unban players                            |
|   f  | ADMFLAG_SLAY |                                 Slay                                |
|   g  | ADMFLAG_CHANGEMAP |                              Change map                             |
|   h  | ADMFLAG_CONVARS |                         Change server cvars                         |
|   i  | ADMFLAG_CONFIG |         Executes commands over plugin specific config files         |
|   j  | ADMFLAG_CHAT |               Access to private say, center say, etc.               |
|   k  | ADMFLAG_VOTE |                       Creates a vote on server                      |
|   l  | ADMFLAG_PASSWORD |                      Changes server's password                      |
|   m  | ADMFLAG_RCON |                          Use RCON commands                          |
|   n  | ADMFLAG_CHEATS | Changes sv_cheats and allows to use cheating commands (noclip, etc) |
|   z  | ADMFLAG_ROOT |                         Access to everything                        |
|   o  | ADMFLAG_CUSTOM1 |                            Custom Flag 1                            |
|   p  | ADMFLAG_CUSTOM2 |                            Custom Flag 2                            |
|   q  | ADMFLAG_CUSTOM3 |                            Custom Flag 3                            |
|   r  | ADMFLAG_CUSTOM4 |                            Custom Flag 4                            |
|   s  | ADMFLAG_CUSTOM5 |                            Custom Flag 5                            |
|   t  | ADMFLAG_CUSTOM6 |                            Custom Flag 6                            |

### Admin Exports 🛠️

The following exports are available:

|     Name    |    Arguments    |                            Description                            |
|:-----------:|:---------------:|:-----------------------------------------------------------------:|
|   HasFlags  | playerid, flags | Checks if a player has the flags provided in the second argument  |
| GetImmunity |     playerid    |                 Returns the immunity of the player                |
| HasAdminGroup | playerid, group | Checks if a player has the group provided in the second argument |
| GetAdminGroup |     playerid    |                 Returns the group of the player                |

### Admin Commands 💬

* Base commands provided by this plugin:

|      Command     |        Flag       |               Description              |
|:----------------:|:-----------------:|:--------------------------------------:|
|     !admins    |       CONSOLE     |        Admins Manager command.        |
|   !groups   |       CONSOLE     |    Groups Manager command.   |

### Creating A Pull Request 😃

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

### Have ideas/Found bugs? 💡
Join [Swiftly Discord Server](https://swiftlycs2.net/discord) and send a message in the topic from `📕╎plugins-sharing` of this plugin!

---
