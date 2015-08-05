$: << 'lib'

require 'package_provider'
require 'package_provider/repository'

repo = PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git', '/home/vagrant/repos/onlinekitchen/')
#repo = PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git', '/bla/bla/')
#puts repo.repo_root
#repo.fetch

repo.clone('/tmp/test_cloned_repo/', nil, ["/spec"], false)
repo.clone('/tmp/test_cloned_repo2/', nil, ["*.rb"], false)
repo.clone('/tmp/test_cloned_repo3/', nil, ["/spec/**"], false)
#repo.destroy

#repo2 = PackageProvider::Repository.new('https://ondrej.hosak@stash.cz.avg.com/scm/ddtf/onlinekitchen.git')
#puts repo2.repo_root
#repo2.fetch
#repo2.destroy
