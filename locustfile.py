from locust import HttpUser, task

class OllamaUser(HttpUser):
    @task
    def query_model(self):
        self.client.post("/api/chat", json={
            "model": "gemma:2b",
            "messages": [
                { "role": "user", "content": "Summarize AI in 3 lines." }
            ]
        })
