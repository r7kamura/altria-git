# Magi::Git
Magi git integration plugin.

## Installation
```
# Gemfile.local
gem "magi-git", git: "git@github.com:r7kamura/magi-git"
```

## Usage
1. Configure a repository url at your job's settings page
2. Magi will clone the repository before enqueue/execute
3. Magi will enqueue a new build only if the repository is updated

## Testing
If you want to run specs of Magi::Git, please call rspec from the magi's directory.

```
$ cd /path/to/magi
$ bundle exec rspec /path/to/magi-git
```
