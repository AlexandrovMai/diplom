FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y git 

RUN mkdir /opencv && cd /opencv && git clone -b 4.1.0 --single-branch https://github.com/opencv/opencv.git \
    && git clone -b 4.1.0 --single-branch https://github.com/opencv/opencv_contrib.git


RUN apt-get install -y python3.7 python3-pip

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2 \ 
    && update-alternatives --config python3

RUN python3 -m pip install --upgrade pip

RUN apt-get install -y --no-install-recommends libnvinfer7=7.1.3-1+cuda11.0 \
    libnvinfer-dev=7.1.3-1+cuda11.0 \
    libnvinfer-plugin7=7.1.3-1+cuda11.0

COPY . /coord_get/
RUN python3 --version && echo $(which python3)
RUN apt-get update && apt-get install -y python3.7-dev nano && python3 -m pip install setuptools
RUN python3 -m pip install -r /coord_get/requirments.txt

RUN apt-get install -y libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc \
    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 gstreamer1.0-pulseaudio

RUN apt-get install -y build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3.7-dev \
    libtbb2 libtbb-dev libdc1394-22-dev

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get install -y ttf-mscorefonts-installer && apt-get install -y ubuntu-restricted-extras

RUN apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

RUN  cd /opencv/opencv && mkdir build && \
    echo "$(python3 -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')" && \
    cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=$(which python2) \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=yes \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D PYTHON3_EXECUTABLE=$(which python3) \
    -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -D WITH_GSTREAMER=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON .. && make -j"$(nproc)" && make install && ldconfig

WORKDIR /app
CMD ["/bin/bash"]
