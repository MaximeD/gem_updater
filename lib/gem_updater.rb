require 'git'
require 'pry'

BRANCH_NAME = 'update_gems'
git = Git.open( Dir.pwd )

git.branch( BRANCH_NAME ).checkout

puts %x( bundle update )

puts git.diff
