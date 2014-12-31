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




## Effects

* Installs the Omnibus version of Gitlab.

## Usage


### Defined Types

** Cautionary note: any resources created inside Gitlab by these types will be managed solely by Puppet. The created projects, groups, users and so on will not be able to be changed or deleted through the Gitlab user interface. **

All of the defined types use the Gitlab REST API and require the `rest-client` ruby gem installed:

    package { 'rest-client':
      ensure   => 'present',
      provider => 'gem'
    }

#### The `gitlab_session` type

The `gitlab_session` type logs into the Gitlab API and stores a returned token so that other types can connect to the API as needed.

    gitlab_session { 'sessionname':
      login    => 'root',
      password => 'rootpassword',
      url      => 'http://gitlab.site'
    }

The `login` parameter can be any user that has administrative privileges on the Gitlab site. The `url` should be the top-level URL of the site.

The name of the session is used to form dependencies between any other of the type declarations and the session declaration. Every other type declaration will include a `session` parameter for this purpose.

#### The `gitlab_user` type

    gitlab_user { 'newusername':
      ensure   => 'present',
      session  => 'sessionname',
      email    => 'valid@email.address',
      fullname => 'New User',
      password => 'userpassword'
    }

#### The `gitlab_user_key` type

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

    gitlab_group { 'My Group':
      ensure  => 'present',
      session => 'sessionname'
    }

#### The `gitlab_project` type

The `gitlab_project` type creates a project:

    gitlab_project { 'My Big Project':
      ensure  => 'present',
      session => 'sessionname',
      owner   => 'My Group'
    }

The `owner` can be the name of a group or a user. If it is left out the project will be owned by the user that logged into the API.

#### The `gitlab_deploy_key` type

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

The `gitlab` class ...

#### Parameters

##### `param`

Description.

## Limitations



## Development

I am happy to receive pull requests. 
