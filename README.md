# Texture Packer

The Texture Packer acts as a simple web dashboard, allowing players to upload their own custom textures, and have those textures then visible server wide.

Texture Packer runs on Ruby on Rails. It is licensed under the GNU GPLv3.

Currently, Texture Packer has no user authentication, so it is advised to only be run within a private network, such as a VPN like Zerotier, or over LAN.

## How to install Texture Packer

1. Make sure Ruby v3.0.2 is installed.
2. Install the gem "bundler", using `gem install bundler`
3. Clone down this repository
4. Open this repository in your terminal or command prompt, and run `bundle install`
5. Once that is installed, if there were no errors, run `rails db:migrate`

Texture Packer should now be installed.

## Running Texture Packer

Texture Packer can be started by running `rails server -p <port> -b <ip-addr>`.
Set the IP address to the same address people use to connect to your Minecraft server.
You can set the port to any port that is open.

## Setting it to work with your Minecraft Server

Set your server resource pack URL to: `http://<ip-addr>:<port>/dashboard/download`.

Due to bug [MC-164316](https://bugs.mojang.com/browse/MC-164316), Minecraft doesn't download new versions of a resource pack, if they are all hosted at the same URL. In order to fix this, I forked a simple Resource Pack downloader plugin, and made it insert a random number at the end of the URL, which forces Minecraft to redownload the pack. You can download the plugin [here](https://github.com/moxvallix/rpurl). Set the resource pack URL in the plugin's config rather than the Minecraft server's. The config will generate itself after you log in to the server, and once you have added the URL you will need to restart the server.

If you are not using a Bukkit compatible server, you can just add a `#` to the end of the server resource pack URL, followed by some random numbers. This means you will have to restart your server whenever you want to use your new textures. Example: `http://192.168.1.5:3000/dashboard/download#98584968468`
Make sure to change those numbers each time you want to refresh the packs.

To make use of your custom items in game, I would advise downloading the [Custom Roleplay Data](https://www.curseforge.com/minecraft/customization/custom-roleplay-data-datapack) datapack.
