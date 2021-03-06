#!/bin/bash
#!/usr/bin/sh

if [ ! -d ./JD_tencent_scf/ ]; then
    echo "git clone https://github.com/zero205/JD_tencent_scf.git ./JD_tencent_scf"
    git clone https://github.com/zero205/JD_tencent_scf.git ./JD_tencent_scf
    # rm -r -f ./JD_tencent_scf/.git
fi

# if [ ! -d ./Auto-jd/ ]; then
#     echo "git clone https://github.com/asd920/Auto-jd.git ./Auto-jd"
#     git clone https://github.com/asd920/Auto-jd.git ./Auto-jd
#     # rm -r -f ./Auto-jd/.git
# fi

# if [ ! -d ./QLScript2/ ]; then
#     echo "git clone https://github.com/ccwav/QLScript2.git ./QLScript2"
#     git clone https://github.com/ccwav/QLScript2.git ./QLScript2
#     # rm -r -f ./QLScript2/.git
# fi

if [ -d ./dst ]; then rm -r -f ./dst; fi
echo "mkdir ./dst"
mkdir ./dst
echo "cp -f -r ./JD_tencent_scf/. ./dst"
cp -f -r ./JD_tencent_scf/. ./dst
# echo "cp -f -r ./QLScript2/. ./dst"
# cp -f -r ./QLScript2/. ./dst

# echo "====================== Copy Auto-jd repository to dst folder ======================"
# for jsfile in ./Auto-jd/*; do
#     filename=$(basename "${jsfile}")
#     if [[ ! -f "./dst/${filename}" ]]; then
#         cp -f -r "${jsfile}" ./dst
#         echo "copied: ${filename}"
#     fi
# done

# echo "====================== Download set-share-code.sh to dst folder ======================"
# curl https://raw.githubusercontent.com/migrate-bricks/tg-msg/main/set-share-code.sh -o ./dst/set-share-code.sh
# chmod +x ./dst/set-share-code.sh
# bash ./dst/set-share-code.sh

cd ./dst || exit
#remove expired scripts
if [ -f jd_carnivalcity.js ]; then rm jd_carnivalcity.js; fi
if [ -f jd_ppdz.js ]; then rm jd_ppdz.js; fi
if [ -f jd_cjyx.js ]; then rm jd_cjyx.js; fi
if [ -f jd_cfd_mooncake.js ]; then rm jd_cfd_mooncake.js; fi

#below action will send out notification msg, hence let's run these at the end of the job
#run jd_try.js at the end because it may be exceed the time limit.
extraActions=("jd_bean_sign.js" "jd_cleancart.js" "jd_dpqd.js" "jd_moneyTree.js" "jd_qqxing.js" "jd_wsdlb.js" "jd_bean_change.js" "jd_try.js")

npm install
npm install dotenv

node jd_fruit.js
node jd_pet.js

echo '"====================== Run jobs except the extraActions script "======================'
for jsfile in ./jd_*.js; do
    action="$(basename "${jsfile}")"
    if [[ ! " ${extraActions[*]} " =~ ${action} ]]; then
        start=$(date +%s)
        echo -e "===============================================\n${action} start: $(date)"
        node "${action}"
        end=$(date +%s)
        echo -e "${action} end: $(date), duration: $((end-start))\n===============================================\n"
    fi
done

echo "====================== Run notify actions seperately ======================"
for action in "${extraActions[@]}"; do
    start=$(date +%s)
    echo -e "===============================================\n${action} start: $(date)"
    node "${action}"
    end=$(date +%s)
    echo -e "${action} end: $(date), duration: $((end-start))\n===============================================\n"
done
