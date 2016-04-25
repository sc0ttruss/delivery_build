# delivery_build cookbook

Configure a build node for chef delivery

Based on instructions for [manually installing Chef products](https://github.com/trickyearlobe/manual_install_chef_products)

# Attributes

### Package Locations
The package locations are controlled by the following attributes:-

```ruby
default['delivery_build']['use_package_manager'] = false
default['delivery_build']['base_package_url'] = "file:///var/tmp"
```

### Credentials
Credentials are loaded from a ```delivery_secrets``` item in a ```vault```, ```databag``` or ```encrypted_databag```

```ruby
default['delivery_build']['secrets_type']   = "vault"
default['delivery_build']['secrets_source'] = "delivery_secrets_vault"
default['delivery_build']['chef_username']  = "svc-delivery"
```

### Server URL's

```ruby
# Delivery and SUpermarket URL's to retrieve their certificates
default['delivery_build']['delivery_url']    = 'https://delivery.chefdemo.net'
default['delivery_build']['supermarket_url'] = 'https://supermarket.chefdemo.net'
```

# Creating the credentials Vault/Bag
Make a JSON file with the following structure:-

```json
{
  "id":"delivery_secrets",
  "builder_key":"Some ssh private key data with newlines replaced by \n",
  "delivery_pem":"Some PEM data with newlines replaced by \n"
}
```

Upload to a ChefVault

```ruby
# Add a new vault with an admin called admin_user
# and grant access to builders matching "builder*"
knife vault create delivery_secrets_vault delivery_secrets \
  -J delivery_secrets.json -A admin_user -S "name:builder*" -m client

```

# Packages

Packages for creating a private repo can be obtained from:-

* https://packages.chef.io/stable (For Chef packages)
* https://packagecloud.io/imeyer/runit (for runit)
* The OS distribution's repo (for git)
* http://rubygems.org (For ruby gems)

If using the OS package manager please ensure you have a repo configured which contains the following packages:-

* chefdk
* delivery-cli
* push-jobs-client
* runit
* git
* knife-push gem
* knife-supermarket gem

If using remote file download instead of the OS package manager, we need to know the exact filenames so place them in attributes like this:-

```ruby
default['delivery_build']['packages']['chefdk'] = 'chefdk-0.12.0-1.el7.x86_64.rpm'
default['delivery_build']['packages']['delivery-cli'] ='delivery-cli-20160317163950-1.el6.x86_64.rpm'
default['delivery_build']['packages']['push-jobs-client'] ='push-jobs-client-1.3.4-1.el7.x86_64.rpm'
default['delivery_build']['packages']['runit'] ='runit-2.1.2-3.el7.centos.x86_64.rpm'
```

## Example: Using a file or http/https URL

```ruby
default['delivery_build']['use_package_manager'] = false
default['delivery_build']['base_package_url'] = "http://my_package_source/packages/chef"
```

## Using package download in test kitchen
Place all the packages and gems in ~/chef-kits/chef
