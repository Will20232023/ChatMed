lr=1e-4
lora_rank=8
lora_trainable="q_proj,v_proj,k_proj,o_proj,gate_proj,down_proj,up_proj"
#lora_trainable="q_proj,v_proj,k_proj,o_proj"
modules_to_save="embed_tokens,lm_head"
lora_dropout=0.1
pretrained_model="./resources/chinese-llama-alpaca-plus-lora-7b"
dataset_dir="预训练数据/datasets/chatgpt_data/ChatMed-v0.3.json"
per_device_batch_size=2
per_device_batch_size=2
gradient_accumulation_steps=32
training_steps=20000
output_dir="./medical_prompts/experiments/output/chatmed-llama-7b-pt-v0"
deepspeed_config_file="medical_prompts/src/ft_llama_lora/deepspeed_config_zero3_offload.json"

torchrun \
  --nnodes 1 \
  --nproc_per_node 4 \
  --rdzv_id=1 --rdzv_backend=c10d --rdzv_endpoint=localhost:12356 \
   medical_prompts/src/ft_llama_lora/run_clm_pt_with_peft.py \
   --deepspeed ${deepspeed_config_file} \
    --model_name_or_path ${pretrained_model} \
    --tokenizer_name_or_path ${pretrained_model} \
    --dataset_dir ${dataset_dir} \
    --validation_split_percentage 0.001 \
    --per_device_train_batch_size ${per_device_batch_size} \
    --per_device_eval_batch_size ${per_device_batch_size} \
    --do_train \
    --seed 100 \
    --fp16 \
    --max_steps ${training_steps} \
    --lr_scheduler_type cosine \
    --leraning_rate ${lr} \
    --warmup_ratio 0.05 \
    --weight_decay 0.01 \
    --logging_strategy steps \
    --logging_steps 10 \
    --save_strategy steps \
    --save_total_limit 25 \
    --save_steps 100 \
    --gradient_accumulation_steps ${gradient_accumulation_steps} \
    --preprocessing_num_workers 8 \
    --block_size 512 \
    --output_dir ${output_dir} \
    --overwrite_output_dir \
    --ddp_timeout 30000 \
    --logging_first_step True \
    --lora_rank ${lora_rank} \
    --trainable ${lora_trainable} \
    --modules_to_save ${modules_to_save} \
    --lora_dropout ${lora_dropout} \
    --torch_dtype float16