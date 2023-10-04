## changees ownership of all files to root
alias schown="sudo chown -R $USER:$USER ."

## git 
alias gph="git add . && git commit -m 'hotfix' && git push"
alias gs="git status"
alias gp="git push"
alias ga="git add ."
alias gm="git commit -m"
alias gcam="git commit -am"

## docker
alias dc="docker-compose"
alias dcd="dc down"
alias dce="dc exec"
alias dcr="dc run"
alias dcu="dcd && dc up --build"
alias dcu="docker-compose down && docker-compose build && dc up"
alias dcub="docker-compose down && docker-compose build && dc up"
alias dcud="dcu -d"
alias dcul="dcu -d && dced bundle exec guard -P livereload"

## exec app
alias dced="dce app"
alias dcel="dce app guard -P livereload"
alias dceds="dcde sh"
alias dcedr="dcde bin/rails"

# run app
alias dcrd="docker-compose run --rm app"
alias dcrdr="dcrd bin/rails"
alias dcrdm="dcrdr db:migrate"
alias dcrds="dcrdm && dcrdr bin/rails db:setup"

# run test
alias dcrt="dcr test sh -c 'bundle exec guard -g test'"
alias dcrtc="dcr test bin/rails db:create"

# kubectl exec 
alias ksh="mise/scripts/ssh_to.sh"
alias kpe="mise/scripts/kubectl_pod_exec.sh"
alias krr="kubectl rollout restart deploy app sidekiq"
alias kpw="kubectl get pods --watch"
alias kdp="kubectl delete pods"

alias killyarn="lsof -t -i:8082 | xargs -r kill"
alias killrails="lsof -t -i:3000 | xargs -r kill"
alias rmpids="rm ./tmp/pids/server.pid"
alias killdev="killyarn && killrails && rmpids"

