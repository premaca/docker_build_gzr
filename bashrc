
### Build Environments
alias gendef='sudo make mrproper; make ARCH=arm CROSS_COMPILE=arm-eabi- '
alias gen64='sudo make mrproper; make ARCH=arm64 CROSS_COMPILE=aarch64-linux-androidkernel- '
alias repsync='repo sync -c -j18 --force-sync --no-clone-bundle --no-tags'
export EDITOR="vim"

alias allstatus='repo forall -pc '"git status"''

alias arr='adb reboot recovery'

#Placeholder for custom alias
alias sync="repo sync"		# default action	- Sync repo
alias envsetup=". build/envsetup.sh"		# default action	- Start build environmrent
alias log="adb logcat"		# default action	- Logcat
alias gcl='git clone'
alias ga='git add'
alias gaa='git add --all'
alias grm='git rm'
alias gap='git add -p'
alias gall='git add -A'
alias gf='git fetch --all --prune'
alias gft='git fetch --all --prune --tags'
alias gfv='git fetch --all --prune --verbose'
alias gftv='git fetch --all --prune --tags --verbose'
alias gus='git reset HEAD'
alias gpristine='git reset --hard && git clean -dfx'
alias gclean='git clean -fd'
alias gm="git merge"
alias gmv='git mv'
alias g='git'
alias get='git'
alias gst='git status'
alias gs='git status'
alias gss='git status -s'
alias gsu='git submodule update --init --recursive'
alias gl='git pull'
alias glum='git pull upstream master'
alias gpr='git pull --rebase'
alias gpp='git pull && git push'
alias gup='git fetch && git rebase'
alias gp='git push'
alias gpo='git push origin'
alias gpu='git push --set-upstream'
alias gpom='git push origin master'
alias gr='git remote'
alias grv='git remote -v'
alias gra='git remote add'
alias gd='git diff'
alias gdv='git diff -w "$@" | vim -R -'
alias gc='git commit'
alias gca='git commit -v -a'
alias gcm='git commit -v -m'
alias gci='git commit --interactive'
alias gb='git branch'
alias gba='git branch -a'
alias gbt='git branch --track'
alias gbm='git branch -m'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gco='git checkout'
alias gcom='git checkout master'
alias gcb='git checkout -b'
alias gcob='git checkout -b'
alias gct='git checkout --track'
alias gexport='git archive --format zip --output'
alias gdel='git branch -D'
alias gmu='git fetch origin -v; git fetch upstream -v; git merge upstream/master'
alias gll='git log --graph --pretty=oneline --abbrev-commit'
alias gg="git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
alias ggs="gg --stat"
alias gsl="git shortlog -sn"
alias gwc="git whatchanged"
alias gt="git tag"
alias gta="git tag -a"
alias gtd="git tag -d"
alias gtl="git tag -l"
# From http://blogs.atlassian.com/2014/10/advanced-git-aliases/
# Show commits since last pull
alias gnew="git log HEAD@{1}..HEAD@{0}"
# Add uncommitted and unstaged changes to the last commit
alias gcaa="git commit -a --amend -C HEAD"
alias ggui="git gui"
alias gcam="git commit -am"
alias gcsam="git commit -S -am"
alias gstd="git stash drop"
alias gstl="git stash list"
alias setup=". build/envsetup.sh"

# Android
export LANG=C

### git push ssh://premaca@review.gzospgzr.com:29418/GZOSP/vendor_gzosp HEAD:refs/for/9.0
### gitdir=$(git rev-parse --git-dir); scp -p -P 29418 premaca@review.gzospgzr.com:hooks/commit-msg ${gitdir}/hooks/
