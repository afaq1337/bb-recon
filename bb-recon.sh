#!/bin/bash

red=`echo -en "\e[31m"`
green=`echo -en "\e[32m"`
bold=`echo -en "\e[1m"`
blue=`echo -en "\e[34m"`
normal=`echo -en "\e[0m"`

input=$1
if [ -z "$input" ]
  then
    echo "${red} [+] No domain name supplied!"
    exit 1
fi

chaos_scan() {
echo ""    
echo "${bold}+---------------------------Running Chaos----------------------------+${normal}"
chaos -d $input -silent > $input.chaos
echo ""
echo "${green} [+] Total Number of Subdomains : ${normal}" $(cat $input.chaos | wc -l)
sleep 2
}
chaos_scan

httpx_scan() {
echo ""
echo "${bold}+---------------------------Running HTTPX----------------------------+${normal}"
echo "${blue}"
cat $input.chaos | httpx -silent | tee $input.httpx
echo ""
echo "${red} [+] Total Number of Live Subdomains :${normal}" $(cat $input.httpx | wc -l)
}
httpx_scan

copy_results() {
echo ""
echo "${bold}+---------------------------Backup Results----------------------------+${normal}"
echo "${green}"
scp $input.httpx pi@rasp:/home/pi/backup/
echo "${normal}"
}
copy_results

nuclei_scan() {
echo ""
echo "${bold}+---------------------------Running Nuclei----------------------------+${normal}"
echo "${green}"
cat $input.httpx | nuclei -t ~/nuclei-templates -silent -stats | tee $input.nuclei | notify -silent
echo "${normal}"
}
nuclei_scan

jaeles_scan() {
echo ""
echo "${bold}+---------------------------Running Jaeles----------------------------+${normal}"
echo ""
cat $input.nuclei | cut -d " " -f4 | jaeles scan -s ~/.jaeles/base-signatures/ | tee $input.jaeles | notify -silent
}
jaeles_scan
