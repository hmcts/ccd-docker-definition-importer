#!/bin/sh
set -e

template_file_location=$1
output_file_location=$2
service_base_url=$3

#service_base_url_placeholder='${MICROSERVICE_BASE_URL}'

tmp_dir="/tmp_def"
rm -rf $tmp_dir
mkdir $tmp_dir
cd $tmp_dir

unzip $template_file_location

find . -type f -print0 | xargs -0 sed -i 's!\${MICROSERVICE_BASE_URL}!'"$service_base_url"'!g'

rm -f $output_file_location
zip -r $output_file_location .
