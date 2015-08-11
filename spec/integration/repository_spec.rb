describe PackageProvider::Repository do
  PackageProvider::Repository.temp_prefix = "pp_integration_tests_#{rand(1000)}"
  persist_folders_prefix = 'pp_integration_per'

  let(:fake_remote_repo_dir) do
    File.join(PackageProvider.root, 'spec', 'factories', 'testing-repo')
  end
  let(:repo) do
    PackageProvider::Repository.new(fake_remote_repo_dir)
  end

  after(:each) do
    repo && repo.destroy
  end

  describe '#initialize' do
    it 'makes local copy' do
      expect(
        PackageProvider::Spec::Helpers.test_git_status(repo.repo_root)
      ).to be true
    end
  end

  describe '#clone' do
    let(:dest_dir) do
      PackageProvider::Spec::Helpers.get_temp_dir_name(persist_folders_prefix)
    end
    after(:each) do
      FileUtils.rm_rf dest_dir rescue nil
    end

    it 'clones docs folder from test repo' do
      paths = ['docs/**']

      repo.clone(dest_dir, '9191ed1ad760d66e84ef2e6fc24ea85e70404638', paths)

      expect(File.exist?(File.join(dest_dir, 'README.md'))).to be false
      expect(File.exist?(File.join(dest_dir, 'docs', 'doc1.txt'))).to be true
      expect(File.exist?(File.join(dest_dir, 'docs', 'doc2.txt'))).to be true
    end

    it 'clones master branch' do
      paths = ['README.md']

      repo.clone(dest_dir, '02fc247decfa35930484559fa633da4a1de4e14c', paths)

      expect(File.exist?(File.join(dest_dir, 'README.md'))).to be true
      expect(Dir.exist?(File.join(dest_dir, 'docs'))).to be false
    end

    context 'when submodule switch is on' do
      let(:submodule_repo_root) { File.join(PackageProvider.root, 'spec', 'factories', 'testing-submodule-repo') }
      let(:submodule_dir) { File.join('/', 'tmp', 'submodule_repo') }

      pending "write mount --bind #{PackageProvider.root}/spec/factories/testing-submodule-repo /tmp/submodule_repo as root for this test" unless Dir.exist?('/tmp/submodule_repo')
      it 'clones submodule' do
        paths = ['/submodule', '.gitmodules']

        repo.clone(
          dest_dir,
          'e5f69f823d80c0c00deb448e88cf56828cb48351',
          paths,
          true)

        pth_subm_folds = File.join(dest_dir, 'submodule', 'submodule_sources')
        pth_to_readme = File.join(dest_dir, 'submodule', 'README.md')

        expect(File.exist?(pth_to_readme)).to be true
        expect(Dir.exist?(pth_subm_folds)).to be false
      end

      it 'clones new version of submodule' do
        paths = ['/**']

        repo.clone(
          dest_dir,
          '23e4306cc6e8fe5122f075be971e6155e00b5ad9',
          paths,
          true)

        pth_subm_folds = File.join(dest_dir, 'submodule', 'submodule_sources')
        pth_to_readme = File.join(dest_dir, 'submodule', 'README.md')

        expect(File.exist?(pth_to_readme)).to be true
        expect(Dir.exist?(pth_subm_folds)).to be true
      end
    end
  end
end
