module.exports = {
  setupFiles: ['<rootDir>/test/setup.js'],
  testEnvironment: 'node',
  transform: {
    '^.+\\.[t|j]sx?$': 'babel-jest'
  }
}; 