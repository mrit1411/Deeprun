FROM ollama/ollama:latest

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV OLLAMA_NUM_PARALLEL=2
EXPOSE 11434

ENTRYPOINT ["/start.sh"]

