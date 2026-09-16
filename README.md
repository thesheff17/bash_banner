# bash banner

this is a custom bash script that can run every time you load a terminal or ssh into a ubuntu/debian system.

# install

I put `banner.sh` in my `~/.ssh/` directory and then add this to your `~/.bashrc` file: 

```bash
source ~/.ssh/banner.sh
```

curl command
```bash
cd ~/.ssh/
curl -O https://raw.githubusercontent.com/thesheff17/bash_banner/refs/heads/main/banner.sh
chmod +x ./banner.sh
```

wget command
```bash
cd ~/.ssh/
wget https://raw.githubusercontent.com/thesheff17/bash_banner/refs/heads/main/banner.sh
chmod +x ./banner.sh
```

# Network bandwidth monitoring

This is a little bit more of a setup because you want to make sure this does not impact your system you are running this on.  I use a tool called [vnstat](https://github.com/vergoh/vnstat) which hooks into the kernel for minimal impact.

## to install
```bash
sudo apt-get update 
sudo apt-get install -y vnstat
sudo systemctl enable vnstat
sudo systemctl start vnstat

# check status
sudo systemctl status vnstat
```

## The output is too long with the network stats
I have a `short` param you can pass to toggle on/off networking stats if you want.  add `short` to the banner script in your `~/.bashrc` file.
```bash
source ~/.ssh/banner.sh short
```