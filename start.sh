#!/bin/bash

# Bind Ollama to 0.0.0.0 so it's reachable from outside the pod
ollama serve --host 0.0.0.0 &

# Pull the model
sleep 3
ollama pull gemma:2b

wait
