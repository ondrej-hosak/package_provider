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
    # rubocop:disable TrivialAccessors
    def self.temp_prefix=(tp)
      @temp_prefix = tp
    end

    def self.temp_prefix
      @temp_prefix || 'pp_repo_'
    end
    # rubocop:enable TrivialAccessors
    def initialize(git_repo_url, git_repo_local_cache_root = nil)
      if git_repo_local_cache_root
        unless Dir.exist?(git_repo_local_cache_root)
          fail InvalidRepoPath, "#{git_repo_local_cache_root} does not exists"
        end
      end

      @repo_url = git_repo_url
      @repo_root = Dir.mktmpdir(self.class.temp_prefix)

      init_repo!(git_repo_local_cache_root)
    end

    def logger
      PackageProvider.logger
    end

    def clone(dest_dir, treeish, paths, use_submodules = false)
      fail InvalidRepoPath, "Folder #{dest_dir} exists" if Dir.exist?(dest_dir)

      logger.debug "clonning repo #{repo_root}: " \
                   " [dest_dir: #{dest_dir.inspect}, " \
                   "treeish: #{treeish.inspect}, " \
                   "use_submodules: #{use_submodules.inspect}]"

      begin
        Dir.mkdir(dest_dir)
        fetch(treeish)

        fill_sparse_checkout_file(paths)
        command = [
          File.join(PackageProvider.root, 'lib', 'scripts', 'clone.sh'),
          repo_root,
          dest_dir,
          treeish
        ]
        command << '--use-submodules' if use_submodules
        run_command({}, command, chdir: repo_root)

        dest_dir
      rescue => err
        FileUtils.rm_rf(dest_dir)
        logger.error "Cannot clone repository #{repo_root}: #{err}"
        raise
      end
    end

    # rubocop:disable UnusedMethodArgument
    def fetch(treeish = nil)
      fetch!
    end
    # rubocop:enable UnusedMethodArgument
    def destroy
      FileUtils.rm_rf(@repo_root)
    end

    private

    def init_repo!(git_repo_local_cache_root)
      run_command(
        {},
        [
          File.join(PackageProvider.root, 'lib', 'scripts', 'init_repo.sh'),
          repo_url,
          git_repo_local_cache_root || ''
        ],
        chdir: repo_root
      )
    end

    def fetch!
      run_command(
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
      paths = ['/**'] if paths.nil?
      path = File.join(repo_root, '.git', 'info', 'sparse-checkout')

      logger.debug "Setting sparse-checkout to: #{paths.join("\n")}"
      File.open(path, 'w+') do |f|
        f.puts paths.join("\n")
      end
    end

    def run_command(env_hash, params, options_hash)
      logger.debug "Running shell command: #{params.inspect}"
      o, e, s = Open3.capture3(env_hash, *params, options_hash)

      if s.success?
        logger.info "Command #{params.inspect} returns #{o.inspect} on stdout" unless o.empty?
        logger.info "Command #{params.inspect} returns #{e.inspect} on stderr" unless e.empty?
      else
        logger.error "Command #{params.inspect} failed!" \
                     "stdout: #{o.inspect}, stderr: #{e.inspect}"
      end
    end
  end
end
