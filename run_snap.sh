#!/usr/bin/bash

MODEL_PATH="kim_tmp/SNAP_Alchemy__MO_000000000000_000"
IMAGE_NAME="ghcr.io/openkim/developer-platform:latest-minimal"

mkdir -p $MODEL_PATH
cp SNAP_Alchemy_Template/* $MODEL_PATH
printf "$1\"]\n}" >> $MODEL_PATH/kimspec.edn
cp $2 $MODEL_PATH/alchemy.snapcoeff
cp $3 $MODEL_PATH/alchemy.snapparam

DOCKER_COMMAND="kimitems install SNAP__MD.* &&
cp -r /home/openkim/$MODEL_PATH /home/openkim/models/ &&
kimitems install -D LatticeConstantCubicEnergy_bcc_$1.* &&
kimitems install -D LatticeConstantCubicEnergy_fcc_$1.* &&"

for i in "${@:4}"
do
    DOCKER_COMMAND="$DOCKER_COMMAND kimitems install -D $i &&"
done

DOCKER_COMMAND="$DOCKER_COMMAND pipeline-database set local &&
pipeline-run-pair LatticeConstantCubicEnergy_bcc_$1* SNAP_Alchemy__MO_000000000000_000 &&
pipeline-run-pair LatticeConstantCubicEnergy_fcc_$1* SNAP_Alchemy__MO_000000000000_000 &&
kimitems remove -f LatticeConstant.* &&
pipeline-run-matches SNAP_Alchemy__MO_000000000000_000 &&
find /home/openkim/test-results/ -name results.edn | xargs cat >> /home/openkim/kim_tmp/results.edn"

docker run --rm --mount type=bind,src=$PWD/kim_tmp,target=/home/openkim/kim_tmp --env LD_LIBRARY_PATH=:/usr/local/lib $IMAGE_NAME /bin/bash -c "$DOCKER_COMMAND"
