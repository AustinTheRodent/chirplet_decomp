#!/bin/bash

script=`realpath $0`
script_dir=`dirname $script`
TULIP=${script%tulip*}tulip
export TULIP_WIN=`$cyg2win $TULIP`

sim_name="chirplet_sig_gen"
input_vector_fname=$sim_name"_input.txt"

VLD_COEFF=1.0
RDY_COEFF=1.0
rand_seed=`date +%s`
echo rand_seed: $rand_seed

time_step=0.00000001
tau=0.0005
alpha1=20000000

input_fname="$TULIP_WIN/fpga_builds/tb/${sim_name}/input.txt"
output_fname="$TULIP_WIN/fpga_builds/tb/${sim_name}/hw_output/output.bin"
num_samps=10000

main_arg="none"
use_user_input="false"
usr_file_name="none"
gui="true"
gui_sw=""
verbose="false"

args=("$@") 
for (( i=0;i<${#args[@]};i++)); do
  case ${args[${i}]} in
    "-all")
      main_arg="all"
      ;;
    "-hw")
      main_arg="hw"
      ;;
    "-sw")
      main_arg="sw"
      ;;
    "-compile")
      main_arg="compile"
      gui_sw="-c"
      ;;
    "-cmp")
      main_arg="cmp"
      ;;
    "-onlygen")
      main_arg="onlygen"
      ;;
    "-nogui")
      gui="false"
      gui_sw="-c"
      ;;
    "-clean")
      main_arg="clean"
      ;;
    "-i")
      use_user_input="true"
      usr_file_name=${args[${i}+1]}
      ;;
    "-n")
      num_samps=${args[${i}+1]}
      ;;
    "-v")
      verbose="true"
      ;;
  esac
done

if [ $main_arg == "none" ];then
  echo main arg undefined ...
  cat $TULIP_WIN/fpga_builds/tb/${sim_name}/readme.txt
  exit
fi

if [ $main_arg != "clean" ];then
  make -C $TULIP_WIN/fpga_builds/tb/${sim_name}/c_code
fi

##################################################################
## clean:
##################################################################
if [ $main_arg == "clean" ];then
  echo cleaning generated files ...
  make clean -C $TULIP_WIN/fpga_builds/tb/${sim_name}/c_code
  cd $TULIP_WIN/fpga_builds/tb/${sim_name}
  echo $TULIP_WIN/fpga_builds/tb/${sim_name}
  mv readme.txt readme.bak
  find . -maxdepth 1 -type f -name '*.txt' -delete
  find . -maxdepth 1 -type f -name '*.bin' -delete
  mv readme.bak readme.txt
  cd $TULIP_WIN/fpga_builds/tb/${sim_name}/hw_output
  find . -maxdepth 1 -type f -name '*.txt' -delete
  find . -maxdepth 1 -type f -name '*.bin' -delete
  cd $TULIP_WIN/fpga_builds/tb/${sim_name}/sw_output
  find . -maxdepth 1 -type f -name '*.txt' -delete
  find . -maxdepth 1 -type f -name '*.bin' -delete
  cd $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg
  find . -maxdepth 1 -type f -name '*.wlf' -delete
  find . -maxdepth 1 -type f -name '*transcript' -delete
  find . -maxdepth 1 -type f -name '*.ini' -delete
  rm -rf work/
  exit
fi

##################################################################
## generate simulation setup:
##################################################################
if [ $main_arg == "all" ] || [ $main_arg == "hw" ] || [ $main_arg == "sw" ] || [ $main_arg == "onlygen" ]; then
  echo generating simulation setup ...
  rm -f $input_fname
  touch $input_fname

  echo $time_step > $input_fname
  echo $tau >> $input_fname
  echo $alpha1 >> $input_fname

  $script_dir/c_code/bin/txt_to_bin \
    -i $input_fname \
    -o ${input_fname%txt*}bin \
    -t float

  if [ $main_arg == "onlygen" ]; then
    exit
  fi

fi

##################################################################
## generate SW output:
##################################################################
if [ $main_arg == "all" ] || [ $main_arg == "sw" ];then
  echo generating SW model ...

  cp $input_fname $script_dir/sw_output/output.txt

  #$script_dir/c_code/bin/filter.exe \
  #  -a $script_dir/a_taps.txt \
  #  -b $script_dir/b_taps.txt \
  #  -i $script_dir/input.txt \
  #  -o $script_dir/sw_output/output.txt

fi

##################################################################
## generate HW output:
##################################################################

if [ $main_arg == "all" ] || [ $main_arg == "hw" ] || [ $main_arg == "compile" ];then
    echo generating HW model ...

  export generics_list="\
-g/tb_${sim_name}/G_VLD_COEFF=$VLD_COEFF \
-g/tb_${sim_name}/G_RDY_COEFF=$RDY_COEFF \
-g/tb_${sim_name}/G_RAND_SEED=$rand_seed \
-g/tb_${sim_name}/G_INPUT_FNAME=$input_fname \
-g/tb_${sim_name}/G_OUTPUT_FNAME=$output_fname \
"

  cd $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/

  cp $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim.do $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim_tmp.do
  if [ $gui == "false" ]; then
    echo "exit" >> $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim_tmp.do
  fi

  if [ $verbose == "false" ]; then
      $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/compile.sh $main_arg | grep "Error"
      if [ $main_arg == "compile" ]; then
        exit
      fi
      vsim $gui_sw -do $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim_tmp.do | grep "Error"
  else
      $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/compile.sh $main_arg
      if [ $main_arg == "compile" ]; then
        exit
      fi
      vsim $gui_sw -do $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim_tmp.do
  fi

  rm $TULIP_WIN/fpga_builds/tb/${sim_name}/cfg/sim_tmp.do

  #$script_dir/c_code/bin/bin_to_txt \
  #  -i ${output_fname%txt*}bin \
  #  -o $output_fname \
  #  -t float

fi

##################################################################
## compare SW and HW outputs:
##################################################################
if [ $main_arg != "hw" ] && [ $main_arg != "sw" ] && [ $main_arg != "compile" ];then
  echo comparing outputs ...

  cmp $script_dir/sw_output/output.txt $script_dir/hw_output/output.txt

  #$script_dir/c_code/bin/calc_evm \
  #  -f1 $script_dir/hw_output/output.txt \
  #  -f2 $script_dir/sw_output/output.txt \
  #  -s 16

fi





