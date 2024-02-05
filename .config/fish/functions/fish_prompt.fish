function __user_host
  set -l content 
  if [ (id -u) = "0" ];
    echo -n (set_color --bold red)
  else
    echo -n (set_color --bold green)
  end
  echo -n $USER@(hostname|cut -d . -f 1) (set color normal)
end

function __current_path
  set pwd_result (pwd)
  if test (string length $pwd_result) -gt (math $COLUMNS - 10)
	  echo -n (set_color --bold blue) (prompt_pwd) (set_color normal) 
  else
	  echo -n (set_color --bold blue) $pwd_result (set_color normal) 
  end
end

function __git
  test $SSH_TTY
    and printf (set_color red)$USER(set_color brwhite)'@'(set_color yellow)(prompt_hostname)' '
    test $USER = 'root'
    and echo (set_color red)"#"

    # Main
    echo -n (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '

    # Git
    set last_status $status
    printf '%s ' (__fish_git_prompt)
    set_color normal
end

function fish_prompt
  if [ $status -eq 0 ]
    set status_face (set_color green)"(*'-') < "
  else
    set status_face (set_color blue)"(*;-;) < "
  end

  echo -n (set_color white)"╭─"(set_color normal)
  __user_host
  __current_path
  __git
  echo -e ''
  echo (set_color white)"╰─"$status_face(set_color normal)
end

function fish_right_prompt
    # echo -n (set_color --bold black)
	date "+%H:%M:%S"
	# echo -n (set color normal)
end

alias ls="lsd"
alias la="lsd -a"
alias ll="lsd -al"
alias vim="nvim"
