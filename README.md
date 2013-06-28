# Altria::Git
Altria git integration plugin.

## Installation
```
# Gemfile.local
gem "altria-git", git: "git@github.com:r7kamura/altria-git.git"
```

## Usage
1. Configure a repository url at your job's settings page
2. Altria will clone the repository before enqueue/execute
3. Altria will enqueue a new build only if the repository is updated

## Testing
If you want to run specs of Altria::Git, please call rspec from the altria's directory.

```
$ cd /path/to/altria
$ bundle exec rspec /path/to/altria-git
```
