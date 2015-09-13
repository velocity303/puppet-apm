Package{
  provider => apm,
  ensure   => latest,
}

package {['linter','travis-ci-status','merge-conflicts','language-puppet','linter-puppet-lint']:}
