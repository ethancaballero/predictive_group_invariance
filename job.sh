#!/bin/bash
#SBATCH --account=rrg-bengioy-ad         # Yoshua pays for your job
#SBATCH --cpus-per-task=6                # Ask for 40 CPUs
#SBATCH --gres=gpu:v100:1                    # Ask for 0 GPU
#SBATCH --mem=31G                        # Ask for 752 GB of RAM
#SBATCH --time=23:00:00                   # The job will run for 3 hours
#SBATCH -o /scratch/ethancab/syst-gen-outputs/slurm-%j.out  # Write the log in $SCRATCH

ib_penalty_activate_epoch="1"
ib_penalty_ramp_over_epoch="10"
ib_penalty="1.0"
method="baseline"
wc="0.0001"
u="200"

user=$USER
echo "$user"

for i in "$@"
do
case $i in
    -a=*|--ib_penalty_activate_epoch=*)
    ib_penalty_activate_epoch="${i#*=}"
    shift # past argument=value
    ;;
    -b=*|--ib_penalty_ramp_over_epoch=*)
    ib_penalty_ramp_over_epoch="${i#*=}"
    shift # past argument=value
    ;;
    -c=*|--ib_penalty=*)
    ib_penalty="${i#*=}"
    shift # past argument=value
    ;;
    -d=*|--method=*)
    method="${i#*=}"
    shift # past argument=value
    ;;
    -e=*|--wc=*)
    wc="${i#*=}"
    shift # past argument=value
    ;;
    -f=*|--u=*)
    u="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

env_dir="/home/ethancab/envs"
code_dir="/home/ethancab/research/predictive_group_invariance/coco"

echo "$ib_penalty_activate_epoch"
echo "$ib_penalty_ramp_over_epoch"
echo "$ib_penalty"
echo "$method"
echo "$wc"
echo "$u"

if [[ -n $1 ]]; then
    echo "Argument not recognised"
    exit
fi

# 1. Create your environement locally
module load python/3.7
cd $env_dir
source env_tf1/bin/activate
cd $code_dir
#DATA_DIR=/scratch/ethancab/syst-gen SLURM_TMPDIR=/scratch/ethancab/syst-gen python main.py -method ib_irmv1 -bs 2
DATA_DIR=/scratch/ethancab/syst-gen SLURM_TMPDIR=/scratch/ethancab/syst-gen python main.py -wc $wc -u $u -ib_penalty_activate_epoch $ib_penalty_activate_epoch --ib_penalty_ramp_over_epoch $ib_penalty_ramp_over_epoch --ib_penalty $ib_penalty --method $method
