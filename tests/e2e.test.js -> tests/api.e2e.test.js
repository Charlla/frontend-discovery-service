import request from 'supertest';
import { v4 as uuidv4 } from 'uuid';

const BASE_URL = process.env.API_URL || 'http://localhost:4566';
const PROJECT_NAME = 'test-project';
const MFE_NAME = 'test-frontend';

describe('Frontend Service Discovery E2E Tests', () => {
  let authToken;
  let projectId;
  let mfeId;

  beforeAll(async () => {
    // Get auth token from Cognito
    authToken = await getAuthToken();
  });

  describe('Admin API', () => {
    test('should create a new project', async () => {
      const response = await request(BASE_URL)
        .post('/admin/projects')
        .set('Authorization', authToken)
        .send({ name: PROJECT_NAME });

      expect(response.status).toBe(201);
      expect(response.body.name).toBe(PROJECT_NAME);
      projectId = response.body.id;
    });

    test('should create a new micro-frontend', async () => {
      const response = await request(BASE_URL)
        .post(`/admin/projects/${projectId}/microFrontends`)
        .set('Authorization', authToken)
        .send({ 
          name: MFE_NAME,
          metadata: {
            type: 'module'
          }
        });

      expect(response.status).toBe(201);
      expect(response.body.name).toBe(MFE_NAME);
      mfeId = response.body.id;
    });
  });

  describe('Consumer API', () => {
    test('should get micro-frontends for project', async () => {
      const response = await request(BASE_URL)
        .get(`/consumer/projects/${projectId}/microFrontends`);

      expect(response.status).toBe(200);
      expect(response.body.microFrontends).toBeDefined();
    });
  });
}); 