#!/bin/bash

# Generate "spec" used by dirstr.py (dev-util/dirstr), which is a dependency of
# split git ebuilds in Sabayon.

# You don't have to use this script while bumping ebuilds! It's just a helper;
# use your preferred method to update "spec" files.

#   Copyright 2019 Sławomir Nizio
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Usage: ./mkspec-git.sh DIR > FILE
# where DIR is supposed to be something like ${D} after 'ebuild ... install'
# executed on dev-vcs/git from Gentoo.

# Why don't "spec" files used by dirstr.py contain patterns (like in this file)
# but instead include every file and directory? There are three reasons: it was
# easier to implement this way; it provides more visibility so it's more
# difficult to "misplace" a file (e.g. most files under git-core belong to git,
# but not all) by comparing "old" with "new"; it provides more QA by detecting
# missing or additional files.


pkg_inst_dir=${1:?}

error() {
	echo "error: $*" >&2
	exit 1
}

map() {
awk '
function s(line, what)
{
	w = "." what
	return ((index(line, w "/") == 1) || (line == w))
}

{
	if (s($0, "/usr/share/gitk"))
		class = "git-gui-tools"
	else if (s($0, "/usr/share/gitweb"))
		class = "gitweb"
	else if (s($0, "/usr/share/locale"))
		class = "git"
	else if (s($0, "/usr/share/man"))
		class = "git"
	else if (s($0, "/usr/share/git"))
		class = "git"
	else if (s($0, "/usr/share/git-core"))
		class = "git"
	else if (s($0, "/usr/libexec/git-core"))
		class = "git"
	else if (s($0, "/usr/share/doc"))
		class = "git"
	else if (s($0, "/usr/share/bash-completion"))
		class = "git"
	else if (s($0, "/usr/share/git-gui"))
		class = "git-gui-tools"
	else if (s($0, "/lib"))
		class = "git"
	else if (s($0, "/usr/lib64"))
		class = "git"
	else if (s($0, "/usr/bin"))
		class = "git"
	else if (s($0, "/etc"))
		class = "git"
	else
		class = "???"

	if (match($0, /\/usr\/share\/man\/.*\/(gitcvs-|git-cvs)/))
		class = "git-cvs"
	if (match($0, /\/usr\/share\/man\/.*\/(git-gui|gitk|git-citool)/))
		class = "git-gui-tools"
	if (match($0, /\/usr\/share\/man\/.*\/(git-svn)/))
		class = "git-subversion"
	if (match($0, /\/usr\/share\/man\/.*\/gitweb/))
		class = "gitweb"
	if (match($0, /\/usr\/libexec\/git-core\/git-svn/))
		class = "git-subversion"
	if (match($0, /\/usr\/libexec\/git-core\/(git-gui|git-citool)/))
		class = "git-gui-tools"
	if (match($0, /\/usr\/libexec\/git-core\/git-cvs/))
		class = "git-cvs"
	if (match($0, /\/usr\/share\/git\/gitweb/))
		class = "gitweb"
	if (match($0, /\/usr\/share\/doc\/.*gitweb/))
		class = "gitweb"
	if (match($0, /\/usr\/share\/doc\/.*\/svn-fe\./))
		class = "git-subversion"
	if (match($0, /\/usr\/(share|libexec)$/))
		class = "git"
	if (match($0, /\/usr\/bin\/gitk/))
		class = "git-gui-tools"
	if (match($0, /\/usr\/bin\/git-cvsserver/))
		class = "git-cvs"
	if (match($0, /\/usr\/bin\/svn-fe/))
		class = "git-subversion"
	if (match($0, /\/usr$/))
		class = "git"
	if ($0 == ".")
		class = "git"

	print class " " $0
}
'
}

filter() {
	grep -v -E '^\./usr/lib(/debug|$)'
}

rewrite() {
	# .bz2 is src_install vs. installation to $D :/
	sed -r \
		-e 's:(/usr/share/doc/)git-[0-9][^/]+:\1@git-doc@-@git-ver@:' \
		-e 's:(/usr/lib64/perl5/vendor_perl/)[^/]+:\1@perl-ver-path@:' \
		-e 's:(.*/usr/share/(man|doc)/.*)\.bz2$:\1:'
}

cd "$pkg_inst_dir" || error cd
result=$(find . -depth | filter | map | rewrite)

if echo "$result" | grep -F '???'; then
	error "??? (see above)"
fi

echo "$result"
