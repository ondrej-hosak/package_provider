describe PackageProvider::Repository do
  PackageProvider::Repository.temp_prefix = "pp_integration_tests_#{rand(1000)}"

  let(:fake_remote_repo_dir) do
    File.join(PackageProvider.root, 'spec', 'factories', 'testing-repo')
  end

  let(:repo) do
    PackageProvider::Repository.new(fake_remote_repo_dir)
  end

  after(:each) do
    repo.destroy
  end

  after(:all) do
    FileUtils.rm_rf(Dir["/tmp/#{PackageProvider::Repository.temp_prefix}*"])
    FileUtils.rm_rf(Dir['/tmp/tt'])
  end

  # let(:repo_with_local) {
  #   local_git_copy = Dir.mktmpdir
  #   system("git clone #{fake_remote_repo_dir} #{local_git_copy}")
  #   PackageProvider::Repository.new(
  #     'spec/factories/testing-repo'
  # )}

  describe '#initialize' do
    it 'makes local copy' do
      # system('ls #{repo.repo_root}/.git')
      # expect(File.exist?('#{repo.repo_root}/.git/HEAD')).to be true
      PackageProvider::Spec::Helpers.git_current_id(repo.repo_root)
      #TODO verify git repo
    end
  end

  describe '#clone' do
    it 'clones doc_branch from test repo' do
      paths = ['docs']
      dest_dir = '/tmp/tt'

      repo.clone(dest_dir, 'docs_branch', paths) #coomit hash

      expect(File.exist?('#{dest_dir}/README.md')).to be false
    end
  end
end
