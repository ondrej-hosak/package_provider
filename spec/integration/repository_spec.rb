require 'tempfile'

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
    repo.destroy
  end

  after(:all) do
    FileUtils.rm_rf Dir["/tmp/#{persist_folders_prefix}*"]
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
    let(:dest_dir2) do
      PackageProvider::Spec::Helpers.get_temp_dir_name(persist_folders_prefix)
    end

    it 'clones doc_branch from test repo' do
      paths = ['doc/**']

      repo.clone(dest_dir, 'e13ddf31e4ce1505aeb5a560e7b96775c9083321', paths)

      expect(File.exist?(File.join(dest_dir, 'README.md'))).to be false
      expect(File.exist?(File.join(dest_dir, 'doc', 'doc1.txt'))).to be true
      expect(File.exist?(File.join(dest_dir, 'doc', 'doc2.txt'))).to be true
    end

    it 'clones master branch' do
      paths = ['README.md']

      repo.clone(dest_dir2, 'b2a711aa52845f192c1f428fc77453ff60cd2c76', paths)

      expect(File.exist?(File.join(dest_dir2, 'README.md'))).to be true
      expect(Dir.exist?(File.join(dest_dir2, 'doc'))).to be false
    end
  end
end
