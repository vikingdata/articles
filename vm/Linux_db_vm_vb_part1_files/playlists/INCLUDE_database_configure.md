
---
- name: INCLUDE common initial setup
  hosts: "{{ target_hosts }}"
  tasks:

  - name: Display tags
    ansible.builtin.debug:
      msg: my tags {{ ansible_run_tags }}  

  - name: Assert we are included
    ansible.builtin.assert:
      that:
        - playlist_imported is defined
      msg: "Abort if this is not included as playbook."

  - name: Create /db/config
    ansible.builtin.file:
      path: /db/config
      state: directory
      mode: '0755'

  - name: Make sure name change is done
    ansible.builtin.command:
        # ansible_hostname is from facts
        # inventory-hostname is from inventory
      cmd: hostnamectl set-hostname {{ inventory_hostname}}
      creates: /db/config/hostname_set

    # We use the command with touch
    # Because built in touch command always creates the file. 
  - name: Touch file only when it does not exists
    command: touch /db/config/hostname_set
    args:
      creates: /db/config/hostname_set

  - name: Initial install check
    apt:
        pkg:
          - emacs
          - screen
          - nmap
          - net-tools
          - ssh
          - software-properties-common
          - gnupg
          - tmux
          - bind9-dnsutils
          - btop
          - htop
          - nano
          - nmap
          - tmux
          - nmon
          - atop
          - slurm
          - dstat
          - ranger
          - tldr
          - cpufetch
          - bpytop
          - lolcat
          - mc
          - speedtest-cli
          - python-setuptools
          - python3-pip
          - lynx
          - plocate
          - zip
        state: latest 
        update_cache: true




