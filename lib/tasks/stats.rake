# frozen_string_literal: true

task stats: 'app:statsetup'

namespace :app do
  task :statsetup do
    require 'rails/code_statistics'

    ::STATS_DIRECTORIES.unshift ['Transactions', 'app/transactions']
  end
end
