#!/bin/bash
export NODE_RANK=${SLURM_NODEID}
echo "##########################################"
echo MASTER_ADDR=${MASTER_ADDR}
echo MASTER_PORT=${MASTER_PORT}
echo NODE_RANK=${NODE_RANK}
echo WORLD_SIZE=${WORLD_SIZE}
echo "##########################################"
# debug environment worked great so we stick with it
# no magic there, just a miniconda python=3.9, pytorch=1.12, cudatoolkit=11.3
# env with pip dependencies from stable diffusion's requirements.txt
eval "$(/fsx/stable-diffusion/debug/miniconda3/bin/conda shell.bash hook)"
conda activate stable
cd /fsx/stable-diffusion/stable-diffusion

CONFIG=configs/stable-diffusion/txt2img-multinode-clip-encoder-f16-768-laion-hr.yaml
EXTRA="model.params.ckpt_path=/fsx/stable-diffusion/stable-diffusion/checkpoints/f16-33k+12k-hr_pruned.ckpt"
DEBUG="-d True lightning.callbacks.image_logger.params.batch_frequency=5"

python main.py --base $CONFIG --gpus 0,1,2,3,4,5,6,7 -t --num_nodes ${WORLD_SIZE} --scale_lr False $EXTRA #$DEBUG
