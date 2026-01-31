# CI/CD Pipeline Configuration Guide

## Required GitHub Secrets

To use the CI/CD pipelines, configure the following secrets in your GitHub repository:

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - AWS access key for Terraform and EKS
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Docker Registry
- `DOCKER_USERNAME` - Docker Hub username (or other registry)
- `DOCKER_PASSWORD` - Docker Hub password or access token
- `DOCKER_REGISTRY` - (Optional) Custom registry URL, defaults to docker.io

## Workflows

### 1. Build and Deploy (`build-and-deploy.yml`)

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual trigger via workflow_dispatch

**Jobs**:
1. **build-frontend** - Build and push frontend Docker image
2. **build-backend** - Build and push backend Docker image
3. **test** - Run unit tests and linting
4. **deploy** - Deploy to Kubernetes cluster
5. **rollback** - Automatic rollback on deployment failure

**Usage**:
```bash
# Automatic on push to main
git push origin main

# Manual trigger
# Go to Actions → Build and Deploy → Run workflow
```

### 2. Deploy Infrastructure (`deploy-infrastructure.yml`)

**Triggers**:
- Manual trigger only (workflow_dispatch)

**Jobs**:
1. Terraform format check
2. Terraform init, validate, plan
3. Terraform apply
4. Update kubeconfig
5. Verify cluster

**Usage**:
```bash
# Go to Actions → Deploy Infrastructure → Run workflow
# Select environment: dev, staging, or production
```

### 3. Destroy Infrastructure (`destroy.yml`)

**Triggers**:
- Manual trigger only (requires confirmation)

**Jobs**:
1. Terraform destroy with confirmation

**Usage**:
```bash
# Go to Actions → Destroy Infrastructure → Run workflow
# Type "destroy" to confirm
# Select environment
```

### 4. Nightly Cleanup (`nightly-cleanup.yml`)

**Triggers**:
- Scheduled: 2 AM UTC daily
- Manual trigger

**Jobs**:
1. Check if infrastructure exists
2. Destroy infrastructure if found
3. Create cleanup report

**Cost Savings**: ~$5/night (~$150/month)

### 5. Pull Request Checks (`pr-checks.yml`)

**Triggers**:
- Pull requests to `main` or `develop`

**Jobs**:
1. **lint** - Code linting
2. **validate-terraform** - Terraform validation
3. **validate-kubernetes** - K8s manifest validation
4. **security-scan** - Trivy security scanning

## Workflow Sequence

### Initial Setup
```
1. Deploy Infrastructure (manual)
   ↓
2. Build and Deploy (automatic on push)
   ↓
3. Verify deployment
```

### Daily Development
```
1. Create feature branch
   ↓
2. Make changes
   ↓
3. Create PR → PR Checks run
   ↓
4. Merge to main → Build and Deploy runs
   ↓
5. Nightly Cleanup runs at 2 AM UTC
```

### Cost Optimization Cycle
```
Morning: Deploy Infrastructure (manual)
   ↓
Day: Development and testing
   ↓
Night: Nightly Cleanup (automatic)
   ↓
Savings: ~$5/night
```

## Environment Configuration

### GitHub Environments

Create these environments in GitHub Settings → Environments:

1. **dev**
   - Auto-deploy on push to develop
   - No approval required

2. **staging**
   - Manual deployment
   - Optional: Require approval

3. **production**
   - Manual deployment only
   - Require approval from team leads

## Deployment Strategies

### Blue-Green Deployment
```yaml
# Update deployment with new image
kubectl set image deployment/backend backend=new-image:tag
kubectl rollout status deployment/backend
```

### Canary Deployment
```yaml
# Create canary deployment with 10% traffic
# Monitor metrics
# Gradually increase traffic
```

### Rollback
```yaml
# Automatic on failure, or manual:
kubectl rollout undo deployment/backend
```

## Monitoring Integration

After deployment, workflows automatically:
- Verify pod status
- Check service endpoints
- Run smoke tests
- Report deployment status

## Troubleshooting

### Build Failures
```bash
# Check build logs in Actions tab
# Verify Dockerfile syntax
# Check dependencies in package.json
```

### Deployment Failures
```bash
# Check kubectl logs
kubectl logs -l app=backend --tail=50

# Check pod status
kubectl describe pod <pod-name>

# Manual rollback
kubectl rollout undo deployment/backend
```

### Terraform Failures
```bash
# Check Terraform state
terraform show

# Manual cleanup
terraform destroy

# Re-initialize
terraform init
```

## Best Practices

1. **Always test in dev first** before deploying to production
2. **Use PR checks** to catch issues early
3. **Monitor deployments** via Grafana dashboards
4. **Enable nightly cleanup** to save costs
5. **Tag releases** for production deployments
6. **Review security scan results** before merging PRs

## Cost Optimization

- **Nightly Cleanup**: Saves ~$150/month
- **Spot Instances**: Saves ~70% on compute
- **Auto-scaling**: Scales down during low traffic
- **Manual Production Deploys**: Only deploy when needed

## Security

- **Never commit secrets** to repository
- **Use GitHub Secrets** for credentials
- **Enable security scanning** on PRs
- **Review Trivy reports** regularly
- **Rotate credentials** periodically
