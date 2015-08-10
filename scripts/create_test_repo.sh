rm -rf /tmp/testrepo

 # ---------------------- CREATE ORIGIN --------------------#
mkdir /tmp/testrepo
cd /tmp/testrepo

 git init
 git config --global user.name 'Jara Cimrman'
 git config --global user.email 'jara@cimrman.cz'
 cat >README.md <<EOF
 # TESTING Reop

 Two branches ...
EOF

git add README.md
git commit -m 'initial commit'
git checkout -b 'docs_branch'
 mkdir doc
 echo 'Doc1' >> doc/doc1.txt
 echo 'Doc2' >> doc/doc2.txt
 git add doc/*
 git commit -m 'add docs'

 # ---------------------- CREATE COPY --------------------#
 #mkdir /tmp/testrepo2
git clone --bare /tmp/testrepo spec/factories/testing-repo

#for hash in $(git log --pretty=oneline | awk '{print $1}'); do
#  echo $hash
#done

#echo 'first commit: '${HASHES[0]}
#echo 'second commit: '${HASHES[1]}
