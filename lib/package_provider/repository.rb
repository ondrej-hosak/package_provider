require 'tmpdir'
require 'open3'

module PackageProvider
  class Repository

    attr_reader :repo_url, :repo_root

    class InvalidRepoPath < ArgumentError
    end

    def initialize(git_repo_url, git_repo_local_root = nil)

      if git_repo_local_root
        raise InvalidRepoPath, "Folder #{git_repo_local_root} does not exists" unless Dir.exists?(git_repo_local_root)
      end

      @repo_url = git_repo_url
      @repo_root = Dir.mktmpdir('pp_repo_')

      init_repo!(git_repo_local_root)
    end

    def clone(dest_dir, treeish, paths, use_submodules = false)
      raise InvalidRepoPath unless !Dir.exists?(dest_dir)

      begin
        Dir.mkdir(dest_dir)

        fetch(treeish)

        File.open(File.join(repo_root, ".git", "info", "sparse-checkout"), 'w+') do |f|
          f.puts paths.join("\n")
        end

        o, e, s = Open3.capture3({}, File.join(PackageProvider.root, 'lib', 'scripts', 'clone.sh'), dest_dir, treeish || "HEAD", { chdir: repo_root })
        processOutput(o,e,s, 'sparse')

        dest_dir
      rescue
        FileUtils.rm_rf(dest_dir)
      end
    end

    def fetch(treeish = nil)
      fetch!
    end

    def destroy
      FileUtils.rm_rf(@repo_root)
    end

    private

    def init_repo!(git_repo_local_root)
      o, e, s = Open3.capture3({}, File.join(PackageProvider.root, 'lib', 'scripts', 'init_repo.sh'), repo_url, git_repo_local_root || "", { chdir: repo_root })
      processOutput(o,e,s, 'clone')
    end

    def fetch!
      o, e, s = Open3.capture3({}, "git", "-c", "http.sslverify=false", "fetch", "--all", { chdir: repo_root })
      processOutput(o, e, s, 'fetch')
    end

    def processOutput(stdout, stderr, status, action)
      puts status
      if !status.success?
        puts action + " failed:"
        puts stderr
        puts stdout
        #PackageProvider.logger.debug o
        #PackageProvider.logger.error e
      end
    end

  end
end
