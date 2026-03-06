# Ubuntu Desktop GUI Install

1. Create an instance  
   1. Choose Ubuntu 22.04 LTS as the operating system.  
   2. turn off ‘vTPM’ in the Shielded section for good performance  
   3. Create instance  
2. SSH to the VM

3. ### Install Ubuntu Desktop Environment:

```
sudo apt update

sudo apt install ubuntu-desktop

OR
sudo apt install ubuntu-desktop-minimal
```

   

4. Install XRDP:

```
sudo apt install xrdp
```

5. Restart the xrdp and the Server

```
sudo systemctl restart xrdp

sudo reboot
```

   

6. Reset the password of ubuntu

```
sudo passwd ubuntu
```

7. Access through microsoft remote desktop  
8. Done\!