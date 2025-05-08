
export def names [] {
  [
    'nanopay-frontend-user'
    'nanopay-frontend-admin'
    'nanopay-frontend-payment'
    'nanopay-frontend-p2p-desktop'
  ]
}

def --wrapped git_command [name: string, command: string, ...args] {
  print $"\n--- ($name) ---"
  let path = ($env.NANOPAY_FRONTEND | path join $name)
  git -C $path $command ...$args
}

def git_clone [name: string] {
  let path = ($env.NANOPAY_FRONTEND | path join $name)
  if not ($path | path exists) {
    git clone $"git@($env.GITLAB_HOST):nanopay/frontend/($name).git" $path
  }
}

def git_submodule [name: string] {
  git_command $name submodule update --init --recursive
}

def git_status [name: string] {
  git_command $name status
}

def git_switch [name: string, branch: string] {
  try { git_command $name switch $branch }
}

def git_fetch [name: string] {
  git_command $name fetch
}

def git_remote_remove [name: string] {
  git_command $name remote remove origin
}

def git_remote_add [name: string] {
  git_command $name remote add origin $"git@($env.GITLAB_HOST):nanopay/frontend/($name).git"
}

def git_branch_upstream [name: string] {
  git_command $name branch --set-upstream-to origin/main main
}

def git_push_upstream [name: string] {
  git_command $name push --set-upstream origin main
}

def git_pull [name: string] {
  try { git_command $name pull }
}

def git_reset [name: string, branch: string] {
  try {
    gum confirm $"Are you sure run ($name): git reset --hard origin/($branch)?"
    git_command $name reset --hard origin/($branch)
  }
}

def zoxide_add [name: string] {
  print $"\n--- ($name) ---"
  ^zoxide add ($env.NANOPAY_FRONTEND | path join $name)
}

def run_for_each_name [command: closure] {
  for $name in (names) {
    do $command $name
  }
}

export def clone [] {
  run_for_each_name { |name| git_clone $name }
}

export def submodule [] {
  run_for_each_name { |name| git_submodule $name }
}

export def status [] {
  run_for_each_name { |name| git_status $name }
}

export def switch [branch: string] {
  run_for_each_name { |name| git_switch $name $branch }
}

export def fetch [] {
  run_for_each_name { |name| git_fetch $name }
}

export def pull [] {
  run_for_each_name { |name| git_pull $name }
}

export def reset [branch: string] {
  run_for_each_name { |name| git_reset $name $branch }
}

export def remote_refresh [] {
  run_for_each_name { |name|
    git_remote_remove $name
    git_remote_add $name
    git_push_upstream $name
  }
}

export def zoxide [] {
  run_for_each_name { |name| zoxide_add $name }
}
