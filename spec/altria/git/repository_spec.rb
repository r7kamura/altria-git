require File.expand_path("../../../spec_helper", __FILE__)

describe Altria::Git::Repository do
  let(:repository) do
    described_class.new(job)
  end

  let(:job) do
    FactoryGirl.create(:job, properties: { "repository_url" => "repository_url", "branch_name" => "branch_name" })
  end

  let(:build) do
    FactoryGirl.create(:build, job: job, finished_at: nil)
  end

  describe "#before_enqueue" do
    before do
      build.update_attributes(finished_at: Time.now)
    end

    context "without repository url" do
      before do
        job.repository_url = nil
      end

      it "does nothing" do
        repository.should_not_receive(:update)
        repository.should_not_receive(:pull)
        repository.before_enqueue
      end
    end

    context "with repository url" do
      it "updates repository" do
        repository.should_receive(:update)
        repository.before_enqueue
      end
    end

    context "when updated" do
      before do
        repository.stub(revision: "1", update: nil)
        build.update_properties(revision: "2")
      end

      it "returns true" do
        repository.before_enqueue.should == true
      end
    end

    context "when not updated" do
      before do
        repository.stub(revision: "1", update: nil)
        build.update_properties(revision: "1")
      end

      it "returns false" do
        repository.before_enqueue.should == false
      end
    end
  end

  describe "#before_execute" do
    context "without repository url" do
      before do
        job.repository_url = nil
      end

      it "does nothing" do
        repository.should_not_receive(:clone)
        repository.before_execute
      end
    end

    context "with repository url" do
      it "calls .clone" do
        repository.should_receive(:clone)
        repository.before_execute
      end

      context "with branch name" do
        it "calls .checkout" do
          repository.should_receive(:checkout)
          repository.before_execute
        end
      end

      context "without branch name" do
        before do
          job.branch_name = nil
        end

        it "does nothing" do
          repository.should_not_receive(:checkout)
          repository.before_execute
        end
      end
    end
  end

  describe "#after_execute" do
    before do
      repository.stub(revision: "1")
      build.update_attributes(started_at: Time.now)
    end

    context "without repository url" do
      before do
        job.repository_url = nil
      end

      it "does nothing" do
        repository.after_execute
        job.current_build.revision.should == nil
      end
    end

    context "with repository_url" do
      it "updates revision" do
        repository.after_execute
        job.current_build.revision.should == "1"
      end
    end
  end

  describe "#clone" do
    context "when already cloned" do
      before do
        path = repository.path.tap(&:mkpath).join(".git")
        FileUtils.touch(path)
      end

      it "does nothing" do
        repository.should_not_receive(:command)
        repository.clone
      end
    end

    context "when not cloned" do
      it "clones repository" do
        repository.should_receive(:command).with("git clone #{job.repository_url} #{repository.path}")
        repository.clone
      end
    end
  end

  describe "#checkout" do
    context "when already checkouted" do
      before do
        path = repository.path.tap(&:mkpath).join(".git")
        FileUtils.touch(path)
        repository.stub(:checkouted?).and_return(true)
      end

      it "does nothing" do
        repository.should_not_receive(:command)
        repository.checkout
      end
    end

    context "when not checkouted" do
      let(:path) { '/home/r7kamura/altria/tmp/workspace/jobs/1/repository' }

      before do
        repository.stub(:checkouted?).and_return(false)
        repository.stub(:path).and_return(path)
      end

      it "checkouts repository" do
        repository.should_receive(:command).with("cd #{path} && git checkout -b #{job.branch_name} origin/#{job.branch_name}")
        repository.checkout
      end
    end
  end

  describe "#path" do
    it "returns workspace pathname for the job" do
      repository.path.should == Pathname.new("#{Dir.pwd}/tmp/workspace/jobs/#{job.id}/repository")
    end
  end
end
