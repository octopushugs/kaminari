# frozen_string_literal: true
# require 'rails/all'
require 'action_controller/railtie'
require 'action_view/railtie'

require 'fake_app/active_record/config' if defined? ActiveRecord
# config
app = Class.new(Rails::Application)
app.config.secret_key_base = app.config.secret_token = '3b7cd727ee24e8444053437c36cc66c4'
app.config.session_store :cookie_store, :key => '_myapp_session'
app.config.active_support.deprecation = :log
app.config.eager_load = false
# Rails.root
app.config.root = File.dirname(__FILE__)
Rails.backtrace_cleaner.remove_silencers!
app.initialize!

# routes
app.routes.draw do
  resources :users
  resources :addresses do
    get 'page/:page', :action => :index, :on => :collection
  end

  get 'paginate_without_count', controller: :users, action: :paginate_without_count
end

#models
require 'fake_app/active_record/models' if defined? ActiveRecord

# controllers
class ApplicationController < ActionController::Base; end
class UsersController < ApplicationController
  def index
    @users = User.page params[:page]
    render :inline => <<-ERB
<%= @users.map(&:name).join("\n") %>
<%= paginate @users %>
ERB
  end

  def paginate_without_count
    @users = User.page(params[:page]).without_count
    render inline: <<-ERB
      <%= @users.map(&:name).join("\n") %>
      <%= paginate_without_count @users %>
    ERB
  end
end

if defined? ActiveRecord
  class AddressesController < ApplicationController
    def index
      @addresses = User::Address.page params[:page]
      render :inline => <<-ERB
  <%= @addresses.map(&:street).join("\n") %>
  <%= paginate @addresses %>
  ERB
    end
  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
