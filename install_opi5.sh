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
apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev
apt-get remove -y snapd
apt-get autoremove -y

# Install necessary packages
echo "Installing packages"
apt-get install -y wget build-essential cmake libffi-dev libssl-dev zlib1g-dev
apt-get install -y curl wget
apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-dev gfortran openexr libatlas-base-dev
apt-get install -y libgstreamer1.0-dev
apt-get install -y libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base
apt-get install -y libgstreamer-plugins-bad1.0-dev  gstreamer1.0-plugins-bad
apt-get install -y gstreamer1.0-plugins-good
apt-get install -y gstreamer1.0-plugins-ugly
apt-get install -y gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-gl
apt-get install -y clang

# install pip 
apt-get install -y python3 python3-pip

# install python deps
pip3 install -v numpy
pip3 install --find-links https://tortall.net/~robotpy/wheels/2023/raspbian pyntcore
# pip3 install -v pyntcore 
pip3 install robotpy-wpimath==2023.4.3.1
pip3 install -v pillow

# check python3 version
echo "Checking python version"
python3 --version

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

make -j$(nproc)
make install

cd ../..

# Install northstar under /opt/northstar
echo "Installing Northstar"

