#!/bin/bash

# ✅ Just start Ollama without --host
ollama serve &

# Pull the model after a short delay
sleep 3
ollama pull gemma:2b

wait
