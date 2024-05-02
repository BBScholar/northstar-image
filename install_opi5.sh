# Create pi/raspberry login
if id "$1" >/dev/null 2>&1; then
    echo 'user found'
else
    echo "creating pi user"
    useradd pi -b /home
    usermod -a -G sudo pi
    mkdir /home/pi
    chown -R pi /home/pi
fi
echo "pi:raspberry" | chpasswd

add-apt-repository ppa:liujianfeng1994/panfork-mesa            
add-apt-repository ppa:liujianfeng1994/rockchip-multimedia
apt update
apt dist-upgrade
apt install -y --no-install-recommends mali-g610-firmware rockchip-multimedia-config
# apt search rockchip | grep gstream
apt install -y --no-install-recommends gstreamer1.0-rockchip1

# Remove extra packages
echo "Purging extra things"
apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev snapd
apt-get autoremove -y

# configure hostname 
hostnamectl set-hostname northstar

# configure static ip
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
	version: 2
	renderer: networkd
	ethernets:
		eth0:
			dhcp4: no
			addresses: [10.54.19.12/24]
			routes:
				- to: default
				  via: 10.54.19.1
EOF
netplan apply

# Install necessary packages
echo "Installing packages"*
apt get install -y --no-install-recommends wget build-essential cmake make libffi-dev libssl-dev zlib1g-dev curl libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-dev gfortran openexr libatlas-base-dev clang clang++ llvm-dev

apt install -y --no-install-recommends python3-pip
apt install -y --no-install-recommends python3-pil gstreamer1.0-gl gstreamer1.0-opencv gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev

# install python deps
# pip3 install -v numpy
# pip3 install --find-links https://tortall.net/~robotpy/wheels/2023/raspbian pyntcore
# pip3 install --find-links https://tortall.net/~robotpy/wheels/2023/raspbian robotpy-wpimath==2023.4.3.1
# pip3 install -v pillow
# pip3 install -v opencv-contrib-python-headless

git clone  --depth 1 --recurse-submodules --shallow-submodules https://github.com/opencv/opencv-python.git
cd opencv-python
export ENABLE_HEADLESS=1
export CMAKE_ARGS="-DWITH_GSTREAMER=ON -DWITH_FFMPEG=OFF"
export CXX="/usr/bin/clang++"
sudo pip3 install --upgrade pip wheel
pip3 wheel . --verbose
pip3 install opencv_python*.whl
cd ..

pip3 install --extra-index-url https://wpilib.jfrog.io/artifactory/api/pypi/wpilib-python-release-2024/simple/ robotpy

python3 -c "import cv2; print(cv2.getBuildInformation())"

# Install northstar under /opt/northstar
echo "Installing Northstar"

wget -O northstar.tar.gz https://github.com/BBScholar/northstar-5419/archive/refs/heads/master.tar.gz
tar -zvxf northstar.tar.gz
cp -R northstar-5419-master/northstar /opt

rm northstar.tar.gz
rm -rf northstar-5419-master


cat > /lib/systemd/system/northstar1.service <<EOF
[Unit]
Description=Service that runs Northstar1

[Service]
WorkingDirectory=/opt/northstar
# Run photonvision at "nice" -10, which is higher priority than standard
Nice=-15
# for non-uniform CPUs, like big.LITTLE, you want to select the big cores
# look up the right values for your CPU
# AllowedCPUs=4-7

ExecStart=/usr/bin/python3  /opt/northstar/__init__.py /opt/northstar/config1.json /opt/northstar/calibration1.json
# ExecStop=/bin/systemctl kill photonvision
Type=simple
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

cat > /lib/systemd/system/northstar2.service <<EOF
[Unit]
Description=Service that runs Northstar2

[Service]
WorkingDirectory=/opt/northstar
# Run photonvision at "nice" -10, which is higher priority than standard
Nice=-15
# for non-uniform CPUs, like big.LITTLE, you want to select the big cores
# look up the right values for your CPU
# AllowedCPUs=4-7

ExecStart=/usr/bin/python3  /opt/northstar/__init__.py /opt/northstar/config2.json /opt/northstar/calibration2.json
# ExecStop=/bin/systemctl kill photonvision
Type=simple
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

cp /lib/systemd/system/northstar1.service /etc/systemd/system/northstar1.service
cp /lib/systemd/system/northstar2.service /etc/systemd/system/northstar2.service

chmod 644 /etc/systemd/system/northstar1.service
chmod 644 /etc/systemd/system/northstar2.service

systemctl daemon-reload

# systemctl enable northstar1.service
# systemctl enable northstar2.service


# Do we need any of this?
rm -rf /var/lib/apt/lists/*
apt-get clean

rm -rf /usr/share/doc
rm -rf /usr/share/locale/
