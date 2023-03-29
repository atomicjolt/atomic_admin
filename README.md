# atomic_admin
Engine to provide apis that power the atomic jolt admin app

# Usage

Add the gem to your project:
gem 'atomic_admin',  git: 'https://github.com/atomicjolt/atomic_admin.git', tag: '0.1.0'

Add the following to routes.rb:
  ```
  namespace :admin do
    mount AtomicAdmin::Engine => "/"
  end
  ```