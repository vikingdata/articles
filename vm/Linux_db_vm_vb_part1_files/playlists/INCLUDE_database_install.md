     
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

  - name: Download all databases files from MySQL, Percona, MongoDB, YugabyteB
    include_role:
C      name: download_database_files


				  

#  - name: Download postgresql and put into apt
#    include_role:
#      name: install_postgresql

#  - name: basic Configure postgresql
#    include_role:
#      name: configure_basic_postgresql
      

A