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

All of the defined types use the Gitlab REST API and require the `rest-client`
ruby gem installed:

    package { 'rest-client':
      ensure => 'present',
      provider => 'gem'
    }

With that in place, the only caveat for now is that each defined type declaration must include the API URL, admin username and password until I can work out a better way of handling authorisation.

You can create a new user in Gitlab with:

    gitlab_user { 'username':
      ensure       => 'present',
      password     => 'initialpassword',
      email        => 'email@address.com',
      fullname     => 'Full Name'
      api_url      => 'https://gitlab.url/api/v3',
      api_login    => 'root',
      api_password => 'adminpassword'
    }

You can add a public key to an existing user with:

    gitlab_user_key { 'username-key':
      ensure       => 'present',
      username     => 'existinguser',
      key          => 'public-key-as-string',
      api_url      => 'https://gitlab.url/api/v3',
      api_login    => 'root',
      api_password => 'adminpassword'
    }

You can create a group with:

    gitlab_group { 'Group Name':
      ensure       => 'present',
      path         => 'group-name',
      api_url      => 'https://gitlab.url/api/v3',
      api_login    => 'root',
      api_password => 'adminpassword'
    }

You can create a new project with:

    gitlab_project { 'Project Name':
      ensure       => 'present',
      group        => 'group-name',
      api_url      => 'https://gitlab.url/api/v3',
      api_login    => 'root',
      api_password => 'adminpassword'
    }

Finally you can add deploy keys to a project with:

    gitlab_deploy_key { 'project-key':
      ensure       => 'present',
      project      => 'project-name',
      key          => 'public-key-as-string',
      api_url      => 'https://gitlab.url/api/v3',
      api_login    => 'root',
      api_password => 'adminpassword'
    }

## Reference

### The `gitlab` class

The `gitlab` class does ...

#### Parameters

##### `param`

Description.

## Limitations



## Development

I am happy to receive pull requests. 
