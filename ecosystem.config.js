module.exports = {
  apps: [{
    name: 'rbis-app',
    script: 'npm',
    args: 'start -- -p 3001',
    env: { NODE_ENV: 'production' }
  }]
}
