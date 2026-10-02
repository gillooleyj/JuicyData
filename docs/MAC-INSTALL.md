# JuicyCloud for Mac: Install and Setup Guide

## What you need

JuicyCloud installs in about a minute on any Mac running macOS 12 Monterey or later, on Apple Silicon or Intel. It is a desktop mascot that floats above your windows and serves up FedRAMP 20x humor in a speech bubble.

- **Download:** the JuicyCloud installer from the [latest release](https://github.com/gillooleyj/JuicyData/releases/latest). Under **Assets**, click the file named like `JuicyCloud-1.2.dmg`.
- **Permissions:** a normal user account is fine; no admin password is needed
- **Device:** use a personal Mac. Government-furnished Macs may block apps not approved by your agency, so follow your agency's software policy.

## Install

1. Download the `JuicyCloud-1.x.dmg` file from the [latest release](https://github.com/gillooleyj/JuicyData/releases/latest) (or the copy you were sent). It lands in your **Downloads** folder.
2. Double-click the `.dmg` file. A window opens showing the JuicyCloud icon and an **Applications** folder.
3. Drag the **JuicyCloud** icon onto the **Applications** folder.
4. Close that window, then eject the installer: in Finder's sidebar, click the eject button next to **JuicyCloud**. You can delete the `.dmg` file afterward.
5. Open JuicyCloud: press **Command + Space**, type `JuicyCloud`, and press **Return**. You can also double-click it in your Applications folder.
6. The first time, macOS asks whether you're sure you want to open an app downloaded from the internet. Click **Open**.

If instead you see a message that macOS cannot verify the app, you received an unsigned test build. Click **Done**, open **System Settings > Privacy & Security**, scroll down, and click **Open Anyway** next to JuicyCloud. You only do this once.

## First look

When JuicyCloud opens, the cloud appears in the bottom-right corner of your screen and greets you: "Hello! I'm the government, and I'm here to help!" A cloud icon also appears in your menu bar at the top right. JuicyCloud has no Dock icon; this is on purpose.

| To do this | Do this |
| --- | --- |
| Get a new line | Click the cloud |
| Move it | Drag it anywhere. It remembers the spot. |
| Close the speech bubble | Click the bubble |
| Open the settings menu | Right-click the cloud, or click the cloud icon in the menu bar |
| Hide it for a while | Settings menu > **Hide JuicyCloud** |
| Close it completely | Settings menu > **Quit JuicyCloud** |

## Settings

All settings live in one menu: right-click the cloud, or click the cloud icon in the menu bar. Changes take effect right away and are remembered the next time JuicyCloud opens.

| Setting | Options | Default |
| --- | --- | --- |
| Size | Small, Medium, Large | Medium |
| Chattiness (random pop-ups) | Quiet, every 5 minutes, every 15 minutes, every hour | Every 15 minutes |
| React to Apps | On or off. Comments now and then when you switch into Excel, Word, PowerPoint, Outlook, Mail, Teams, Slack, Terminal, or VS Code, at most once every 10 minutes. | On |
| Speech | Off, Only When Clicked, All Lines. Uses a recorded AI voice. | Off |

## Turn on the voice

The voice is off until you turn it on. **Only When Clicked** is the best choice for work, since the cloud stays quiet during meetings unless you click it.

1. Open the settings menu and choose **Speech**.
2. Choose **Only When Clicked** or **All Lines**. The cloud confirms out loud.
3. That's it. Every line is recorded with an AI voice (made with ElevenLabs), so it sounds natural with nothing to download.

## Start it automatically at login

1. Open **System Settings > General > Login Items & Extensions**. On older macOS versions this is called **Login Items**.
2. Under **Open at Login**, click **+**.
3. Choose **JuicyCloud** from your Applications folder and click **Open**.

To stop it from starting automatically, select JuicyCloud in that list and click **-**.

## Update or uninstall

**To update to a new version:**

1. Quit JuicyCloud from the settings menu.
2. Download the newest `.dmg` from the [latest release](https://github.com/gillooleyj/JuicyData/releases/latest), open it, and drag JuicyCloud onto **Applications** again.
3. When asked, click **Replace**. Your settings are kept.

**To uninstall:**

1. Quit JuicyCloud from the settings menu.
2. Drag **JuicyCloud** from your Applications folder to the Trash.
3. Optional: older versions created a `~/.juicycloud` folder for custom lines, which you can delete (Finder > **Go > Go to Folder**). To clear saved settings, run this in Terminal:

```
defaults delete com.cooeytools.juicycloud
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| I can't see the cloud | Click the cloud icon in the menu bar and choose **Show JuicyCloud**. If it's still missing, it may be on a disconnected display: quit it, run `defaults delete com.cooeytools.juicycloud origin` in Terminal, and reopen it. It returns to the bottom-right corner. |
| It doesn't talk | Speech is off by default. Turn it on under **Speech**, and check that your Mac's volume is up. |
| It never reacts when I switch apps | Check that **React to Apps** is on. It comments only about half the time, and at most once every 10 minutes. |
| macOS says it can't verify the app | Open **System Settings > Privacy & Security** and click **Open Anyway** next to JuicyCloud. |
| It won't install on my work Mac | Your agency's device management may block it. Use a personal Mac. |

Still stuck? Contact the person who sent you the installer, or [open an issue](https://github.com/gillooleyj/JuicyData/issues) on GitHub.
