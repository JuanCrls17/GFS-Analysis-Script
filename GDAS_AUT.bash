#!/bin/bash

#################################################################
#        GFS Analysis Data Script                               #
#  This Script was written by Juan Carlos Tufino Bernuy        #
#  Universidad Nacional Agraria La Molina (UNALM)               #
#       To run this script: "bash GDAS_AUT.bash"                #
#################################################################

function show_banner() {
  author="Juan Carlos Tufino Bernuy"
  institution="Universidad Nacional Agraria La Molina (UNALM)"
  email="jtufinobernuy@gmail.com"
  date="2024-07-22"
  description="This script automates the download of specific GDAS analysis data."

  echo "#########################################################"
  echo "#        GFS Analysis Data Script                        #"
  echo "#  Author: $author                                       #"
  echo "#  Institution: $institution                             #"
  echo "#  Email: $email                                         #"
  echo "#  Date: $date                                           #"
  echo "#  Description: $description                             #"
  echo "#########################################################"
}
#it cab be neccesary to install aria2
# Ensure that the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires superuser privileges to download data"
  echo "Please run it with 'sudo'."
  exit 1
fi

chmod -R 777 /home/WRF/gfs
show_banner

echo "Before using the script, specify the downloading level that you need:"
echo "1.- Month -> monthinit_monthend"
echo "2.- Day   -> month-dayinit_month-dayend **commonly used"

read -p "Enter your choice (1 or 2): " choice

cd /home/WRF/gfs/

download_data() {
    local start_date=$1
    local end_date=$2
    local base_url="https://thredds.rda.ucar.edu/thredds/fileServer/files/g/ds083.3"
    local year=$3
    local download_dir=$4
    local temp_file="urls_to_download.txt"
    local block_size=4

    mkdir -p "$download_dir"

    current_date=$start_date
    > "$temp_file"

    while [ "$current_date" != "$end_date" ]; do
        for hour in 00 06 12 18; do
            for forecast in f00 f03 f06 f09; do
                formatted_date=$(date -d "$current_date" +"%Y%m%d")
                month=$(date -d "$current_date" +"%m")
                file_url="${base_url}/${year}/${year}${month}/gdas1.fnl0p25.${formatted_date}${hour}.${forecast}.grib2"
                echo "$file_url" >> "$temp_file"
            done
        done
        current_date=$(date -I -d "$current_date + 1 day")
    done

    echo "Starting downloads..."


    total_urls=$(wc -l < "$temp_file")
    for (( i=0; i<total_urls; i+=block_size )); do
        block_file="block_${i}.txt"
        head -n $((i + block_size)) "$temp_file" | tail -n $block_size > "$block_file"
        
        aria2c -x 4 -j 4 -d "$download_dir" -i "$block_file"
        

        find "$download_dir" -name "*.aria2" -type f -delete
    done
    
    rm "$temp_file"
}

if [ "$choice" -eq 1 ]; then
    read -p "Enter the year (yyyy): " year
    read -p "Enter the start month (mm): " month_start
    read -p "Enter the end month (mm): " month_end

    month_start=$(printf "%02d" $month_start)
    month_end=$(printf "%02d" $month_end)

    start_date="${year}-${month_start}-01"
    end_date=$(date -I -d "${year}-${month_end}-01 + 1 month - 1 day")

    download_dir="gdas_${start_date//-/}_${end_date//-/}"
    download_data "$start_date" "$end_date" "$year" "$download_dir"

elif [ "$choice" -eq 2 ]; then
    read -p "Enter the year (yyyy): " year
    read -p "Enter the start date (mm-dd): " start_date
    read -p "Enter the end date (mm-dd): " end_date

    start_date="${year}-${start_date}"
    end_date="${year}-${end_date}"

    download_dir="gdas_${start_date//-/}_${end_date//-/}"
    download_data "$start_date" "$end_date" "$year" "$download_dir"

else
    echo "Invalid choice. Please run the script again and choose 1 or 2."
fi

echo "The files have been downloaded successfully."

