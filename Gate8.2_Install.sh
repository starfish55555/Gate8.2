#!/bin/sh

# Easy GATE Installation 
# Gate one-click installation script
# Modified on: Jun 25, 2019
# Original author:Alexandre CARRE (alexandre.carre@gustaveroussy.fr)
# Author: Starfish.W(starfish970323@gmail.com)
# Reference: https://github.com/Alxaline/Easy-GATE-Installation/blob/master/easy_gate.sh

echo "       *     ,MMM8&&&.            *       "
echo "            MMMM88&&&&&    .              "
echo "           MMMM88&&&&&&&                  "
echo "  *        MMMM GATE &&&&          *       "
echo "           MMMM V8.2 &&&'                  "
echo "           'MMM88&&&&&&'             .    "
echo "             'MMM8&&&'      *             "
echo "    |\___/|           installation :      "
echo "    )     (       - clhep-2.4.1.0         "
echo "   =\     /=      - root_v6.16.00         "
echo "     )===(        - RTK-1.4.0 Gate-8.2    "
echo "    /     \       - geant4.10.05          "
echo "    |     |       - InsightToolkit 4.13.2 "
echo "   /       \      - RTK-1.4.0             "
echo "   \       /      - Gate8.2&Cluster tools "
echo "  _/\__  _/_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\ "
echo "  |  |( (  |  |Author : STARFISH.W|  |  ))"  
echo "  |  | ) ) |  |  |  |  |  |  |  |  |  |  |"
echo "  |  |(_(starfish970323@gmail.com)_)|  |  "
echo " "

## Check version
version=$(cat /etc/*-release | uniq -c | sort -r | head -1|  xargs | cut -d" " -f2 | cut -b 12-)
echo "Your system version is ubuntu $version"

## Installation of GATE or not ?
while true; do
    read -p "Do you wish to install GATE and its dependencies [y/n]?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) return;;
        * ) echo "Please answer yes or no.";;
    esac
done

## Installation of GATE require sudo password
if [[ "$EUID" = 0 ]]; then
    echo "You are logged as root"
    echo "The installation can't be processed as root"
    return
else
    sudo -k # make sure to ask for password on next sudo
    if sudo true; then
        echo "correct password"
    else
        echo "wrong password"
    return
    fi
fi

# keep sudo alive
while true; do
  sleep 200
  sudo -n true
  kill -0 "$$" 2>/dev/null || exit
done &

## Verify if there is a version of GATE already installed ?
if which Gate 2>/dev/null
    then
        echo "'Gate' seems to be already installed."
            while true; do
            read -p "Are you sure you want to proceed with the installation [y/n]?" yn
            case $yn in
            [Yy]* ) break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes or no.";;
        esac
   done
fi

## Personalize the GATE installation path.
while true; do
    read -p "Do you want to personalize the installation path [y/n]? (default : /usr/local)" yn
    case $yn in
        [Yy]* ) read -p "Enter path: " GPTH
    if [ -d "$GPTH" ]
    then
            echo "$GPTH is valide."
        break
    else
            echo "$GPTH is not valide. Please check the path enter !"
    fi;;
        [Nn]* ) GPTH='/usr/local'; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

## Check free space on Disk (require 13 GBs)
FREE=`df -k --output=avail "$PWD" $GPTH | tail -n1`   # df -k not df -h
if [[ $FREE -lt 13631488 ]]; then               # 13G = 13*1024*1024k
     echo "You need at least 13 GBs of free space to install GATE !"
     echo "less than 13 GBs free in your installation path!"
     return
fi



## Copy the files to  the installation directory
# create the Gate dir
sudo mkdir $GPTH/Gate

# Prepare Gate installtion environment
sudo mkdir $GPTH/Gate/Gate8
sudo cp Gate* $GPTH/Gate/Gate8

# Prepare geant4 installtion environment
sudo mkdir $GPTH/Gate/geant4
sudo cp geant* $GPTH/Gate/geant4
sudo mkdir $GPTH/Gate/geant4/data
cp G4* $GPTH/Gate/geant4/data

# Prepare root installtion environment
if [[ $version == "18.04" ]] ; then
    tar -xzvf root_v6.16.00.Linux-ubuntu18-x86_64-gcc7.3.tar.gz -C $GPTH/Gate/
elif
    wget https://root.cern/download/root_v6.16.00.Linux-ubuntu16-x86_64-gcc5.4.tar.gz
    tar -xzvf root_v6.16.00.Linux-ubuntu16-x86_64-gcc5.4.tar.gz
fi
# Prepare RTK installtion environment
sudo mkdir $GPTH/Gate/RTK
sudo cp RTK* $GPTH/Gate/RTK

# Prepare CLHEP installtion environment
tar -xvf clhep-2.4.1.0.tgz
mv 2.4.1.0/ clhep
cp -rf clhep/ $GPTH/Gate
sudo mkdir $GPTH/Gate/clhep/build

# Prepare ITK installtion environment
sudo mkdir $GPTH/Gate/ITK
tar -zxvf InsightToolkit-4.13.2.tar.gz -C $GPTH/Gate/ITK
sudo mkdir $GPTH/Gate/ITK/build



## Install cmake-3.13.0
echo "Installing the cmake-3.13.0..."
tar xvf tar xvf cmake-3.13.0-Linux-x86_64.tar.gz
cd cmake-3.13.0-Linux-x86_64/
sudo cp -rf * /usr/local/
cd .. && sudo rm -rf cmake-3.13.0-Linux-x86_64/
echo "The installtion of cmake-3.13.0 is done"



## Prepare all the nice-to-have pre-requisites
echo "Installing the nice-to-have pre-requisites"
sudo apt-get install build-essential gcc make  libxt-dev libcanberra-gtk-module libxmu-dev libxi-dev zlib1g-dev libgl2ps-dev libexpat1-dev libxerces-c-dev libgl1-mesa-dev freeglut3-dev binutils libx11-dev libxpm-dev libxft-dev libxext-dev gfortran libssl-dev libpcre3-dev libglew-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl-dev libqt4-dev qt4* libxtst-dev libxrender-dev  libxmuu-dev libtbb2 -y
echo "Installtion of the nice-to-have pre-requisites is done"



## Installation of clhep-2.4.1.0 root_v6.16.00 geant4.10.05 ITK-4.13.2 RTK-1.4.0 Gate-8.2
#clhep
    echo "Installing the clhep"
    cd  $GPTH/Gate/clhep/build
    cmake ../CLHEP
    make -j$(nproc)
    make install -j$(nproc)
    echo "Installtion of the clhep is done"
#root
    echo "Installing the root"
    root_path=$GPTH/Gate/root/bin/root
    thisroot_path=$GPTH/Gate/root/bin/thisroot.sh
    #cp -i ~/.bashrc ~/.bashrc_bak
    new_alias="alias root=$root_path"
    new_thisroot="source $thisroot_path"
    echo $new_alias >> ~/.bashrc
    echo $new_thisroot >> ~/.bashrc
    source ~/.bashrc
    echo "Installtion of the root is done"
#geant4
    echo "Installing the geant4"
    cd $GPTH/Gate/geant4
    tar -xvf geant4.10.05.p01.tar.gz
    rm geant4.10.05.p01.tar.gz
    sudo mkdir build
    sudo mkdir install

    cd $GPTH/Gate/geant4/data
    for tar in *.tar.gz;  do tar xvf $tar; done
    cd $GPTH/Gate/geant4/build
    cmake -DCMAKE_INSTALL_PREFIX=$GPTH/Gate/geant4/install -DCMAKE_BUILD_TYPE=RELEASE -DGEANT4_BUILD_MULTITHREADED=OFF -DGEANT4_INSTALL_DATA=OFF -DGEANT4_USE_G3TOG4=OFF -DGEANT4_USE_GDML=OFF -DGEANT4_USE_INVENTOR=OFF -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_RAYTRACER_X11=ON -DGEANT4_USE_SYSTEM_EXPAT=ON -DGEANT4_USE_SYSTEM_ZLIB=OFF -DGEANT4_USE_XM=OFF $GPTH/Gate/geant4/geant4.10.05.p01
    cmake -DCMAKE_INSTALL_PREFIX=$GPTH/Gate/geant4/install -DCMAKE_BUILD_TYPE=RELEASE -DGEANT4_INSTALL_DATADIR=/usr/local/share/Geant4-10.5.1/data -DGEANT4_USE_SYSTEM_CLHEP=ON -DGEANT4_BUILD_MULTITHREADED=OFF -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_G3TOG4=ON -DGEANT4_USE_GDML=ON -DGEANT4_USE_INVENTOR=OFF -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_RAYTRACER_X11=ON -DGEANT4_USE_SYSTEM_EXPAT=ON -DGEANT4_USE_SYSTEM_ZLIB=ON -DGEANT4_USE_XM=OFF ../geant4.10.05.p01/


    make -j$(nproc) && make install
    
    geant4_path=$GPTH/Gate/geant4/install/bin/geant4.sh
    geant4make_path=$GPTH/Gate/geant4/install/share/Geant4-10.5.1/geant4make/geant4make.sh
    new_geant4="source $geant4_path"
    new_geant4make="source $geant4make_path"
    echo $new_geant4 >> ~/.bashrc
    echo $new_geant4make >> ~/.bashrc
    #source ~/.bashrc 这句导入数据后再source

    source ~/.bashrc
    echo "Installtion of the geant4 is done"

#ITK
    echo "Installing the ITK"
    cd $GPTH/Gate/ITK/build                                                                      
    #4.13.2
    cmake -DITK_USE_REVIEW=ON ../InsightToolkit-4.13.2
    #5.0.0
    #cmake -DModule_ITKReview=ON ../InsightToolkit-5.0.0
    make -j$(nproc)
    make install -j$(nproc)
    echo "Installtion of the ITK id done"

#RTK
    echo "Installing the RTK"   
    cd $GPTH/Gate/RTK
    unzip RTK*
    rm RTK-1.4.0.zip
    sudo mkdir build && cd build

    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_APPLICATIONS=ON -DBUILD_DOXYGEN=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_SIMPLERTK=OFF -DBUILD_TESTING=OFF ../RTK-1.4.0/

    make -j$(nproc)
    make install
    echo "Installtion of the RTK is done"
    # set the RTK environment variable
    #RTK_path=$GPTH/Gate/RTK/build/bin
    #RTK_LD_LIBRARY_PATH=$GPTH/Gate/RTK/build/bin
    #new_RTK_PATH="export PATH=$RTK_path:\$PATH"
    #new_LD_PATH="export LD_LIBRARY_PATH=$RTK_LD_LIBRARY_PATH:\$LD_LIBRARY_PATH"
    #echo $new_RTK_PATH >> ~/.bashrc
    #echo $new_LD_PATH >> ~/.bashrc
    #source ~/.bashrc
    #echo "Installtion of the RTK is done"
#gate
    echo "Installing the Gate"
    cd $GPTH/Gate/Gate8
    tar -xvzf Gate-8.2.tar.gz
    rm Gate-8.2.tar.gz
    mkdir build
    cd build
    #cmake  -DGATE_USE_GPU=ON -DGATE_USE_ITK -DGATE_USE_RTK=ON -DGATE_USE_SYSTEM_CLHEP  ../Gate-8.2
    cmake  -DGATE_USE_GPU=ON -DGATE_USE_ITK=ON -DGATE_USE_SYSTEM_CLHEP=ON  -DGATE_USE_GEANT4_UIVIS=ON -DGATE_USE_OPTICAL=ON ../Gate-8.2
    make -j$(nproc) && make install
    echo "Installtion of the Gate is done"
#Cluster tools 
    echo "Installing the Cluster tools"
    cd $GPTH/Gate/Gate8/Gate-8.2/cluster_tools/jobsplitter
    make
    cp gjs /usr/local/bin
    cd $GPTH/Gate/Gate8/Gate-8.2/cluster_tools/filemerger
    make
    cp gjm /usr/local/bin
    
    GC="export GC_DOT_GATE_DIR=/home/$USER"
    Gate_DIR="export GC_GATE_EXE_DIR=/usr/local/bin/"
    echo $GC >>~/.bashrc
    echo $Gate_DIR >> ~/.bashrc
echo "Gate has been isntalled successfully!!!..."
exit 0
