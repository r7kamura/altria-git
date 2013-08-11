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
        return unless has_repository_url? 
        command("cd #{path} && git checkout -b #{job.branch_name} origin/#{job.branch_name}") unless checkouted?
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
        !!command("ch #{path} && git branch").match(/\*\s+#{job.branch_name}/)
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

      def update_revision
        job.current_build.update_properties(revision: revision)
      end
    end
  end
end
