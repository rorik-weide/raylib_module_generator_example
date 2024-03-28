
# Raylib Module Generator
This is an example of how to generate Jai bindings for [Raylib](https://github.com/raysan5/raylib).

To build the project run:
```
jai build.jai
```
Raylib module will be automatically generated from `vendor/raylib-4.5.0_win64_msvc16` if it does not exist in `local_modules`. To re-generate it simply delete the module from `local_modules`. The only important file is: `build.jai` and the only important function is `generate_raylib_module`.

Please note that this is automatically generated, there might be flaws and things might break. I only tested this on Windows.

## Copyright
- Scarfy sprite by **Eiden Marsal**
- Cyberpunk Street Environment by **Luis Zuno (@ansimuz)**
- Icon by me (Public Domain)

![Screenshot](./screenshots/Example.PNG?raw=true "Screenshot")
