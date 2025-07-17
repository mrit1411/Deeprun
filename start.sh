#!/bin/bash

ollama serve &
sleep 3
ollama pull gemma:2b
wait
