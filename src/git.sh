alias g=git
alias gaa="g add . && g add -u & g status"
alias gco="g commit"
alias gdiff="g diff"
alias gpull="g pull"
alias gpush="g push"

#[user]
#    name = holly
#    email = emperor.kurt@gmail.com
#[alias]
#    co = checkout
#    cm = commit
#    st = status -sb # simple status
#    pr = pull --rebase # no merge commit when pulling
#    pl = pull
#    ph = push -u
#    fo = fetch origin
#    ro = rebase origin # you can rebase to master by fo -> ro in branch
#    rc = rebase --continue
#    wd = diff --word-diff
#    gp = grep -n # grep with line numslg = log --graph --pretty=oneline --decorate --date=short --abbrev-commit --branches # tree log ( via http://webtech-walker.com/archive/2010/03/04034601.html)
#    graph = log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'
#    refresh = !git fetch origin && git remote prune origin
#    aa = !git add .  && git add -u && git status
#    aliases = "!git config --get-regexp alias | perl -nlpe 's/^alias\\.//g; s/ / = /' | sort"
#    ls = ls-files
#    df = diff
#[color]
#    ui = auto
#[http]
#    sslVerify = false
#[push]
#    default = simple
#[credential]
#    helper = cache
