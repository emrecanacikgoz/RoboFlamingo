#!/bin/bash
#SBATCH --job-name=train
#SBATCH -p palamut-cuda     # Kuyruk adi: Uzerinde GPU olan kuyruk olmasina dikkat edin.
#SBATCH --exclude=palamut2
#SBATCH -A proj12           # Kullanici adi
#SBATCH -J print_gpu        # Gonderilen isin ismi
#SBATCH -o %J-RobotFlamingo-mpt_3b-task_D_D.out     # Ciktinin yazilacagi dosya adi
#SBATCH --gres=gpu:8        # Her bir sunucuda kac GPU istiyorsunuz? Kumeleri kontrol edin.
#SBATCH -N 1                # Gorev kac node'da calisacak?
#SBATCH -n 1                # Ayni gorevden kac adet calistirilacak?
#SBATCH --cpus-per-task 128  # Her bir gorev kac cekirdek kullanacak? Kumeleri kontrol edin.
#SBATCH --time=3-0:0:0      # Sure siniri koyun.


echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

eval "$(/truba/home/$USER/miniconda3/bin/conda shell.bash hook)"
source activate RoboFlamingo
echo 'number of processors:'$(nproc)
export PATH=$PATH:/kuacc/users/eacikgoz17/thesis/RoboFlamingo/robot_flamingo
export PYTHONPATH=$PYTHONPATH:/kuacc/users/eacikgoz17/thesis/RoboFlamingo/robot_flamingo

# dataset path
calvin_dataset_path='/truba/home/eacikgoz/thesis/RoboFlamingo/calvin/dataset/task_D_D'
# language model path
lm_path='mpt-1b-dolly'
# tokenizer path
tokenizer_path='mpt-1b-dolly'
# openflamingo ckpt path
openflamingo_checkpoint='/truba/home/eacikgoz/thesis/OpenFlamingo-3B-vitl-mpt1b/checkpoint.pt'

subfix=`date "+%Y%m%d-%H%M"`
log_file="logs/training_RobotFlamingo-mpt_3b-task_D_D-"${subfix}".log"
#python3 -m torch.distributed.launch --nnodes=1 --nproc_per_node=2  --master_port=6042 robot_flamingo/train/train_calvin.py \
torchrun --nnodes=1 --nproc_per_node=8 --master_port=6042 robot_flamingo/train/train_calvin.py \
    --report_to_wandb \
    --llm_name mpt_3b \
    --traj_cons \
    --use_gripper \
    --fusion_mode post \
    --rgb_pad 10 \
    --gripper_pad 4 \
    --precision fp32 \
    --num_epochs 5 \
    --gradient_accumulation_steps 1 \
    --batch_size_calvin 6 \
    --run_name RobotFlamingo-mpt_3b-task_D_D \
    --calvin_dataset ${calvin_dataset_path} \
    --lm_path ${lm_path} \
    --tokenizer_path ${tokenizer_path} \
    --openflamingo_checkpoint ${openflamingo_checkpoint} \
    --cross_attn_every_n_layers 4 \
    --dataset_resampled \
    --loss_multiplier_calvin 1.0 \
    --workers 1 \
    --lr_scheduler constant \
    --warmup_steps 5000 \
    --learning_rate 1e-4 \
    --save_every_iter 10000 \
    --from_scratch \
