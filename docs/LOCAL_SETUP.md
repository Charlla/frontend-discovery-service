===========================================
FRONTEND DISCOVERY SERVICE - LOCAL SETUP
===========================================

This guide explains how to run and develop the service locally using LocalStack and Terraform.

-------------------------------------------
REQUIRED TOOLS
-------------------------------------------

Install these before starting:
- Docker and Docker Compose
- Node.js >= 16.11
- npm >= 8
- Python3 and python3-venv
- Terraform >= 1.0
- AWS CLI
- LocalStack CLI (recommended)

Note: tflocal will be installed automatically in a virtual environment during setup

-------------------------------------------
FIRST TIME SETUP
-------------------------------------------

1. Make scripts executable:
   chmod +x scripts/*.sh

2. Run the automated setup script:
   ./scripts/setup-local-dev.sh

   This script will:
   - Make all scripts executable
   - Check for required tools
   - Install tflocal if missing
   - Create initial .env file
   - Install dependencies
   - Initialize Terraform

2. Configure your environment:
   Edit .env with your settings:
   - LOCALSTACK_AUTH_TOKEN=<your-token>
   - DEBUG=1
   - LOCALSTACK_VOLUME_DIR=./.localstack
   - API_URL=http://localhost:4566
   - PROJECT_STORE=ProjectStore
   - FRONTEND_STORE=FrontendStore
   - VERSION_STORE=VersionStore
   - DEPLOYMENT_STORE=DeploymentStore
   - LOG_LEVEL=DEBUG

-------------------------------------------
QUICK START
-------------------------------------------

1. Start Local Environment:
   npm run start

2. Run Tests:
   npm run test:e2e

3. Stop Environment:
   npm run stop

-------------------------------------------
DEVELOPMENT WORKFLOW
-------------------------------------------

1. Daily Development:
   - Start environment: npm run start
   - Make code changes
   - Run tests: npm run test:e2e
   - Stop when done: npm run stop

2. Testing Changes:
   - Unit tests: npm test
   - E2E tests: npm run test:e2e
   - Both: npm run test:all

3. Restarting:
   - Quick restart: npm run restart
   - Full rebuild: npm run stop && npm run start

4. When to Run Setup Script:
   Run ./scripts/setup-local-dev.sh when:
   - First time setup
   - After pulling major updates
   - After changing branches
   - If local environment is corrupted

-------------------------------------------
LOCAL INFRASTRUCTURE
-------------------------------------------

Services Running Locally:
- DynamoDB (port 4566)
- Lambda Functions
- API Gateway
- Cognito
- Step Functions

All services run in LocalStack container

-------------------------------------------
ENVIRONMENT CONFIGURATION
-------------------------------------------

.env file settings:
LOCALSTACK_AUTH_TOKEN=<your-token>
DEBUG=1
LOCALSTACK_VOLUME_DIR=./.localstack
API_URL=http://localhost:4566

-------------------------------------------
COMMON TASKS
-------------------------------------------

1. Reset Local State:
   npm run cleanup
   npm run start

2. View Logs:
   docker-compose logs -f localstack

3. Check Service Health:
   curl http://localhost:4566/_localstack/health

4. Access APIs:
   Admin API: http://localhost:4566/admin
   Consumer API: http://localhost:4566/consumer

-------------------------------------------
TROUBLESHOOTING
-------------------------------------------

1. LocalStack Issues:
   - Check Docker is running
   - Verify port 4566 is free
   - Check LocalStack logs
   - Ensure auth token is valid

2. Terraform Issues:
   - Clear state: rm -rf .terraform*
   - Reinitialize: tflocal init
   - Check tflocal installation

3. Test Failures:
   - Verify LocalStack is healthy
   - Check service endpoints
   - Review test logs

-------------------------------------------
ARCHITECTURE NOTES
-------------------------------------------

Local Setup Mirrors Production:
- Same AWS services
- Similar configuration
- Equivalent API endpoints
- Matching authentication flow

Key Differences:
- Uses LocalStack instead of AWS
- Local state management
- Simplified authentication
- Faster deployment cycle

-------------------------------------------
BEST PRACTICES
-------------------------------------------

1. Always use provided scripts
2. Keep LocalStack updated
3. Clean up resources when done
4. Use test environment for verification
5. Monitor LocalStack resources
6. Regular state cleanup

===========================================
END OF LOCAL SETUP GUIDE
===========================================