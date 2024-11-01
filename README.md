# Frontend Service Discovery - LocalStack Development

A local development environment for testing and developing frontend service discovery functionality using LocalStack.

## Prerequisites

- Docker and Docker Compose
- Node.js 16+
- npm
- LocalStack Pro account (for auth token)
- Terraform (1.0+)
- AWS CLI v2

## Quick Start

1. Set up environment variables:
```bash
export LOCALSTACK_AUTH_TOKEN="your-token-here"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
```

2. Start LocalStack:
```bash
make up-local
```

3. Deploy the infrastructure:
```bash
make deploy-local
```

4. Run tests:
```bash
npm test
```

5. Clean up:
```bash
make down-local
```

## Example Application Setup

### 1. Create Host Application (SvelteKit)

```bash
# Create host app
npx create-mf-app host-app
# Select the following options:
# - Project type: Application
# - Framework: svelte-kit
# - Language: JavaScript
# - CSS: Tailwind
# - Port: 5000

cd host-app
```

Update `src/routes/+page.svelte`:
```svelte
<script>
  import { onMount } from 'svelte';
  
  let microfrontends = [];
  
  onMount(async () => {
    const response = await fetch('http://localhost:4566/projects/main/microFrontends');
    const data = await response.json();
    microfrontends = data.microfrontends;
  });
</script>

<div>
  {#each microfrontends as mfe}
    <div id={mfe.id}></div>
  {/each}
</div>
```

### 2. Create Auth Micro-Frontend (Vue)

```bash
# Create auth MFE
npx create-mf-app auth-mfe
# Select the following options:
# - Project type: Application
# - Framework: vue3
# - Language: JavaScript
# - CSS: Tailwind
# - Port: 5001

cd auth-mfe
```

Update `src/App.vue`:
```vue
<template>
  <div class="auth-container">
    <h2>Authentication</h2>
    <form @submit.prevent="handleLogin">
      <input type="email" v-model="email" placeholder="Email" />
      <input type="password" v-model="password" placeholder="Password" />
      <button type="submit">Login</button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'AuthApp',
  data() {
    return {
      email: '',
      password: ''
    }
  },
  methods: {
    handleLogin() {
      console.log('Login attempt:', this.email);
    }
  }
}
</script>
```

### 3. Create Admin Micro-Frontend (Svelte)

```bash
# Create admin MFE
npx create-mf-app admin-mfe
# Select the following options:
# - Project type: Application
# - Framework: svelte
# - Language: JavaScript
# - CSS: Tailwind
# - Port: 5002

cd admin-mfe
```

Update `src/App.svelte`:
```svelte
<script>
  let projects = [];
  
  async function fetchProjects() {
    const response = await fetch('http://localhost:4566/projects');
    projects = await response.json();
  }
</script>

<div class="admin-container">
  <h2>Admin Dashboard</h2>
  <button on:click={fetchProjects}>Load Projects</button>
  
  {#each projects as project}
    <div class="project-card">
      <h3>{project.name}</h3>
      <p>{project.description}</p>
    </div>
  {/each}
</div>
```

### 4. Register Micro-Frontends

Use the AWS CLI to register your micro-frontends:

```bash
# Create main project
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name admin-handler \
  --payload '{
    "path": "/projects",
    "httpMethod": "POST",
    "body": {
      "projectId": "main",
      "name": "Main Project"
    }
  }' response.json

# Register Auth MFE
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name admin-handler \
  --payload '{
    "path": "/projects/main/microFrontends",
    "httpMethod": "POST",
    "body": {
      "microFrontendId": "auth",
      "name": "Authentication",
      "entry": "http://localhost:5001/remoteEntry.js",
      "scope": "auth",
      "module": "./App"
    }
  }' response.json

# Register Admin MFE
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name admin-handler \
  --payload '{
    "path": "/projects/main/microFrontends",
    "httpMethod": "POST",
    "body": {
      "microFrontendId": "admin",
      "name": "Admin Dashboard",
      "entry": "http://localhost:5002/remoteEntry.js",
      "scope": "admin",
      "module": "./App"
    }
  }' response.json
```

### 5. Run the Applications

```bash
# Terminal 1 - Host
cd host-app
npm run dev

# Terminal 2 - Auth MFE
cd auth-mfe
npm run dev

# Terminal 3 - Admin MFE
cd admin-mfe
npm run dev
```

Visit http://localhost:5000 to see the host application with integrated micro-frontends.

## Project Structure

```
.
├── infrastructure/         # Lambda functions and business logic
│   ├── lambda/
│   └── stepfunctions/
├── test/                  # Test files
├── terraform/             # Infrastructure as code
└── docker-compose.yml     # LocalStack configuration
```

## Development

- Modify Lambda functions in `infrastructure/lambda/`
- Update infrastructure in `terraform/`
- Run `make deploy-local` to apply changes
- Use `make test` to run tests

## License

Apache-2.0
