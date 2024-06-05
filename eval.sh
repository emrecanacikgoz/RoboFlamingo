#!/bin/bash
#SBATCH --job-name=eval
#SBATCH -p palamut-cuda     # Kuyruk adi: Uzerinde GPU olan kuyruk olmasina dikkat edin.
#SBATCH --exclude=palamut2
#SBATCH -A proj12           # Kullanici adi
#SBATCH -J print_gpu        # Gonderilen isin ismi
#SBATCH -o %J-eval.out     # Ciktinin yazilacagi dosya adi
#SBATCH --gres=gpu:1        # Her bir sunucuda kac GPU istiyorsunuz? Kumeleri kontrol edin.
#SBATCH -N 1                # Gorev kac node'da calisacak?
#SBATCH -n 1                # Ayni gorevden kac adet calistirilacak?
#SBATCH --cpus-per-task 16  # Her bir gorev kac cekirdek kullanacak? Kumeleri kontrol edin.
#SBATCH --time=3-0:0:0      # Sure siniri koyun.


echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

eval "$(/truba/home/$USER/miniconda3/bin/conda shell.bash hook)"
source activate RoboFlamingo
echo 'number of processors:'$(nproc)


export PATH=$PATH:/truba/home/eacikgoz/thesis/RoboFlamingo/robot_flamingo
export PYTHONPATH=$PYTHONPATH:/truba/home/eacikgoz/thesis/RoboFlamingo/robot_flamingo

python eval_ckpts.py

source deactivate
