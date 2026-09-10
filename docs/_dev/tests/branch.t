Branch/version consistency
===========================

This is a cram test that tests the $DOC_VERSION defined in docs/versions.env
against the git branch that this documentation lives in. The branch naming
convention is "$DOC_VERSION-branch"; a mismatch here means either versions.env
was bumped without renaming/re-branching, or the wrong branch was checked out
for this content:

  $ branch=$(git -C "$TESTDIR/../../.." rev-parse --abbrev-ref HEAD)
  $ expected="$DOC_VERSION-branch"
  $ if [ "$branch" = "$expected" ]; then
  >   :
  > else
  >   echo "This documentation is in git branch '$branch'."
  >   echo "This does not match the expected '$expected' branch name"
  >   echo "Either docs/versions.env was bumped without re-branching, or the wrong branch is checked out"
  > fi
