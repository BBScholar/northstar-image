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

apt-get update

# Remove extra packages
echo "Purging extra things"
apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev snapd
# apt-get remove -y snapd
apt-get autoremove -y

# Install necessary packages
echo "Installing packages"
apt-get install -y wget build-essential cmake libffi-dev libssl-dev zlib1g-dev curl
apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-dev gfortran openexr libatlas-base-dev
apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base libgstreamer-plugins-bad1.0-dev  gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-gl
apt-get install -y clang python3 python3-pip

# install python deps
pip3 install -v numpy
pip3 install --find-links https://tortall.net/~robotpy/wheels/2023/raspbian pyntcore
pip3 install --find-links https://tortall.net/~robotpy/wheels/2023/raspbian robotpy-wpimath==2023.4.3.1
pip3 install -v pillow

# download and install opencv 
echo "Downloading and installing opencv"
wget -O opencv.tar.gz https://github.com/opencv/opencv/archive/refs/tags/4.6.0.tar.gz
wget -O opencv_contrib.tar.gz https://github.com/opencv/opencv_contrib/archive/refs/tags/4.6.0.tar.gz
tar -zvxf opencv.tar.gz
tar -zvxf opencv_contrib.tar.gz

cd opencv-4.6.0
mkdir build
cd build 

# cmake -DCMAKE_TOOLCHAIN_FILE=/RobotCode2024/vision/opencv-4.6.0/platforms/linux/aarch64-gnu.toolchain.cmake -DWITH_GSTREAMER=ON -DWITH_FFMPEG=OFF -DPYTHON3_EXECUTABLE="/python3-build/bin/python3" -DPYTHON3_LIBRARIES="/python3-host/lib/libpython3.10.so" -DPYTHON3_NUMPY_INCLUDE_DIRS="/RobotCode2024/vision/cross_venv/cross/lib/python3.10/site-packages/numpy/core/include" -DPYTHON3_INCLUDE_PATH="/python3-host/include/python3.10" -DPYTHON3_CVPY_SUFFIX=".cpython-310-aarch64-linux-gnu.so" -D BUILD_NEW_PYTHON_SUPPORT=ON -D BUILD_opencv_python3=ON -D HAVE_opencv_python3=ON -D OPENCV_EXTRA_MODULES_PATH=/RobotCode2024/vision/opencv_contrib-4.6.0/modules -DBUILD_LIST=aruco,python3,videoio -D ENABLE_LTO=ON ..

# make -j$(nproc)
# make install

cd ../..

# Install northstar under /opt/northstar
echo "Installing Northstar"

wget -O northstar.tar.gz https://github.com/BBScholar/northstar-5419/archive/refs/heads/master.tar.gz
tar -zvxf northstar.tar.gz
cp -R northstar/northstar /opt/northstar


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

systemctl enable northstar1.service
# systemctl enable northstar2.service


# Do we need any of this?
rm -rf /var/lib/apt/lists/*
apt-get clean

rm -rf /usr/share/doc
rm -rf /usr/share/locale/
