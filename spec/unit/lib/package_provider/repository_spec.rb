describe PackageProvider::Repository do
  let(:repo) { PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git') }
  after(:each) do
    repo.destroy
  end

  it 'class initialized' do
    #response = []
    #response << 'stdin'
    #response << 'stdout'
    #response << 'test'
    #response << 'exit 0'
    #allow(Open3).to receive(:capture3) { ["stdout","stderr", $?] }

    expect(Open3).to receive(:capture3).with({}, /.*init_repo.sh/, any_args).once
    expect(Dir.exists?(repo.repo_root)).to be true
  end
  it 'raise exception when local folder to clone does not exists' do
    expect {
      PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git','/bla/bla')
    }.to raise_error(PackageProvider::Repository::InvalidRepoPath)
  end
  it 'fetch calls Open3::capture3' do
    expect(Open3).to receive(:capture3).with({}, /.*init_repo.sh/, anything, anything, anything).once
    expect(Open3).to receive(:capture3).with({}, /git.*/, any_args).once

    repo.fetch(nil)
  end
  it 'clones repo' do
    dir = '/tmp/tt/'

    expect(Open3).to receive(:capture3).with({}, /.*init_repo.sh/, anything, anything, anything).once
    expect(Open3).to receive(:capture3).with({}, /git.*/, any_args).once
    expect(Open3).to receive(:capture3).with({}, /.*clone.sh/, any_args).once

    # MOCK FILE UTILS
    repo.clone(dir, nil, nil, false)

    FileUtils.rm_rf(dir)
  end
  it 'raise exception when destination folder exists' do
    dir = '/tmp/tt/'
    Dir.mkdir(dir)

    expect {
      repo.clone(dir, nil, [], false)
    }.to raise_error(PackageProvider::Repository::InvalidRepoPath)

    FileUtils.rm_rf(dir)
  end
end
