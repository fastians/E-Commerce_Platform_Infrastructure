.PHONY: help deploy destroy build push test grafana prometheus load-test

# Variables
CLUSTER_NAME ?= demo-eks-cluster
REGION ?= us-east-1
NAMESPACE ?= default

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

deploy: ## Deploy full infrastructure and application
	@echo "🚀 Deploying infrastructure..."
	cd infrastructure/terraform/aws && terraform init && terraform apply -auto-approve
	@echo "⚙️  Configuring kubectl..."
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)
	@echo "📦 Deploying application..."
	kubectl apply -k infrastructure/kubernetes/base/
	@echo "✅ Deployment complete!"

destroy: ## Destroy all infrastructure
	@echo "🗑️  Destroying infrastructure..."
	cd infrastructure/terraform/aws && terraform destroy -auto-approve
	@echo "✅ Infrastructure destroyed!"

build: ## Build Docker images
	@echo "🔨 Building frontend..."
	cd app/frontend && docker build -t platform-frontend:latest .
	@echo "🔨 Building backend..."
	cd app/backend && docker build -t platform-backend:latest .
	@echo "✅ Build complete!"

push: ## Push Docker images to registry
	@echo "📤 Pushing images..."
	docker push platform-frontend:latest
	docker push platform-backend:latest
	@echo "✅ Images pushed!"

test: ## Run tests
	@echo "🧪 Running tests..."
	cd app/backend && npm test
	cd app/frontend && npm test
	@echo "✅ Tests passed!"

grafana: ## Open Grafana dashboard
	@echo "📊 Opening Grafana..."
	kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring &
	@echo "🌐 Grafana available at http://localhost:3000"
	@echo "   Username: admin"
	@echo "   Password: prom-operator"

prometheus: ## Open Prometheus dashboard
	@echo "📈 Opening Prometheus..."
	kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring &
	@echo "🌐 Prometheus available at http://localhost:9090"

load-test: ## Run load tests
	@echo "⚡ Running load tests..."
	k6 run load-tests/scenarios/normal-load.js
	@echo "✅ Load test complete!"

status: ## Check deployment status
	@echo "📊 Deployment Status:"
	@echo "\n🔹 Nodes:"
	kubectl get nodes
	@echo "\n🔹 Pods:"
	kubectl get pods -n $(NAMESPACE)
	@echo "\n🔹 Services:"
	kubectl get services -n $(NAMESPACE)
	@echo "\n🔹 Ingress:"
	kubectl get ingress -n $(NAMESPACE)

logs: ## View application logs
	@echo "📜 Application logs:"
	kubectl logs -l app=backend --tail=50 -n $(NAMESPACE)

clean: ## Clean local build artifacts
	@echo "🧹 Cleaning..."
	docker system prune -f
	@echo "✅ Cleanup complete!"
