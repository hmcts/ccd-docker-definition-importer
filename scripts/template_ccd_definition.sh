#!/bin/sh
set -e

template_file_location=$1
output_file_location=$2
service_base_url=$3

if [ "$#" -ne 3 ]
  then
    echo "Usage: template_ccd_definition.sh template_file_location output_file_location service_base_url"
    exit 1
fi

#service_base_url_placeholder='${MICROSERVICE_BASE_URL}'

tmp_dir="/tmp_def"
rm -rf $tmp_dir
mkdir $tmp_dir
cd $tmp_dir

unzip $template_file_location

find . -type f -print0 | xargs -0 sed -i 's!\${MICROSERVICE_BASE_URL}!'"$service_base_url"'!g'

rm -f $output_file_location
zip -r $output_file_location .
