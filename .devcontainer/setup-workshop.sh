#!/bin/bash

# Create Desktop directory
mkdir -p /home/openlane/Desktop

# Download work.zip to Desktop
cd /home/openlane/Desktop
wget -O work.zip "https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/work.zip"

# Extract work.zip
unzip -q work.zip
rm work.zip

# Set PDK_ROOT in bashrc
echo "export PDK_ROOT=/home/openlane/Desktop/work/tools/openlane_working_dir/pdks" >> /home/openlane/.bashrc
echo "cd /home/openlane/Desktop/work" >> /home/openlane/.bashrc

# Create a desktop shortcut
cat > /home/openlane/Desktop/Open-Workshop.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Open Workshop
Comment=Open the workshop directory
Exec=cd /home/openlane/Desktop/work && bash
Icon=folder
Terminal=true
StartupNotify=true
EOF

chmod +x /home/openlane/Desktop/Open-Workshop.desktop

echo "Workshop setup complete! Your work folder is on the Desktop."
