<p align="center">
  <img src="logos/alien.png" alt="alien_" width="120" />
</p>

<h1 align="center">alien_</h1>

<p align="center">
  One small app that installs, updates and removes all my other apps.<br/>
  Install <b>alien_</b> once. Everything else is a tap away.
</p>

<p align="center">
  <a href="https://github.com/YOUR_USERNAME/alien_/releases/download/latest/alien.apk">
    <img src="https://img.shields.io/badge/DOWNLOAD-alien__-B9F23A?style=for-the-badge&logo=android&logoColor=black" alt="Download alien_" />
  </a>
</p>

<p align="center">
  <sub>Android 7.0+ · 64-bit phones (almost every phone made in the last several years) · free</sub>
</p>

---

## What is this?

**alien_** is a mini app store for my own apps. It shows every app in one list and tells you which ones
are installed and which have a newer version. The buttons then do the rest:

| Button | What it does |
|---|---|
| **INSTALL** | downloads and installs the app |
| **UPDATE TO x.y.z** | downloads and installs the newer version, keeping your data |
| **OPEN** | opens the app |
| **… → Uninstall** | removes the app |

alien_ also updates itself. You only need to download it once.

---

## Install in 4 steps

1. **Tap the green DOWNLOAD button above** on your Android phone.
2. **Open the downloaded file** (`alien.apk`) and tap **Install**. Android will show a few warnings;
   see [the warnings below](#-android-says-its-harmful-this-is-normal). They are normal for apps that
   don't come from the Play Store.
3. **Open alien_** and wait a moment. The list of apps loads.
4. **Tap INSTALL** on any app you want. Done.

From now on, open alien_ whenever you want to update something.

---

## Apps

<table>
  <tr>
    <td align="center" valign="top" width="33%">
      <img src="logos/music.png" width="80" alt="music_" /><br/>
      <b>music_</b><br/>
      <sub>Local music player</sub><br/><br/>
      <a href="https://github.com/YOUR_USERNAME/alien_/releases/download/latest/music.apk">
        <img src="https://img.shields.io/badge/DOWNLOAD-APK-B9F23A?style=for-the-badge&logo=android&logoColor=black" alt="Download music_" />
      </a>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="logos/track.png" width="80" alt="track_" /><br/>
      <b>track_</b><br/>
      <sub>Personal tracker</sub><br/><br/>
      <a href="https://github.com/YOUR_USERNAME/alien_/releases/download/latest/track.apk">
        <img src="https://img.shields.io/badge/DOWNLOAD-APK-B9F23A?style=for-the-badge&logo=android&logoColor=black" alt="Download track_" />
      </a>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="logos/movie.png" width="80" alt="movie_" /><br/>
      <b>movie_</b><br/>
      <sub>Track and discover movies</sub><br/><br/>
      <a href="https://github.com/YOUR_USERNAME/alien_/releases/download/latest/movie.apk">
        <img src="https://img.shields.io/badge/DOWNLOAD-APK-B9F23A?style=for-the-badge&logo=android&logoColor=black" alt="Download movie_" />
      </a>
    </td>
  </tr>
</table>

> 💡 You don't need to download these one by one. Install **alien_** above and install them from inside it.
> The buttons here are for people who only want a single app.

---

## ⚠️ Android says it's "harmful"? This is normal

These apps are not on the Play Store, so Android and Chrome show warnings for any app installed from a file.
Here's what you may see and what to tap:

**1. Chrome: "This type of file can harm your device"**
Tap **OK** / **Download anyway** / **Keep**.

**2. Android: "For your security, your phone isn't allowed to install unknown apps from this source"**
Tap **Settings**, switch on **Allow from this source**, then go back and tap **Install**.
(You do this once for your browser, and once for alien_ the first time it installs an app.)

**3. Google Play Protect: "App blocked to protect your device" or "Unsafe app blocked"**
Tap **More details**, then **Install anyway**.
Or tap **Install without scanning**, if you see that instead.

**4. "Do you want to install this app?"**
Tap **Install**.

> **Is it safe?** The apps are made by me and signed with my own key. They show the warnings above only because
> they aren't from the Play Store. Only install apps from people you trust.

---

## FAQ

**Do I need to do this for every app?**
No. Download alien_ once, then install everything else from inside it.

**How do I update an app?**
Open alien_. Apps with a newer version show **UPDATE TO …**. Tap it. There is also an **UPDATE N APPS** button for all at once.

**Will updating delete my data?**
No. Updates install on top of the existing app and keep its data.

**Installing says "App not installed" or "conflicts with an existing package".**
An older copy of the app came from somewhere else (for example a test build). Uninstall that copy once, then install again from alien_.

**Which phones work?**
Android 7.0 or newer on a 64-bit ARM phone, which covers almost every phone sold in the last several years.

**Does alien_ spy on me?**
No. alien_ only reads this repository (the app list and releases) from GitHub and checks which of my apps are installed on your phone.

---

<details>
<summary><b>For me: how releases work</b></summary>

<br/>

**Each version is a GitHub Release with this tag format:**

| App | Tag | Example |
|---|---|---|
| alien_ | `v` + version | `v0.0.5` |
| music_ | `music` + `v` + version | `musicv0.0.2` |
| track_ | `track` + `v` + version | `trackv0.1.0` |

The tag is the left part of `pubspec.yaml`'s version (`0.0.2+2` → `0.0.2`). The APK must be attached.
alien_ reads these releases to know what is newest.

**The `latest` release is only for the download buttons.** It holds one fixed-name copy of the newest APK of each app
(`alien.apk`, `music.apk`, …), so the buttons in this README never need editing. alien_ ignores it.

Create it once:
```
gh release create latest --repo YOUR_USERNAME/alien_ --prerelease \
  --title "Latest downloads" --notes "Newest APK of every app. Don't delete."
```
After each normal release, refresh its copy:
```
cp build/app/outputs/flutter-apk/app-release.apk music.apk
gh release upload latest music.apk --repo YOUR_USERNAME/alien_ --clobber
```

**Adding an app:** put `logos/<id>.png` in this repo, add an entry to `apps.json`, publish its first release,
and add a cell to the table above.

</details>

---

<p align="center">
  <sub>Made by alien · the source code is private, the apps are free</sub>
</p>
