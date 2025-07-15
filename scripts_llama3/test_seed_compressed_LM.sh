#!/bin/bash
set -e
source "scripts/utils.sh"

# Configurations
model_path="/home/hsin/AutoAWQ/Llama-3-8B-Instruct-AWQ"
#model_path="meta-llama/Llama-3.1-8B-Instruct"
#model_path="/home/hsin/LLM-Pruner/prune_log/hf_llama3_8b_instruct_prune_0p3"
output_folder="predictions_llama31_instruct_awq/seed"
#cuda_visible_devices="3"
result_file="results_llama31_instruct_awq/seed_LM_safe.log"

create_empty_file ${result_file}
echo -e "Evaluation on seed LM.\n" >> ${result_file}

# # Evaluate math reasoning capabilities
# for math_dataset in gsm8k multiarith;
# do
#     echo "Evaluation on ${math_dataset}:" >> ${result_file}
#     output_dir="${output_folder}/${math_dataset}"
#     python main.py \
#         --stage sft \
#         --model_name_or_path ${model_path} \
#         --do_predict \
#         --dataset "${math_dataset}_test" \
#         --template llama3_gsm8k_infer \
#         --output_dir ${output_dir} \
#         --per_device_eval_batch_size 1 \
#         --max_samples 9999999999999 \
#         --predict_with_generate \
#         --overwrite_cache \
#         --fp16

#     python "eval/eval_math.py" --input_file "${output_dir}/generated_predictions.jsonl" >> ${result_file}
# done

# # Evaluate on OpenFunctions
# echo "Evaluation on OpenFunctions:" >> ${result_file}
# output_dir="${output_folder}/openfunction"
# python main.py \
#     --stage sft \
#     --model_name_or_path ${model_path} \
#     --do_predict \
#     --dataset openfunction_test \
#     --template alpaca \
#     --output_dir ${output_dir} \
#     --per_device_eval_batch_size 1 \
#     --max_samples 9999999999999 \
#     --predict_with_generate \
#     --overwrite_cache \
#     --fp16

# python "eval/eval_openfunction.py" --input_file "${output_dir}/generated_predictions.jsonl" >> ${result_file}

# # Evaluate on HumanEval
# output_path="${output_folder}/humaneval/result.json"
# create_empty_file ${output_path}
# python bigcode-evaluation-harness/main.py \
#     --model ${model_path} \
#     --tasks humanevalsynthesize-python \
#     --prompt octocoder \
#     --do_sample False \
#     --batch_size 1 \
#     --allow_code_execution \
#     --trust_remote_code \
#     --metric_output_path ${output_path} \
#     --max_length_generation 2048 \
#     --precision fp16

# python "eval/eval_humaneval.py" --input_file ${output_path} >> ${result_file}

# # Predict on alpaca_eval (general helpfulness)
# output_dir="${output_folder}/alpaca_eval"
# python main.py \
#     --stage sft \
#     --model_name_or_path ${model_path} \
#     --do_predict \
#     --dataset alpaca_eval \
#     --template alpaca \
#     --output_dir ${output_dir} \
#     --per_device_eval_batch_size 1 \
#     --max_samples 9999999999999 \
#     --predict_with_generate \
#     --overwrite_cache \
#     --fp16

# python "eval/prepare_alpaca_eval.py" --input_file "${output_dir}/generated_predictions.jsonl" --output_file "${output_dir}/outputs.json"
# # Execute the line below yourself if you want. Configuration of OpenAI API needed. The evaluation takes about $15.
# # alpaca_eval --model_outputs "${output_dir}/outputs.json"

# # Evaluate safety
# for template in "alpaca" "alpaca_gcg";
# do
#     if [ ${template} == "alpaca" ];
#     then
#         safety_type="raw"
#     else
#         safety_type="jailbreak"
#     fi
#     echo "Evaluation on ${safety_type} safety:" >> ${result_file}
#     output_dir="${output_folder}/advbench-${safety_type}"
#     python main.py \
#         --stage sft \
#         --model_name_or_path ${model_path} \
#         --do_predict \
#         --dataset advbench \
#         --template ${template} \
#         --output_dir ${output_dir} \
#         --per_device_eval_batch_size 32 \
#         --max_samples 9999999999999 \
#         --predict_with_generate \
#         --overwrite_cache \
#         --fp16
    
#     python "eval/keyword_eval_safety.py" --input_file "${output_dir}/generated_predictions.jsonl" >> ${result_file}
# done


# Evaluate safety, 3.1
for template in "llama3_1_alpaca" "llama3_1_alpaca_gcg";
do
    if [ ${template} == "llama3_1_alpaca" ];
    then
        safety_type="raw"
    else
        safety_type="jailbreak"
    fi
    echo "Evaluation on ${safety_type} safety:" >> ${result_file}
    output_dir="${output_folder}/advbench-${safety_type}"
    python main.py \
        --stage sft \
        --model_name_or_path ${model_path} \
        --do_predict \
        --dataset advbench \
        --template ${template} \
        --output_dir ${output_dir} \
        --per_device_eval_batch_size 32 \
        --max_samples 9999999999999 \
        --predict_with_generate \
        --overwrite_cache \
        --fp16
    
    python "eval/keyword_eval_safety_31.py" --input_file "${output_dir}/generated_predictions.jsonl" >> ${result_file}
done


# check result only
# for template in "alpaca" "alpaca_gcg";
# do
#     if [ ${template} == "alpaca" ];
#     then
#         safety_type="raw"
#     else
#         safety_type="jailbreak"
#     fi
#     echo "Evaluation on ${safety_type} safety:" >> ${result_file}
#     output_dir="${output_folder}/advbench-${safety_type}"
#     python "eval/keyword_eval_safety_31.py" --input_file "${output_dir}/generated_predictions.jsonl" >> ${result_file}
# done

# # Evaluate general knowledge 
# output_dir="${output_folder}/lm-eval"
# lm_eval --model hf \
#     --model_args "pretrained=${model_path}" \
#     --tasks mmlu,truthfulqa,ai2_arc,hellaswag,winogrande \
#     --device "cuda:${cuda_visible_devices}" \
#     --batch_size 1 \
#     --output_path ${output_dir}

# python "eval/eval_general_knowledge.py" --input_file "${output_dir}/results.json" >> ${result_file}
# echo "Evaluation of the seed LM finished successfully. Results are saved in ${result_file}."