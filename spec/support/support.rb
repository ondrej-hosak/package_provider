# Namespace that handles git operations for PackageProvider
module PackageProvider
  module Spec
    # Helper module with methods to support unit and integratin tests
    class Helpers
      def self.git_current_id(git_repo_local_path)
        Dir.chdir(git_repo_local_path) do
          system('git log -1')
        end
      end
    end
  end
end
