$LOAD_PATH << 'lib'

require 'package_provider'
require 'package_provider/repository'

repo = PackageProvider::Repository.new(
  'https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git',
  '/home/vagrant/repos/onlinekitchen/')

puts repo.repo_root
# repo.fetch

repo.clone('/tmp/onlinekitchen_repo1', nil, ['/spec'], false)
# puts 'clone 1'
# repo2 = repo.clone('/tmp/onlinekitchen/2', nil, ["*.rb"], false)
# puts 'clone 2'
# repo3 = repo.clone('/tmp/onlinekitchen/3', nil, nil, false)
# puts 'clone 3'
# repo.destroy

# repo_2 = PackageProvider::Repository.new(
#  'https://ondrej.hosak@stash.cz.avg.com/scm/avg/avg.git',
#  '/home/vagrant/repos/avg/')

# puts repo_2.repo_root
# repo_2.clone(
#  '/tmp/avg_repo1',
#  '8970bf7bbd1220cab59a0979823f3e8d421623f',
#  ['automation', 'error', 'msbuild'],
#  false)
# repo2.destroy
