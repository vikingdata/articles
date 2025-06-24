---
# tasks file for common_initial

- name: Initial setup
  hosts: localhost
  tasks:
  - name: Assert we are included
    ansible.builtin.assert:
      that:
        - target_hosts is defined

  - name: Assert we are included
    ansible.builtin.assert:
      that:
        - target_hosts is defined

- name: import INCLUDE_common_initial_setup.yaml
  import_playbook: INCLUDE_database_initial.yaml
  vars:
    playlist_imported: 1

  