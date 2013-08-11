require "open3"

module Altria
  module Git
    class Repository
      attr_reader :job

      def initialize(job)
        @job = job
      end

      def before_enqueue
        if has_repository_url?
          update
          updated_since_last_finished_build?
        end
      end

      def before_execute
        clone if has_repository_url?
        checkout if has_branch_name?
      end

      def after_execute
        update_revision if has_repository_url?
      end

      def clone
        command("git clone #{job.repository_url} #{path}") unless cloned?
      end

      def checkout
        if has_repository_url? && !checkouted? && has_remote_branch?
          command("cd #{path} && git checkout -b #{job.branch_name} origin/#{job.branch_name}")
        end
      end

      def update
        clone
        pull
      end

      def pull
        command("cd #{path} && git pull")
      end

      def revision
        command("cd #{path} && git rev-parse HEAD").rstrip
      end

      def updated_since_last_finished_build?
        revision != job.last_finished_build.try(:revision)
      end

      def cloned?
        path.join(".git").exist?
      end

      def checkouted?
        command("cd #{path} && git rev-parse --abbrev-ref HEAD").rstrip == job.branch_name
      end

      def command(script)
        Open3.capture3(script)[0]
      end

      def path
        job.workspace.path + "repository"
      end

      def has_repository_url?
        job.repository_url.present?
      end

      def has_branch_name?
        job.branch_name.present?
      end

      def has_remote_branch?
        !!command("cd #{path} && git branch -r").match(/^\s+origin\/#{Regexp.escape(job.branch_name)}$/)
      end

      def update_revision
        job.current_build.update_properties(revision: revision)
      end
    end
  end
end
