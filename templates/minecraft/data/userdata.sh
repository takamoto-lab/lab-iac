#!/bin/bash
mkdir -p /data
mkfs -t ext4 /dev/xvdf
echo "/dev/xvdf	/data	ext4	defaults,nofail	0	2" >> /etc/fstab
mount -a

apt update
apt-get -y install openjdk-8-jdk-headless screen

wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar

BASE_DIR=/opt/minecraft/server

mkdir -p "${BASE_DIR}"
mv server.jar "${BASE_DIR}/minecraft_server.1.16.5.jar"

cd "${BASE_DIR}"
java -jar "minecraft_server.1.16.5.jar" --nogui
sed -i s/eula=false/eula=true/g eula.txt

echo "#!/bin/bash" > "${BASE_DIR}/start.sh"
echo """
java -Xms1G -Xmx1G -jar ${BASE_DIR}/minecraft_server.1.16.5.jar --nogui
""" >> "${BASE_DIR}/start.sh"
chmod +x "${BASE_DIR}/start.sh"

echo """
[Unit]
Description=Minecraft Server Service
After=network.target

[Service]
Type=forking
User=root
Group=root
WorkingDirectory=${BASE_DIR}
ExecStart=${BASE_DIR}/start.sh
# ExecStop=${BASE_DIR}/stop.sh
Restart=always
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
""" > /usr/lib/systemd/system/minecraft.service

systemctl daemon-reload
systemctl enable minecraft
systemctl start minecraft
