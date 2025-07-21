from locust import HttpUser, task

class OllamaUser(HttpUser):
    @task
    def query_model(self):
        self.client.post("/api/generate", json={
            "model": "gemma:2b",
            "prompt": "Summarize AI in 3 lines."
        })
