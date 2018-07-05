# frozen_string_literal: true

if Rails.env.development?
  def downcase_arg(value)
    String(value).strip.downcase
  end

  def run_command(cmd, env = {})
    description = "Running '#{cmd}'"
    separator = '-' * description.length

    puts '', separator, description, separator, ''

    fail "There was an error while running '#{cmd}'" unless system(env, cmd)
  end

  def run_rubycritic_command(open_rubycritic)
    open_browser = open_rubycritic.match?(/\At(rue)?|y(es)?|s(im)?\z/)

    command_flag = '--no-browser' unless open_browser

    run_command "bundle exec rubycritic app lib #{command_flag}"
  end

  def run_rubocop_command(run_rubocop)
    skip = run_rubocop.match?(/\Af(alse)?|n(o|[aã]o)?\z/)

    run_command 'bundle exec rubocop' unless skip
  end

  desc 'Checks app health: runs tests, security checks and rubocop'
  task :health, [:run_rubocop, :open_rubycritic] do |_t, args|
    args.with_defaults(run_rubocop: 'true', open_rubycritic: 'false')

    rails_helper = Rails.root / 'spec/rails_helper.rb'
    rspec_env = { 'COVERAGE' => 'true', 'RAILS_ENV' => 'test' }

    run_command "bundle exec rspec -r#{rails_helper}", rspec_env
    run_command 'bundle exec bundle-audit update'
    run_command 'bundle exec bundle-audit check'
    run_command 'bundle exec brakeman -z'

    run_rubycritic_command downcase_arg(args.open_rubycritic)

    run_rubocop_command downcase_arg(args.run_rubocop)
  end
end
