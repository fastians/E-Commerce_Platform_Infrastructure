# GitHub Secrets Setup Guide

## Required Secrets

Configure these secrets in your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### AWS Credentials

#### AWS_ACCESS_KEY_ID
```
Your AWS access key ID for Terraform and EKS access
Example: AKIAIOSFODNN7EXAMPLE
```

**How to get**:
1. Go to AWS Console → IAM
2. Create new user or use existing
3. Attach policies: `AdministratorAccess` (or custom policy)
4. Create access key
5. Copy Access Key ID

#### AWS_SECRET_ACCESS_KEY
```
Your AWS secret access key
Example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**How to get**:
- Same as above, copy Secret Access Key
- ⚠️ **Important**: Save this immediately, you can't view it again

### Docker Registry Credentials

#### DOCKER_USERNAME
```
Your Docker Hub username
Example: myusername
```

#### DOCKER_PASSWORD
```
Your Docker Hub password or access token
Recommended: Use access token instead of password
```

**How to get**:
1. Go to hub.docker.com
2. Account Settings → Security → New Access Token
3. Copy the token

#### DOCKER_REGISTRY (Optional)
```
Custom registry URL
Default: docker.io
Example: ghcr.io (for GitHub Container Registry)
```

## Optional Secrets

### Notification Webhooks

#### SLACK_WEBHOOK_URL
```
Slack webhook for deployment notifications
Example: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX
```

#### DISCORD_WEBHOOK_URL
```
Discord webhook for deployment notifications
```

## Verification

After adding secrets, verify they're set:
1. Go to Settings → Secrets and variables → Actions
2. You should see:
   - ✅ AWS_ACCESS_KEY_ID
   - ✅ AWS_SECRET_ACCESS_KEY
   - ✅ DOCKER_USERNAME
   - ✅ DOCKER_PASSWORD

## Security Best Practices

1. **Use IAM roles** with least privilege
2. **Rotate credentials** regularly (every 90 days)
3. **Use access tokens** instead of passwords
4. **Never commit secrets** to repository
5. **Audit secret usage** in Actions logs
6. **Delete unused secrets** immediately

## Testing Secrets

Run a simple workflow to test:
```yaml
name: Test Secrets
on: workflow_dispatch
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Test AWS
        run: |
          echo "AWS Key ID: ${AWS_ACCESS_KEY_ID:0:4}****"
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      
      - name: Test Docker
        run: |
          echo "Docker User: ${{ secrets.DOCKER_USERNAME }}"
```

## Troubleshooting

### "Secret not found" error
- Check secret name matches exactly (case-sensitive)
- Verify secret is set in repository (not organization)

### AWS authentication fails
- Verify IAM user has correct permissions
- Check access key is active
- Ensure region is correct

### Docker push fails
- Verify username/password are correct
- Check if using access token (recommended)
- Ensure repository exists in Docker Hub
