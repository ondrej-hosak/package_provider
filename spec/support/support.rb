# Namespace that handles git operations for PackageProvider
module PackageProvider
  module Spec
    # Helper module with methods to support unit and integratin tests
    class Helpers
      def self.test_git_status(git_repo_local_path)
        system('git status', chdir: git_repo_local_path)
      end
      def self.get_temp_dir_name(prefix)
        t = Dir.mktmpdir(prefix)
        FileUtils.rm_rf(t)
        t
      end
    end
  end
end
