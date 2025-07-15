#!/bin/bash
#SBATCH -J job_id
#SBATCH -o ./log/test_llama31_instruct_seed.out
#SBATCH --gres=gpu:1 #Number of GPU devices to use [0-2]
#SBATCH --nodelist=leon09 #YOUR NODE OF PREFERENCE


module load shared apptainer 

# Unset so HTTPX/ssl.create_default_context falls back to system defaults (certificates installed via ca-certificates)
unset SSL_CERT_FILE
unset REQUESTS_CA_BUNDLE

# Path to your Apptainer/Singularity image (SIF)
SIF_PATH="./img/sdft.img"  # or .img if that's your extension

# Working directory on the host where your sdft repository (or data) resides
# If your container already baked in /opt/sdft and you don't need host code, you can skip cd/bind.
HOST_WORKDIR="/home/hsin/sdft"   # adjust to where your code or data resides
cd "$HOST_WORKDIR" || exit 1

#echo "CUDA_VISIBLE_DEVICES in job: $CUDA_VISIBLE_DEVICES"
#singularity exec --nv "$SIF_PATH" pip list
#singularity exec --nv "$SIF_PATH" bash -lc "cd /opt/sdft && bash scripts_llama3/test_seed_LM.sh"

# test seed lm
singularity exec --nv "$SIF_PATH" bash scripts_llama3/test_seed_LM.sh

# vanilla ft
#singularity exec --nv "$SIF_PATH" bash scripts_llama3/openfunction/sft.sh

# sdft 
#singularity exec --nv "$SIF_PATH" bash scripts_llama3/openfunction/sdft.sh

