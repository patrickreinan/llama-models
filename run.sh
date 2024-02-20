#!/bin/bash

GIT_DIR=/Users/patrickreinan/git
LLAMA_CPP_DIR=$GIT_DIR/llama.cpp
LLAMA_CPP_MODELS_DIR=$LLAMA_CPP_DIR/models
LLAMA_MODELS_DIR=/Users/patrickreinan/git/llama-models


noclone=0
nobuild=0
nodownload=0


OPTSTRING=":cbd"



while getopts $OPTSTRING flag
do
    case ${flag} in
        c) 
            noclone=1
            ;;
        b) 
            nobuild=1
            ;;
        d) 
            nodownload=1
            ;;
    esac
done




if [  $noclone -eq 0 ] 
then
    rm -rf $LLAMA_CPP_DIR
    cd $GIT_DIR
    git clone https://github.com/ggerganov/llama.cpp.git
fi


cd $LLAMA_CPP_DIR


if [  $nobuild -eq 0 ] 
then
    git checkout 1aa18ef # workaround https://gist.github.com/adrienbrault/b76631c56c736def9bc1bc2167b5d129#:~:text=git-,checkout,-1aa18ef
    make clean
    LLAMA_METAL=1 make
fi

# Download model
export MODEL=llama-2-13b-chat.ggmlv3.q4_0.bin

if [  $nodownload -eq 0 ] 
then
    #wget "https://huggingface.co/TheBloke/Llama-2-13B-chat-GGML/resolve/main/${MODEL}"
    cp $LLAMA_MODELS_DIR/$MODEL $LLAMA_CPP_MODELS_DIR/

fi

echo "Prompt: " \
    && read PROMPT \
    &&  ./main \
        --threads 8 \
        --n-gpu-layers 1 \
        --model models/${MODEL} \
        --color \
        --ctx-size 2048 \
        --temp 0.7 \
        --repeat_penalty 1.1 \
        --n-predict -1 \
        --prompt "[INST] $PROMPT [/INST]"