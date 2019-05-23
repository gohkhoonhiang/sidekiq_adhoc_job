require 'sidekiq/web'

RSpec.shared_context 'request setup' do

  def compact_html(html)
    html.gsub(/\n\s*\</, '<').gsub(/\n\s*(?<word>\w+)/) { $~[:word] }.strip
  end

  let(:app) { Sidekiq::Web }

  before do
    ENV['RACK_ENV'] = 'test'
  end

end
