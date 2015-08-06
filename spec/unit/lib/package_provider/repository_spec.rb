require 'pp'
require 'fakefs'


describe PackageProvider::Repository do

  PackageProvider::Repository.temp_prefix = "pp_tests_#{rand(1000)}"

  let(:repo) do
    status = double(:status)
    expect(status).to receive(:success?).and_return(true)
    expect(Open3).to receive(:capture3).with({}, /.*init_repo.sh/, any_args).once.and_return(['', '', status])
    PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git')
  end

  after(:each) do
    repo.destroy
  end

  after(:all) do
    FileUtils.rm_rf(Dir["/tmp/#{PackageProvider::Repository.temp_prefix}*"])
    FileUtils.rm_rf(Dir['/tmp/tt'])
  end

  describe '#initialize' do
    it 'constructor creates folder' do
      expect(Dir.exist?(repo.repo_root)).to be true
    end

    it 'raise exception when local folder to clone does not exists' do
      expect do
        PackageProvider::Repository.new(
          'https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git',
          '/bla/bla'
        )
      end.to raise_error(PackageProvider::Repository::InvalidRepoPath)
    end
  end

  describe '#clone' do
    let(:treeish) { '4642e6cbebcaa4a7bf94703da1d8ab827b801b34' }
    let(:dest_dir) { '/tt' }
    let(:paths) { ['README.md'] }

    it 'calls 3x Open3::capture' do
      status = double(:status)
      expect(status).to receive(:success?).and_return(true)

      expect(repo).to receive(:fetch).with(treeish).once

      FileUtils.mkdir_p(File.join(repo.repo_root, '.git', 'info'))

      expect(Open3).to receive(:capture3).with({}, /.*clone.sh/, any_args).once.and_return(['', '', status])

      repo.clone(dest_dir, treeish, paths, false)

      expect(File.read(File.join(repo.repo_root, '.git', 'info', 'sparse-checkout'))).to eq paths.join("\n") + "\n"
    end

    it 'raise exception when destination folder exists' do
      dir_path = Dir.mktmpdir(PackageProvider::Repository.temp_prefix)

      expect { repo.clone(dir_path, nil, [], false)}.to raise_error(PackageProvider::Repository::InvalidRepoPath)

      FileUtils.rm_rf(dir_path)
    end
  end

  describe '#fetch' do
    it 'calls 2x Open3::capture3' do
      status = double(:status)
      expect(status).to receive(:success?).and_return(true)

      expect(Open3).to receive(:capture3).with({}, 'git', any_args).once.and_return(['', '', status])

      repo.fetch(nil)
    end
  end

  describe '#destroy' do
    it 'cleans up repo_root' do
      expect(Dir.exist?(repo.repo_root)).to be true
      repo.destroy
      expect(Dir.exist?(repo.repo_root)).to be false
    end
  end
end
