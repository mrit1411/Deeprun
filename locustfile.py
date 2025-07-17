from locust import HttpUser, task

class OllamaUser(HttpUser):
    @task
    def query_model(self):
        self.client.post("/", json={"prompt": "Summarize AI in 3 lines."})
