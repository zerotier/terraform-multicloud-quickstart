users:
  - default
%{ for user in svc ~}
  - name: "${user.username}"
    gecos: "${user.username}"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - "${user.ssh_pubkey}"
%{ endfor ~}
