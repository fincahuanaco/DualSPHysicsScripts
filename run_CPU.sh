#!/bin/bash

# "name" and "dirout" are named according to the testcase

name=$1
dirout=${name}_out
diroutdata=${dirout}/data

# "executables" are renamed and called from their directory

dirbin=/home/fiq2020/solvers/DualSPHysics/bin/linux
#/home/DRIVE/Pesquisa2020/solvers/DualSPHysics/bin/linux
gencase="${dirbin}/GenCase_linux64"
dualsphysicscpu="${dirbin}/DualSPHysics5.0CPU_linux64"
dualsphysicsgpu="${dirbin}/DualSPHysics5.0_linux64"
partvtk="${dirbin}/PartVTK_linux64"
isosurface="${dirbin}/IsoSurface_linux64"

# Library path must be indicated properly

current=$(pwd)
cd $dirbin
path_so=$(pwd)
cd $current
export LD_LIBRARY_PATH=$path_so

# "dirout" is created to store results or it is cleaned if it already exists

if [ -e $dirout ]; then
  rm -r $dirout
fi
mkdir $dirout
mkdir $diroutdata


# CODES are executed according the selected parameters of execution in this testcase
errcode=0

# Executes GenCase4 to create initial files for simulation.
if [ $errcode -eq 0 ]; then
  $gencase ${name}_Def $dirout/$name -save:all
  errcode=$?
fi

# Executes DualSPHysics to simulate SPH method.
if [ $errcode -eq 0 ]; then
  $dualsphysicscpu $dirout/$name $dirout -dirdataout data -svres
  errcode=$?
fi

# Executes PartVTK4 to create VTK files with particles.
dirout2=${dirout}/particles; mkdir $dirout2
if [ $errcode -eq 0 ]; then
  $partvtk -dirin $diroutdata -savevtk $dirout2/PartFluid -onlytype:-all,+fluid
  errcode=$?
fi


# Executes IsoSurface4 to create VTK files with surface fluid and slices of surface.
dirout2=${dirout}/surface; mkdir $dirout2
planesy="-slicevec:0:0.1:0:0:1:0 -slicevec:0:0.2:0:0:1:0 -slicevec:0:0.3:0:0:1:0 -slicevec:0:0.4:0:0:1:0 -slicevec:0:0.5:0:0:1:0 -slicevec:0:0.6:0:0:1:0"
planesx="-slicevec:0.1:0:0:1:0:0 -slicevec:0.2:0:0:1:0:0 -slicevec:0.3:0:0:1:0:0 -slicevec:0.4:0:0:1:0:0 -slicevec:0.5:0:0:1:0:0 -slicevec:0.6:0:0:1:0:0 -slicevec:0.7:0:0:1:0:0 -slicevec:0.8:0:0:1:0:0 -slicevec:0.9:0:0:1:0:0 -slicevec:1.0:0:0:1:0:0"
planesd="-slice3pt:0:0:0:1:0.7:0:1:0.7:1"
if [ $errcode -eq 0 ]; then
  $isosurface -dirin $diroutdata -saveiso $dirout2/Surface -vars:-all,vel,rhop,idp,type -saveslice $dirout2/Slices $planesy $planesx $planesd
  errcode=$?
fi

if [ $errcode -eq 0 ]; then
  echo All done
else
  echo Execution aborted
fi
read -n1 -r -p "Press any key to continue..." key
echo
