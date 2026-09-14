# bash banner

this is a custom bash script that can run every time you load a terminal or ssh into a [ubuntu](https://ubuntu.com/) linux device.

# install

I put `banner.sh` in my `~/.ssh/` directory and then add this to your ~/.bashrc file: 

```bash
source ~/.ssh/banner.sh
```

curl command
```bash
cd ~/.ssh/
curl -O https://github.com/thesheff17/bash_banner/blob/main/banner.sh
```

wget command
```bash
cd ~/.ssh/
wget https://github.com/thesheff17/bash_banner/blob/main/banner.sh
```