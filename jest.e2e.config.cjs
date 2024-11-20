/** @type {import('jest').Config} */
const config = {
  testMatch: ['**/tests/api.e2e.test.js'],
  testTimeout: 30000,
  setupFilesAfterEnv: ['./tests/setup.js'],
  transform: {
    '^.+\\.[t|j]sx?$': ['babel-jest', { configFile: './babel.config.cjs' }]
  },
  moduleFileExtensions: ['js', 'json', 'jsx', 'node'],
  testEnvironment: 'node',
  transformIgnorePatterns: [
    'node_modules/(?!(dotenv)/)'
  ]
};

module.exports = config; 