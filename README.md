# GLi GL-AR150 WiFi PINEAPPLE FIRMWARE BUILDER

all of the fancy work, none of the fancy name

---

## MAIN

### Clone

```
git clone --recursive
```
This method insures the submodules are pulled and synced.

### Run

The most common way to build the firmware is simply to run `build_pineapple.sh`. This will check for newer upstream code, download it and compile the firmware the ar-150. If your currently synced code/built firmware is at it's newest, nothing will be done. 
There is several flags you can use to though. 
- `-f` will force a build. Traditionally, if the currently synced upstream code is at it's most current, the script will not build the code if it was already build on said codebase. This will force a rebuild to take place. 
- `-c` will make a clean build. This will delete all upstream code, download the most recent (again) and compile the firmware. 

---

## TODO:

- [ ] check if openwrt-cc/files exists
