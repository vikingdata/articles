
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

  - name: Create multiple directories
    file:
      path: "{{ item }}"
      state: directory
      recurse: yes
      mode: '0755'
    loop:
      - /db/source
      - /db/config/postgresql
      - /db/config/mysql
      - /db/config/mongo/shard
      - /db/config/yugbyte/cluster

      - /db/data/postgresql/cluster
      - /db/data/postgresql/replication
      - /db/data/mysql/replication
      - /db/data/mysql/clusterset
      - /db/data/mongo/shard
      - /db/data/yugbyte/cluster


  - name: Download postgresql and put into apt
    include_role:
      name: install_postgresql

#  - name: basic Configure postgresql
#    include_role:
#      name: configure_basic_postgresql
      
      






# Created symlink /etc/systemd/system/multi-user.target.wants/postgresql.service → /lib/systemd/system/postgresql.service.

 # /etc/postgresql-common/createcluster.conf
 # /usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main --auth-local peer --auth-host scram-sha-256 --no-instructions

apt-get remove --purge  postgresql-17
apt autoremove
rm /etc/systemd/system/postgresql.service
systemctl disable postgresql

stop postgresql
backup config file
make config file in /db and link to /etc
create another db in /db
init both
start deflau postrgreql
strt 2nd postgresql with different port and socket file