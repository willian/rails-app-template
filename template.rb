RAW_REPO_URL = 'https://raw.githubusercontent.com/willian/rails-app-template/master'

# GEMS

gsub_file 'Gemfile', /^gem\s\'tzinfo\-data.*$/i, ''
gsub_file 'Gemfile', /^\#\sUse\sCoffeeScript.*/, ''
gsub_file 'Gemfile', /^gem\s\'coffee\-.*$/i, ''
gsub_file 'Gemfile', /^group\s:.*end$/m, ''

gem 'active_model_serializers', '~> 0.10'
gem 'bcrypt', '~> 3.1'
gem 'deterministic', '~> 0.16'
gem 'pg', '~> 0.18'
gem 'poltergeist', '~> 1.13'
gem 'redis', '~> 3.0'

gem_group :development, :test do
  gem 'byebug', platform: :mri
  gem 'capybara', '~> 2.14'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

gem_group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '>= 3.3.0'
end

gem_group :test do
  gem 'ffaker'
  gem 'shoulda-matchers'
end

run 'bundle install'
run 'git add . && git ci -m "FIRST"'

# GENERATORS

application <<-GENERATORS

    config.generators do |g|
      g.assets false
      g.factory_girl 'spec/factories'
      g.integration_tool :rspec
      g.request_specs true
      g.routing_specs false
      g.test_framework :rspec
      g.view_specs false
    end
GENERATORS

# LOCALES

remove_file 'config/locales/en.yml'

%w[en-US pt-BR].map do |locale|
  get(
    "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/#{locale}.yml",
    "config/locales/default.#{locale}.yml"
  )
end

# 404 ERROR CATCHER

gsub_file 'app/controllers/application_controller.rb', /^\s\sprotect_from_forgery\swith\:\s\:exception$/i, <<-CONTROLLER
  protect_from_forgery with: :exception

  # rescue_from "ActiveRecord::RecordNotFound" do |e|
  #   render file: "\#{Rails.root}/public/404.html", layout: false, status: 404
  # end
CONTROLLER

# WEBPACK & REACT

gem 'react_on_rails', '8.0.3'
run 'bundle install'
run 'git add . && git ci -m "Add ReactOnRails gem"'

generate 'react_on_rails:install'
run 'bundle install && yarn install'

run 'git add . && git ci -m "Install ReactOnRails dependencies"'

# NPM DEPENDENCIES

npm_packages = %w[
  axios
  babel-polyfill
  react-tap-event-plugin
  turbolinks
  webpacker-react
]
npm_dev_packages = %w[
  babel-eslint
  babel-jest
  babel-preset-es2015
  chalk
  enzyme
  eslint
  eslint-config-standard
  eslint-config-standard-jsx
  eslint-config-standard-react
  eslint-plugin-promise
  eslint-plugin-react
  eslint-plugin-standard
  jest
  jest-enzyme
  nightmare
  npm-run-all
  react-addons-test-utils
  react-dev-utils
  rimraf
  snazzy
  standard
]
run "yarn add #{npm_packages.join(' ')}"
run "yarn add -D #{npm_dev_packages.join(' ')}"

# NPM SCRIPTS

gsub_file 'package.json', /^\s\s\"dependencies\"\:\s\{$/, <<-NPM_SCRIPTS
  "scripts": {
    "dev:rm": "rimraf public/webpack/development/*",
    "dev:build": "cd client && bundle exec rake react_on_rails:locale && yarn run build:development",
    "dev:server": "npm-run-all -p dev:rm dev:build",
    "lint": "standard client/**/*"
  },
  "dependencies": {
NPM_SCRIPTS

# LINTER & JEST

gsub_file 'package.json', /^\s\s\}\n\}$/, <<-NPM_CONFIG
  },
  "standard": {
    "parser": "babel-eslint",
    "ignore": [
      "node_modules/",
      "src/index.html"
    ],
    "globals": [
      "process",
      "webpackIsomorphicTools"
    ],
    "plugins": [
      "react",
      "promise"
    ]
  },
  "jest": {
    "collectCoverageFrom": [
      "<rootDir>/client/bundles/**/*.{js,jsx}",
      "<rootDir>/client/src/**/*.{js,jsx}"
    ],
    "setupFiles": [
      "<rootDir>/client/config/polyfills.js"
    ],
    "testPathIgnorePatterns": [
      "<rootDir>/node_modules/",
      "<rootDir>/config/webpack/",
      "<rootDir>/(vendor)/",
      "<rootDir>/client/(build|docs|node_modules|scripts|vendor)/"
    ],
    "testEnvironment": "node",
    "testURL": "http://localhost",
    "transform": {
      "^.+\\\\\\\\.(js|jsx)$": "<rootDir>/node_modules/babel-jest",
      "^.+\\\\\\\\.css$": "<rootDir>/client/config/jest/cssTransform.js",
      "^(?!.*\\\\\\\\.(js|jsx|css|json)$)": "<rootDir>/client/config/jest/fileTransform.js"
    },
    "transformIgnorePatterns": [
      "/node_modules/.+\\\\\\\\.(js|jsx)$"
    ],
    "moduleNameMapper": {
      "^react-native$": "react-native-web"
    }
  }
}
NPM_CONFIG

run 'git add . && git ci -m "Install NPM dependencies"'

# RSPEC

generate 'rspec:install'

# DOCKER
if yes?('Would you like to use Docker?')
  remove_file 'config/database.yml'
  get "#{RAW_REPO_URL}/defaults/docker/boot", 'bin/boot'
  get "#{RAW_REPO_URL}/defaults/docker/development.env", './development.env'
  get "#{RAW_REPO_URL}/defaults/docker/docker-compose.yml", './docker-compose.yml'
  get "#{RAW_REPO_URL}/defaults/docker/Dockerfile", './Dockerfile'
  get "#{RAW_REPO_URL}/defaults/docker/database.yml", 'config/database.yml'
  run 'chmod +x bin/boot'
  log <<-DOCKER_LOG
  Docker files have been copied to your application.
  Please, edit Dockerfile and config/database.yml files and update {APP_NAME}
  to your app's name.
  DOCKER_LOG
end

run 'git add . && git ci -m "Configure RSpec"'
