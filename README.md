# The gitlab module

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Effects](#effects)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

The `gitlab` Puppet module installs and configures Omnibus Gitlab and provides custom types for creating projects and users.

## Description

The `gitlab` Puppet module installs and configures Omnibus Gitlab.  The module is currently configured to install Gitlab **7.6.2** using the **omnibus.5.3.0.ci.1-1** omnibus package.

The module also provides a number of custom types that use the Gitlab API to create projects, groups, users and keys. See the [Custom Types](#custom-types) section for details.

### Dependencies

* [camptocamp/openssl](https://forge.puppetlabs.com/camptocamp/openssl)
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

### Tested on

* Debian 7 (wheezy)
* Ubuntu 14 (trusty)
* CentOS 7

The module should work on Ubuntu 12 (precise) and CentOS 6. It should also work with other derivatives of RedHat Enterprise Linux.

## Effects

* Installs the Omnibus version of Gitlab.
* Changes the Gitlab admin user password.
* (Optional) Adds the node's root user SSH public key to Gitlab.
* (Optiona) Custom types can be used to create projects, groups, users and keys.

## Dependencies

* 
Gitlab expects to be able to send verification emails to users so your node must be able to send emails. I use [Mandrill](http://mandrillapp.com/) for this because it is avoids having to deal with SMTP blacklists. I have a [Mandrill Puppet module](https://github.com/dmcnicks/dmcnicks-mandrill.git) that can configure a variety of mailers to use Mandrill.

## Usage

Declare the `gitlab` class to install Gitlab:

    class { 'gitlab':
      admin_password => 'newpassword'
    }

To run Gitlab on an alternate port:

    class { 'gitlab':
      admin_password => 'newpassword',
      port => 8080,
      ssl_port => 8443
    }

Note that the standard HTTP port must be specified even if SSL is enabled because Gitlab configures HTTP -> HTTPS redirection.

SSL is enabled by default using a created, self-signed certificate but it can be disabled:

    class { 'gitlab':
      admin_password => 'newpassword',
      port => 8080,
      ssl => false
    }

### Custom Types

**Cautionary note: any resources created by these custom types should be managed solely by Puppet. Changes made to projects, groups, users etc created by Puppet inside Gitlab itself will be lost the next time the Puppet agent runs.**

All of the defined types use the Gitlab REST API and require the `rest-client` ruby gem to be installed:

    package { 'rest-client':
      ensure   => 'present',
      provider => 'gem'
    }

This package is declared by the `gitlab` module so it will be installed. However, it will not be available to the custom types on the first Puppet agent run, since custom types are loaded before package declarations are processed.

#### The `gitlab_session` type

The `gitlab_session` type logs into the Gitlab API and stores a returned token so that other types can connect to the API as needed.

    gitlab_session { 'sessionname':
      login    => 'root',
      password => 'rootpassword',
      url      => 'http://gitlab.site'
    }

The `login` parameter can be any user that has administrative privileges on the Gitlab site. The `url` should be the top-level URL of the site.

The name of the session is used to form dependencies between any other of the type declarations and the session declaration. Every other type declaration will include a `session` parameter for this purpose.

Note that this type does not require an `ensure` parameter because it does not change any resources itself.

#### The `gitlab_user` type

The `gitlab_user` type creates a new user in Gitlab.

    gitlab_user { 'newusername':
      ensure   => 'present',
      session  => 'sessionname',
      email    => 'valid@email.address',
      fullname => 'New User',
      password => 'userpassword'
    }

#### The `gitlab_user_key` type

The `gitlab_user_key` type adds an SSH public key to an existing Gitlab user. Any number of keys can be added to a single user

    gitlab_user_key { 'key-for-newuser':
      ensure   => 'present',
      session  => 'config',
      username => 'newusername',
      key      => 'ssh-rsa NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNN user@laptop.isp.com'
    }

The `key` value must be unbroken on a single line. It has been split up in the example above for legibility.

#### The `gitlab_group` type

The `gitlab_group` type creates a new group in Gitlab.

    gitlab_group { 'My Group':
      ensure  => 'present',
      session => 'sessionname',
      owner   => 'newusername'
    }

The optional `owner` parameter makes sure that the specified user is a member of the group with owner privileges. Changing this value will not remove old owners.

#### The `gitlab_project` type

The `gitlab_project` type creates a project in Gitlab.

    gitlab_project { 'My Big Project':
      ensure  => 'present',
      session => 'sessionname',
      owner   => 'My Group'
    }

The `owner` parameter can be the name of a group or a user. If the `owner` parameter is not specified the new project will be owned by the user that is logged into the API.

#### The `gitlab_deploy_key` type

The `gitlab_deploy_key` type adds an SSH public key as a deploy key to a project, giving the key owner read access.

    gitlab_deploy_key { 'key-for-some-app':
      ensure   => 'present',
      session  => 'config',
      project  => 'My Big Project',
      key      => 'ssh-rsa NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    NNNNNNNNNNNNNNNNNNNNNNNNNNNNNN user@laptop.isp.com'
    }

As with the `gitlab_user_key` type, the `key` value must be unbroken on a single line. 

## Reference

### The `gitlab` class

The `gitlab` class installs and configured Gitlab omnibus edition. 

#### Parameters

##### `admin_password`

(Required) The new password for the Gitlab admin user.

##### `download_url`

(Optional) the download URL for the Gitlab omnibus package. You can use this to install the latest version if the default URLs in the module are out of date.

##### `installer_file`

(Optional) The name of the local file that the downloaded Gitlab package will be saved as (Defaults to `gitlab-<os>.deb` or `gitlab-<os>.rpm` depending on OS).

##### `installer_dir`

(Optional) The local directory that the downloaded Gitlab package will be saved to.

##### `site`

(Optional) The name of the Gitlab site (defaults to FQDN of the node).

##### `port`

(Optional) The HTTP port Gitlab will listen on (defaults to 80).

##### `ssl_port`

(Optional) The SSL port Gitlab will listen on (defaults to 443).

##### `ssl`

(Optional) Enables SSL (defaults to true).

##### `worker_processes`

(Optional) The number of Gitlab worker processes to run (defaults to 1).

##### `add_root_pubkey`

(Optional) Adds the SSH public key of the node's root user to the Gitlab admin account, giving the node's root user access to all Gitlab projects. This will create an SSH key pair for the node's root user if one does not already exist (defaults to false).

##### `api_login`

(Optional) The login used to connect to the Gitlab API (defaults to root).

##### `api_password`

(Optional) The password used to connect to the Gitlab API (defaults to the default Gitlab admin user password).

## Limitations

The module has the download URLs for the 7.6.2 release of Gitlab omnibus and will default to downloading that version. If later releases are available you can specify the download URL as a parameter - you will have to choose the appropriate version for your node OS.

While the custom types are useful for creating users and projects in Gitlab, they will reverse any changes that you make inside Gitlab itself. For that reason, the custom times are best used for absolutely necessary Gitlab users and projects (for example, a Puppet user and a set of repositories for managing Puppet). Real users should be created in Gitlab itself.

## Development

I am happy to receive pull requests. 
