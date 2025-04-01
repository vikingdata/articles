

echo "NOTE, if your ip addresses are different, edit ~/.bashrc"

echo "

  # NOTE, if your ip addresses are different, edit ~/.bashrc
alias ssh_db1='ssh 127.0.0.1 -p 2101 -l root'
alias ssh_db2='ssh 127.0.0.1 -p 2202 -l root'
alias ssh_db3='ssh 127.0.0.1 -p 2303 -l root'
alias ssh_db4='ssh 127.0.0.1 -p 2104 -l root'
alias ssh_db5='ssh 127.0.0.1 -p 2205 -l root'
alias ssh_db6='ssh 127.0.0.1 -p 2306 -l root'

" >> ~/.bashrc
source ~/.bashrc
