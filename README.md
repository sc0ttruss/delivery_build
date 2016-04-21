# delivery_build

Configure a build node for chef delivery

Based on, and replicating manual instructions from:-

https://github.com/trickyearlobe/manual_install_chef_products/blob/master/manual_install/delivery_build_nodes.md

# grab the packages and put them here ~/chef-kits/chef
chefdk
delivery cli
opscode-push-jobs-client

# get then all from here....
https://packages.chef.io/stable/el/7/

The following 3rd party packages are also required

    git (Should be in the OS's repo)
    runit (Can be obtained from https://packagecloud.io/imeyer/runit)

    You will also need to install some Ruby gems which can be obtained from https://rubygems.org

    chef gem install knife-supermarket
    chef gem install knife-push

    # Optional for Sentry Raven
    # chef gem install sentry-raven

If you don't have internet access or a local gem server you will need to download them (and all their dependencies) manually and copy them over.
