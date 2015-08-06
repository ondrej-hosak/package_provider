require 'tmpdir'
require 'open3'

# Namespace that handles git operations for PackageProvider
module PackageProvider
  # Class for cloning remote or local git repositories
  # and checkouting specified folders
  class Repository
    attr_reader :repo_url, :repo_root

    class InvalidRepoPath < ArgumentError
    end

    def self.temp_prefix=(tp)
      @temp_prefix = tp
    end

    def self.temp_prefix
      @temp_prefix || 'pp_repo_'
    end

    def initialize(git_repo_url, git_repo_local_root = nil)
      if git_repo_local_root
        unless Dir.exist?(git_repo_local_root)
          fail InvalidRepoPath, "Folder #{git_repo_local_root} does not exists"
        end
      end

      @repo_url = git_repo_url
      @repo_root = Dir.mktmpdir(self.class.temp_prefix)

      init_repo!(git_repo_local_root)
    end

    def clone(dest_dir, treeish, paths, use_submodules = false)
      fail InvalidRepoPath, "Folder #{dest_dir} exists" if Dir.exist?(dest_dir)

      begin
        Dir.mkdir(dest_dir)

        fetch(treeish)

        fill_sparse_checkout_file(paths)

        run_command(
          'sparse',
          {},
          [
            File.join(PackageProvider.root, 'lib', 'scripts', 'clone.sh'),
            dest_dir,
            treeish,
            use_submodules
          ],
          chdir: repo_root
        )

        dest_dir
      rescue => err
        FileUtils.rm_rf(dest_dir)
        raise
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
      run_command(
        'clone',
        {},
        [
          File.join(PackageProvider.root, 'lib', 'scripts', 'init_repo.sh'),
          repo_url,
          git_repo_local_root || ''
        ],
        chdir: repo_root
      )
    end

    def fetch!
      run_command(
        'fetch',
        {},
        [
          'git',
          '-c',
          'http.sslverify=false',
          'fetch',
          '--all'
        ],
        chdir: repo_root
      )
    end

    def fill_sparse_checkout_file(paths)
      paths = ['/**'] if paths == nil
      File.open(
        a = File.join(repo_root, '.git', 'info', 'sparse-checkout'), 'w+'
      ) do |f|
        f.puts paths.join("\n")
      end
      p a
    end

    def run_command(action, env_hash, params, options_hash)
      o, e, s = Open3.capture3(env_hash, *params, options_hash)
      unless s.success?
        puts action + ' failed:'
        puts e
        puts o
        # PackageProvider.logger.debug o
        # PackageProvider.logger.error e
      end
    end

  end
end
