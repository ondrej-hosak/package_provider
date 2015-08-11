rm -rf /tmp/testrepo
rm -rf /tmp/submodule_repo
 # ---------------------- SET CONFIG --------------------#

 git config --global user.name 'Jara Cimrman'
 git config --global user.email 'jara@cimrman.cz'

 # ---------------------- CREATE ORIGIN --------------------#

mkdir /tmp/testrepo
cd /tmp/testrepo

 git init
 cat >README.md <<EOF
 # TESTING Repo

 Two branches:
 master with README.md
 branch_docs with doc folder containing two files
EOF

git add README.md
git commit -m 'initial commit'

#------------------------ CREATE BRANCH ---------------#
git checkout -b 'docs_branch'
mkdir docs
echo 'Doc1' >> docs/doc1.txt
echo 'Doc2' >> docs/doc2.txt
git add --all
git commit -m 'add docs'

#------------------------ CREATE SUBMODULE ---------------#

cd /tmp
mkdir submodule_repo
cd submodule_repo
git init
cat >README.md <<EOF
# TESTING Repo

Submodule
EOF
git add README.md
git commit -m 'initial submodule commit'

#------------------------ ADD SUBMODULE TO SEPARATE BRANCH ---------------#

cd /tmp/testrepo
git checkout -b 'add_submodule'
git submodule add /tmp/submodule_repo submodule
git commit -m 'add submodule commit'

#------------------------ MERGE BRANCHES TO MASTER  ---------------#

git checkout master
git merge docs_branch
git merge add_submodule

#------------------------ NEXT COMMIT TO MASTER  ---------------#

mkdir sources
echo 'source1' >> sources/source1.txt
echo 'source2' >> sources/source2.txt
git add --all
git commit -m 'add sources'

#------------------------ NEXT COMMIT TO SUBMODULE  ---------------#
cd /tmp/submodule_repo
mkdir submodule_sources
echo 'submodule_source1' >> submodule_sources/source1.txt
echo 'submodule_source2' >> submodule_sources/source2.txt
git add --all
git commit -m 'add submodule sources'

#------------------------ COMMIT TO MASTER NEW SUBMODULE  ---------------#

cd /tmp/testrepo/submodule
git pull
cd /tmp/testrepo
git add --all
git commit -m 'new version of submodule'

git clone --bare /tmp/testrepo/ /vagrant/spec/factories/testing-repo/
git clone --bare /tmp/submodule_repo/ /vagrant/spec/factories/testing-submodule-repo/

cd /vagrant/spec/factories/testing-repo
git log --pretty=oneline
