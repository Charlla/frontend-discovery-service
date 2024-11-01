// First, add the AbortController polyfill
global.AbortController = class AbortController {
  constructor() {
    this.signal = new AbortSignal();
  }
  abort() {
    this.signal.aborted = true;
  }
};

global.AbortSignal = class AbortSignal {
  constructor() {
    this.aborted = false;
  }
};

// Then your existing environment setup
process.env.AWS_ACCESS_KEY_ID = 'test';
process.env.AWS_SECRET_ACCESS_KEY = 'test';
process.env.AWS_REGION = 'us-east-1';
process.env.AWS_ENDPOINT_URL = 'http://localhost:4566';

// Configure AWS SDK to use LocalStack
import { config } from 'aws-sdk';
config.update({
  endpoint: 'http://localhost:4566',
  region: 'us-east-1',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  }
});