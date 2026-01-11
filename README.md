# Morphe Module and APK
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/rvc_magisk)
[![CI](https://github.com/elohim-etz/morphe-builder/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/elohim-etz/morphe-builder/actions/workflows/ci.yml)

Extensive Morphe Builder

Get the [latest CI release](https://github.com/elohim-etz/morphe-builder/releases).

Use [**zygisk-detach**](https://github.com/j-hc/zygisk-detach) to detach YouTube and YT Music from Play Store if you are using modules. 

<details><summary><big>Features</big></summary>
<ul>
 <li>Support all present and future <a href="https://github.com/MorpheApp/morphe-patches">Morphe</a> apps</li>
 <li> Can build Modules and non-root APKs</li>
 <li> Updated daily with the latest versions of apps and patches</li>
 <li> Optimize APKs and modules for size</li>
 <li> Modules</li>
    <ul>
     <li> recompile invalidated odex for faster usage</li>
     <li> receive updates from Magisk app</li>
     <li> do not break safetynet or trigger root detections</li>
     <li> handle installation of the correct version of the stock app and all that</li>
     <li> support Magisk and KernelSU</li>
    </ul>
</ul>
Note that the <a href="../../actions/workflows/ci.yml">CI workflow</a> is scheduled to build the modules and APKs everyday using GitHub Actions if there is a change in Morphe patches. You may want to disable it.
</details>

## To include/exclude patches or patch other apps

 * Star the repo :eyes:
 * Use the repo as a [template](https://github.com/new?template_name=morphe-builder&template_owner=elohim-etz)
 * Customize [`config.toml`](./config.toml) using [rvmm-config-gen](https://j-hc.github.io/rvmm-config-gen/)
 * Run the build [workflow](../../actions/workflows/build.yml)
 * Grab your modules and APKs from [releases](../../releases)

also see here [`CONFIG.md`](./CONFIG.md)

## Building Locally
### On Termux
```console
bash <(curl -sSf https://raw.githubusercontent.com/elohim-etz/morphe-builder/main/build-termux.sh)
```

### On Desktop
```console
$ git clone https://github.com/elohim-etz/morphe-builder
$ cd morphe-builder
$ ./build.sh
```
