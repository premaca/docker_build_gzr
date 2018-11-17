
### Build Environments
alias gendef='sudo make mrproper; make ARCH=arm CROSS_COMPILE=arm-eabi- '
alias gen64='sudo make mrproper; make ARCH=arm64 CROSS_COMPILE=aarch64-linux-androidkernel- '
alias repsync='repo sync -c -j18 --force-sync --no-clone-bundle --no-tags'
export EDITOR="vim"

alias allstatus='repo forall -pc '"git status"''

alias arr='adb reboot recovery'
alias gcp='git cherry-pick'
alias gca='git cherry-pick --abort'

### git push ssh://premaca@review.gzospgzr.com:29418/GZOSP/vendor_gzosp HEAD:refs/for/9.0
### gitdir=$(git rev-parse --git-dir); scp -p -P 29418 premaca@review.gzospgzr.com:hooks/commit-msg ${gitdir}/hooks/
