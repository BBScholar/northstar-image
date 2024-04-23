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
apt-get install -y python3 python3-pip3

# install python deps
pip3 install pyntcore robotpy-wpimath==2023.4.3.1
pip3 install -v pillow

# check python3 version
echo "Checking python version"
python3 --version

# download opencv 
wget -O opencv.tar.gz https://github.com/opencv/opencv/archive/refs/tags/4.6.0.tar.gz
wget -O opencv_contrib.tar.gz https://github.com/opencv/opencv_contrib/archive/refs/tags/4.6.0.tar.gz
tar -zvxf opencv.tar.gz
tar -zvxf opencv_contrib.tar.gz

cd opencv-4.6.0
mkdir build
cd build 

make -j$(nproc)
make install

cd ../..
