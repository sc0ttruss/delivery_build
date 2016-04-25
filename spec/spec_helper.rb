require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault'

#Turn on coverage calculation
#ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.color = true
  config.failure_color = :cyan
  config.formatter = :documentation
  config.tty = true
end
