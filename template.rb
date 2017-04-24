RAILS_51 = !!(Rails.version.match(/5\.1.*/))
RAW_REPO_URL = 'https://raw.githubusercontent.com/willian/rails-app-template/master'

# GEMS

gsub_file 'Gemfile', /^gem\s\'tzinfo\-data.*$/i, ''
gsub_file 'Gemfile', /^\#\sUse\sCoffeeScript.*/, ''
gsub_file 'Gemfile', /^gem\s\'coffee\-.*$/i, ''
gsub_file 'Gemfile', /^group\s:.*end$/m, ''

gem 'webpacker', github: 'rails/webpacker'

gem 'active_model_serializers', '~> 0.10'
gem 'bcrypt', '~> 3.1'
gem 'deterministic', '~> 0.16'
gem 'pg', '~> 0.18'
gem 'poltergeist', '~> 1.13'
gem 'redis', '~> 3.0'
gem 'vanilla-ujs', '~> 1.3' unless RAILS_51
gem 'webpacker-react', '~> 0.2'

gem_group :development, :test do
  gem 'byebug', platform: :mri
  gem 'capybara', '~> 2.7'
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

run 'bundle'

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

remove_file 'bin/yarn' if RAILS_51
run 'bin/rails webpacker:install'
run 'bin/rails webpacker:install:react'

gsub_file 'app/assets/javascripts/application.js', /JavaScript\/Coffee/, 'JavaScript'
gsub_file 'config/webpack/paths.yml', /^\s\s\s\s\-\s\.coffee$/, ''
gsub_file 'package.json', /^\s\s\s\s\"coffee\-.*\,$/, ''
remove_file 'config/webpack/loaders/coffee.js'

run 'yarn'

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
  eslint-config-standard-react
  eslint-plugin-promise
  eslint-plugin-react
  eslint-plugin-standard
  jest
  nightmare
  react-addons-test-utils
  react-dev-utils
  standard
]
run "yarn add #{npm_packages.join(' ')}"
run "yarn add -D #{npm_dev_packages.join(' ')}"

# NPM SCRIPTS

gsub_file 'package.json', /^\s\s\"dependencies\"\:\s\{$/, <<-NPM_SCRIPTS
  "scripts": {
    "lint": "standard frontend/**/*",
    "server": "./bin/webpack-dev-server",
    "test": "node frontend/scripts/test.js --env=jsdom",
    "watch": "./bin/webpack-watcher"
  },
  "dependencies": {
NPM_SCRIPTS

# LINTER & JEST

gsub_file 'package.json', /^\s\s\}\n\}$/, <<-NPM_CONFIG
  },
  "standard": {
    "parser": "babel-eslint",
    "ignore": [
      "app/assets/config/manifest.js",
      "app/assets/javascripts/application.js",
      "app/assets/javascripts/cable.js",
      "config/webpack/**/*"
    ],
    "globals": [],
    "plugins": [
      "react",
      "promise"
    ]
  },
  "jest": {
    "collectCoverageFrom": [
      "<rootDir>/frontend/bundles/**/*.{js,jsx}",
      "<rootDir>/frontend/src/**/*.{js,jsx}"
    ],
    "setupFiles": [
      "<rootDir>/frontend/config/polyfills.js"
    ],
    "testPathIgnorePatterns": [
      "<rootDir>/node_modules/",
      "<rootDir>/config/webpack/",
      "<rootDir>/(vendor)/",
      "<rootDir>/frontend/(build|docs|node_modules|scripts|vendor)/"
    ],
    "testEnvironment": "node",
    "testURL": "http://localhost",
    "transform": {
      "^.+\\\\\\\\.(js|jsx)$": "<rootDir>/node_modules/babel-jest",
      "^.+\\\\\\\\.css$": "<rootDir>/frontend/config/jest/cssTransform.js",
      "^(?!.*\\\\\\\\.(js|jsx|css|json)$)": "<rootDir>/frontend/config/jest/fileTransform.js"
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

# FRONTEND CONFIGURATION

gsub_file 'config/webpack/configuration.js', /\$\{devServer\.host\}/, '${env.APP_HOST || devServer.host}'
gsub_file 'config/webpack/development.server.yml', 'localhost', '0.0.0.0'
gsub_file 'config/webpack/paths.yml', 'entry: packs', 'entry: entries'
gsub_file 'config/webpack/paths.yml', 'source: app/javascript', 'source: frontend'

gsub_file '.babelrc', /^\s\s\s\s\"react\"$/, <<-BABEL
    "es2015",
    "react"
BABEL

run 'rm -rf app/javascript'
run 'mkdir -p frontend/config/jest'
run 'mkdir -p frontend/entries/components'
run 'mkdir -p frontend/scripts'
run 'mkdir -p frontend/specs/e2e'
run 'mkdir -p frontend/specs/helpers'

get "#{RAW_REPO_URL}/defaults/frontend/config/jest/cssTransform.js", 'frontend/config/jest/cssTransform.js'
get "#{RAW_REPO_URL}/defaults/frontend/config/jest/fileTransform.js", 'frontend/config/jest/fileTransform.js'
get "#{RAW_REPO_URL}/defaults/frontend/config/polyfills.js", 'frontend/config/polyfills.js'
get "#{RAW_REPO_URL}/defaults/frontend/entries/application.js", 'frontend/entries/application.js'
get "#{RAW_REPO_URL}/defaults/frontend/scripts/test.js", 'frontend/scripts/test.js'
get "#{RAW_REPO_URL}/defaults/frontend/specs/app.spec.jsx", 'frontend/specs/app.spec.jsx'
get "#{RAW_REPO_URL}/defaults/frontend/specs/e2e/app.spec.js", 'frontend/specs/e2e/app.spec.js'
get "#{RAW_REPO_URL}/defaults/frontend/specs/helpers/visit.js", 'frontend/specs/helpers/visit.js'

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
