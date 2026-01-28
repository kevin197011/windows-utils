# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'bundler/setup'
require 'date'
require 'kk/git/rake_tasks'

task default: %w[push]

task :push do
  Rake::Task['git:auto_commit_push'].invoke
  # if the tag for today already exists, delete it first
  system "git tag -d v#{Date.today.strftime('%Y%m%d')}"
  system "git push origin :refs/tags/v#{Date.today.strftime('%Y%m%d')}"
  system "git tag v#{Date.today.strftime('%Y%m%d')}"
  system "git push origin v#{Date.today.strftime('%Y%m%d')}"
end
