# Magi::Git
Magi git integration plugin.

## Installation
```
gem "magi-git"
```

## Usage
1. Configure a repository url at your job's settings page
2. Magi will clone the repository before enqueue/execute
3. Magi will enqueue a new build only if the repository is updated
