#!/bin/bash

GIT_DIR=/Users/patrickreinan/git
LLAMA_CPP_DIR=$GIT_DIR/llama.cpp
LLAMA_CPP_MODELS_DIR=$LLAMA_CPP_DIR/models
LLAMA_MODELS_DIR=/Users/patrickreinan/git/llama-models


clone=0
build=0
download=0


OPTSTRING=":cbd"



while getopts $OPTSTRING flag
do
    case ${flag} in
        c) 
            clone=1
            ;;
        b) 
            build=1
            ;;
        d) 
            download=1
            ;;
    esac
done




if [  $clone -eq 1 ] 
then
    rm -rf $LLAMA_CPP_DIR
    cd $GIT_DIR
    git clone https://github.com/ggerganov/llama.cpp.git
    download=1
fi


cd $LLAMA_CPP_DIR


if [  $build -eq 1  ] || [ $clone -eq 1 ]
then
    #git checkout 1aa18ef # workaround https://gist.github.com/adrienbrault/b76631c56c736def9bc1bc2167b5d129#:~:text=git-,checkout,-1aa18ef
    make clean
    LLAMA_METAL=1 make
fi

# download model
export MODEL=llama-2-13b-chat.ggmlv3.q4_0.bin

if [  $download -eq 1 ] 
then
    #wget "https://huggingface.co/TheBloke/Llama-2-13B-chat-GGML/resolve/main/${MODEL}"
    cp $LLAMA_MODELS_DIR/$MODEL $LLAMA_CPP_MODELS_DIR/

fi

#echo "Prompt: " \
    # && read PROMPT \
    #&&  
    ./main \
        --threads 8 \
        --n-gpu-layers 1 \
        --model models/${MODEL} \
        --color \
        --ctx-size 2048 \
        --temp 0.7 \
        --repeat_penalty 1.1 \
        --n-predict -1 \
        -i \
        -r "User:" \
        --in-suffix "Llama" \
        --in-prefix " "
        #--prompt "[INST] $PROMPT [/INST]"