# misctools
These are some tools I've made in the past few years. They might be useful for you too.

Many of these are written in perl or zsh. 

## iTunes lyrics finder.ps1
This PowerShell script will add lyrics to your iTunes library. You need to have the lyrics saved in a certain path and it will only try to match songs in a playlist named "Want lyrics". If lyrics are found then the song will be removed from the playlist.

I don't like iTunes for Windows that much. It works better for Mac. But I find it remarkable that Apple managed to port a big part of it's automation to COM. I couldn't find anyone doing something like this, so there you are, iTunes automation for Windows.

Where can you find the lyrics as files? Well, I don't know, but I download mines with foobar2000. I wish foobar2000 could manage my iTunes library.

## mangafox-downloader
This script will help you download any manga from MangaFox. From the manga index in your browser you'll see something like http://mangafox.me/manga/onepunch_man/, take the last part ("onepunch_man") as the manga_id.

## khdownloader
This will download an entire album from downloads.khinsider.com. Enter the download index and copy the url, just pass it as argument to this script and there you go.

## gh-downloader
Pretty much another downloader for another site.

## subsync
This tool helps you to resync a subtitle file to the timing of another file.

Say you got Spanish subtitles for an episode of Grey's Anatomy in spanish, but the timing is wrong. You also downloaded the properly synced .SRT file but it's English only. Using this tool you can sync your Spanish sub to the timing of the English one. Big deal.

