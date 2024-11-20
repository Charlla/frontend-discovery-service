import dotenv from 'dotenv';

// Load environment variables for tests
dotenv.config();

// Increase timeout for LocalStack operations
jest.setTimeout(30000);

// Add global console log for debugging
global.console.debug = (...args) => {
  if (process.env.DEBUG) {
    console.log(...args);
  }
}; 