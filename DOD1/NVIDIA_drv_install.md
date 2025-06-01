```bash
lspci -k | grep -EA3 'VGA|3D|Display'
sudo dnf upgrade --refresh -y
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo akmods --force
lspci -k | grep -EA3 'VGA|3D|Display'
```

