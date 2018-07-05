if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start 'rails' do
    minimum_coverage 90
    refuse_coverage_drop

    add_filter do |source_file|
      source_file.filename =~ %r{app/channels|lib/tasks}
    end
  end
end
