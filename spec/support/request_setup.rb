require 'sidekiq/web'
require 'base64'

RSpec.shared_context 'request setup' do
  def compact_html(html)
    html.gsub(/\n\s*\</, '<').gsub(/\n\s*(?<word>\w+)/) { $~[:word] }.strip
  end

  def disable_csrf
    allow_any_instance_of(Sidekiq::Web::CsrfProtection).to receive(:accept?).and_return(true)
  end

  let(:app) { Sidekiq::Web }

  before do
    ENV['RACK_ENV'] = 'test'
    env 'rack.session', csrf: Base64.urlsafe_encode64('token')
  end
end
