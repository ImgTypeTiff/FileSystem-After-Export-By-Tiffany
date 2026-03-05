# FileSystem-After-Export-By-Tiffany

I originally created this for my Godot-Terminal By Tiffany plugin, but it's super cool so here's the code.

Aren't you tired of Godot's filesystem just breaking after export? Don't you want to be able to *dynamically* load files? Make a filesystem (that works after export) that **isn't** fake?



## Well, I have a solution!



By detecting changes in the Godot filesystem, I was able to create my OWN filesystem! You might be wondering, "*When will I EVER have a use for this.*" Good question. No idea.



## How does it work?

I created a editor script that is triggered by plugin.gd every time the filesystem changes. The editor script recursively scans all folders and files, and creates a recursive dictionary (dictionary in a dictionary) from it. The dictionary is found in the filesystem folder, in file\_registry.gd.

