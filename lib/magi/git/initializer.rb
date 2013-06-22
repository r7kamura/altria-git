Build.property(:revision)
Job.property(:repository_url)
Job.before_enqueue { Magi::Git::Repository.new(self).before_enqueue }
Job.before_execute { Magi::Git::Repository.new(self).before_execute }
Job.after_execute { Magi::Git::Repository.new(self).after_execute }
