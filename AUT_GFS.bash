#!/bin/bash

#################################################################
#		GFS Analysis Data Script  			#
# 	This Script was written by Juan Carlos Tufino Bernuy	#
# 	Universidad Nacional Agraria La Molina (UNALM)		#
#       To run this script: "bash GFS_AUT.bash			#
#################################################################


function show_banner() {
  author="Juan Carlos Tufino Bernuy"
  institution="Universidad Nacional Agraria La Molina (UNALM)"
  email="jtufinobernuy@gmail.com"
  date="2024-03-06"
  description="This script automates the download and unpacking of specific GFS analysis data."

  echo "#########################################################"
  echo "#		WRF Install Script   			#"
  echo "# 	Author: $author					#"
  echo "# 	Institution: $institution			#"
  echo "# 	Email: $email					#"
  echo "# 	Date: $date					#"
  echo "# 	Description: $description			#"
  echo "#########################################################"
}



## Ensure script is run with root privileges/

if [[ $EUID -ne 0 ]]; then
  echo "This script requires superuser privileges to download data."
  echo "Please run it with 'sudo'."
  exit 1
fi

chmod -R 777 /home/WRF/gfs/


show_banner


#wget -r https://www.ncei.noaa.gov/pub/has/model//

#https://www.ncei.noaa.gov/pub/has/model/HAS012495537/


echo "Please give the keyword for downloading"

read keyword

cd /home/WRF/gfs/work
rm *

wget -r -np -nd -A *tar  https://www.ncei.noaa.gov/pub/has/model/$keyword/
##tar -xvzf *.tar
##tar -xvf *.tar

for f in *.tar; do tar -xvf "$f"; done

mv *.tar ../GFS-grib2/.

echo "Download and unpacking complete."



#slider página para poder observar imagenes satelitales
