#!/bin/bash
MYDIR="$(dirname "$(realpath "$0")")"
echo "Calculate new versions"

function conExist {
  docker inspect $1 &>/dev/null
}
function conIsRuning {
  isRun=$(docker inspect -f "{{.State.Running}}" $1)
  if [ $isRun != "true" ];then
    return 1
  fi
}

declare -A imgvs
imgServerN=imgbatt
imgArchN=imgarch
imgBotN=imgbot
imgvs[$imgServerN]=0
imgvs[$imgArchN]=0
imgvs[$imgBotN]=0
declare -A imgDFile
imgDFile[$imgServerN]=~/upload/battleline/battserver
imgDFile[$imgBotN]=~/upload/battleline/battbot
imgDFile[$imgArchN]=~/upload/battleline/battarchiver


conServerN=batt
conArchN=arch
conBot1N=bot1
conBot2N=bot2

conNames[0]="$conBot1N"
conNames[1]="$conBot2N"
conNames[2]="$conServerN"
conNames[3]="$conArchN"

list="$(docker images --format "{{.Repository}} {{.Tag}}")"
for K in "${!imgvs[@]}";do
  no=$(sed -n "/$K/p" <<<"$list"|wc -l)
  if [ "$no" -eq 1 ];then
    vno=$(sed -n "/$K/p" <<<"$list"|(read name version;echo ${version:1}))
    if [ ${imgvs[$K]} -eq 0 ];then
      if [ ! -z $vno ];then
        imgvs[$K]=$vno
      else
        echo "Missing versions on $K"
        exit 1
      fi
    fi
  else
    if [ "$no" -eq 0 ];then
      echo "Image $K  do not exist"
    else
        echo "Multible images exist of $K"
        exit 1
    fi
  fi
done


for K in "${!imgvs[@]}";do
  imgvs[$K]=$((${imgvs[$K]} + 1))
done

for K in "${!imgvs[@]}";do
    echo "Create image $K version v${imgvs[$K]}"
    cd ${imgDFile[$K]}
	ls
    docker build -t $K:v${imgvs[$K]} .|| exit 1
done
cd $MYDIR
echo "Create test net work webnettest"
docker network inspect webnettest &>/dev/null || docker network create --driver bridge webnettest

echo "Start containers"
nameServer="${conServerN}test"
docker run -d --name "$nameServer" -v battdatatest:/batt/data --network webnettest "$imgServerN":v${imgvs[$imgServerN]} || exit 1
sleep 1
nameBot1="${conBot1N}test"
docker run -d --name "$nameBot1" --network webnettest "$imgBotN":v${imgvs[$imgBotN]} -addr="$nameServer" -port=8181 -name=Bot1 -pw=rebot1Er || exit 1
nameArch="${conArchN}test"
docker run -d --name "$nameArch" --network webnettest "$imgArchN":v${imgvs[$imgArchN]} \
       -client="${nameServer}:7171" -addr="$nameArch" -backupport=8282 -loglevel=3 -dbfile="data/bdb.db" || exit 1
nameBot2="${conBot2N}test"
limitNo=141
echo "Starting bot to play 141 games"
docker run --name "$nameBot2" --network webnettest "$imgBotN":v${imgvs[$imgBotN]} \
       -addr="$nameServer" -port=8181 -name=Bot2 -pw=rebot2Er -loglevel=1 -send -limit="$limitNo" || exit 1

echo "Verify games is played and saved"
botNo=$(docker logs "$nameBot2" 2>&1 | grep "Number of game played" | awk '{print $7}')
if [[ -z $botNo ]];then
  echo "Test failed bot2 did not play any games"
  exit 1
fi
if [ "$botNo" != "$limitNo" ];then
  echo "Test failed bot2 did not play $limitNo of games only $botNo"
  exit 1
fi 

echo "Stop containers"
sleep 1
docker kill --signal=SIGINT "$nameBot1" || exit 1
sleep 1
docker kill --signal=SIGINT "$nameServer" || exit 1
sleep 2
docker kill --signal=SIGINT "$nameArch" 

echo "Wait for containers to stop 2 seconds"
sleep 2

archNo=$(docker logs "$nameArch" 2>&1 | grep 'Final number of saved games' |  awk '{print $9}')
if [[ -z $archNo ]];then
  echo "Test failed archiver did not save $limitNo games"
  exit 1
fi
if [ "$archNo" != "$limitNo" ];then
  echo "Test failed archiver did not save $limitNo games only ${archLine//[!0-9]/x}"
  exit 1
fi

echo "Clear containers and their volumes"

docker rm -v "$nameServer" || exit 1
docker rm -v "$nameBot1" || exit 1
docker rm -v "$nameBot2" || exit 1
docker rm -v "$nameArch" || exit 1

if [[ "$1" != "-i" ]];then
    echo "Clear images"

    for K in "${!imgvs[@]}";do
        echo "Clear image $K version v${imgvs[$K]}"
        docker rmi $K:v${imgvs[$K]} || exit 1
    done

else
    echo "##############Install################"
    echo "Stop containers"
    for con in "${conNames[@]}";do
        conExist "$con" && conIsRuning "$con" && docker kill --signal=SIGINT "$con"
	sleep 2
    done

    for con in "${conNames[@]}";do
        conExist "$con" && conIsRuning "$con" && echo "Failed to close down $con" && exit 1
    done
    echo "Backup"
    source ./backup.sh .

    # collect images name may fail if have been changed
    declare -A imgs 
    for con in "${conNames[@]}";do
        if conExist "$con"; then
            imgs["$(docker inspect -f "{{.Config.Image}}" "$con")"]="just want unigue"
        fi
    done
    echo "Clean containers"
    for con in "${conNames[@]}";do
        conExist "$con" && (docker rm -v "$con" || exit 1)
    done
    echo "Clean images"
    for val in "${!imgs[@]}";do
        docker rmi "$val" || exit 1 # name change of image after start may fuck this up.
    done

    echo "Create net work webnet if it does not exit"
    docker network inspect webnet &>/dev/null || docker network create --driver bridge webnet

    echo "Remove volume batthtml"
    docker volume inspect batthtml &>/dev/null && docker volume rm batthtml

    echo "Start containers"
    echo "Start $conServerN"
    docker run -d --name "$conServerN" -v battdata:/batt/data -v batthtml:/batt/html --network webnet "$imgServerN":v${imgvs[$imgServerN]} || exit 1
    sleep 1
    echo "Start $conBot1N"
    docker run -d --name "$conBot1N" --network webnet "$imgBotN":v${imgvs[$imgBotN]} -addr="$conServerN" -port=8181 -name=Bot1 -pw=rebot1Er || exit 1
    echo "Start $conBot2n"
    docker run -d --name "$conBot2N" --network webnet "$imgBotN":v${imgvs[$imgBotN]} -addr="$conServerN" -port=8181 -name=Bot2 -pw=rebot2Er || exit 1
    sleep 2
    echo "Start $conArchN"
    docker run -d --name "$conArchN" --network webnet -v archdata:/arch/data "$imgArchN":v${imgvs[$imgArchN]} \
           -client="${conServerN}:7171" -addr="$conArchN" -backupport=8282 -dbfile="data/bdb.db" || exit 1

fi

