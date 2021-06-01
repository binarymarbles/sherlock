# encoding: utf-8

class Sherlock::Controllers::Dashboard < Sherlock::Sinatra::BaseController

  get '/' do
    title('Sherlock Dashboard')
    render_template :index
  end

end
