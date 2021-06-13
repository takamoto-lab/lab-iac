#!/bin/bash
set -euo pipefail

target_template=${1}
target_files="./templates/global_values.yaml"
if [ -d "./templates/${target_template}" ]; then
    target_files="${target_files} $(echo ./templates/${target_template}/*.yaml)"
fi
if [ -d "./templates/${target_template}/resources" ]; then
    target_files="${target_files} $(echo ./templates/${target_template}/resources/*.yaml)"
fi
if [ -d "./templates/${target_template}/data" ]; then
    target_files="${target_files} $(echo ./templates/${target_template}/data/*)"
fi
if [ -d "./templates/${target_template}/libs" ]; then
    target_files="${target_files} $(echo ./templates/${target_template}/libs/*.yaml)"
fi

./bin/ytt $(echo ${target_files} | tr ' ' '\n' | xargs -I{} echo "-f {}" | tr '\n' ' ') > _build/${target_template}.yaml
