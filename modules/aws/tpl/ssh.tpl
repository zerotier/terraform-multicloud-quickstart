ssh_publish_hostkeys:
    enabled: true
no_ssh_fingerprints: false
ssh_keys:
  ${algorithm}_private: |
    ${private_key}
  ${algorithm}_public: |
    ${public_key}
