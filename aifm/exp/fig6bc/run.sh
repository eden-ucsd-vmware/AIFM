#!/bin/bash

source ../../shared.sh

arr_aifm_heap_size=( 563 682 1374 2850 2850 4949 7168 9387 11605 13824 16043 18261 20480 )
arr_hashtable_idx_shift=( 25 26 27 27 28 28 28 28 28 28 28 28 28 )
#arr_aifm_heap_size=( 25460 )
#arr_hashtable_idx_shift=( 29 )

arr_slab_size=( 100 200 400 800 1600 3200 )
arr_slab_shift=( 25 24 23 22 21 20 )

sudo pkill -9 main

make clean
make -j
#for j in {5..10} 
#do
for ((j=0;j<${#arr_slab_size[@]};++j)); do
  for ((i=0;i<${#arr_aifm_heap_size[@]};++i)); do
      cur_heap_size=${arr_aifm_heap_size[i]}
      cur_idx_shift=${arr_hashtable_idx_shift[i]}
      local_mem_size=$(( (1 << ($cur_idx_shift - 20)) * 24 + $cur_heap_size ))
      if ! [ -f "${arr_slab_size[j]}.log_$local_mem_size" ]; then
      sed "s/constexpr static uint64_t kCacheSize = .*/constexpr static uint64_t kCacheSize = $cur_heap_size * Region::kSize;/g" main.cpp -i
      sed "s/constexpr static uint32_t kLocalHashTableNumEntriesShift = .*/constexpr static uint32_t kLocalHashTableNumEntriesShift = $cur_idx_shift;/g" main.cpp -i

      sed "s/constexpr static uint32_t kValueLen = .*/constexpr static uint32_t kValueLen = ${arr_slab_size[j]};/g" main.cpp -i
      sed "s/constexpr static uint32_t kNumKVPairs = .*/constexpr static uint32_t kNumKVPairs = 1 << ${arr_slab_shift[j]};/g" main.cpp -i
      make clean
      make -j
      rerun_local_iokerneld_args simple 1,2,3,4,5,6,7,8,9,11,12,13,14,15
      rerun_mem_server
      run_program ./main | grep "=" 1>${arr_slab_size[j]}.log_$local_mem_size 2>&1
      fi
      #run_program ./main | grep "=" 1>$j.log_$local_mem_size 2>&1
  done
done

kill_local_iokerneld

