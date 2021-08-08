write_files:
  - path: "/var/lib/zerotier-one/identity.public"
    permissions: "0644"
    content: |
      ${indent(6,"${public_key}")}
  - path: "/var/lib/zerotier-one/identity.secret"
    permissions: "0600"
    content: |
      ${indent(6,"${private_key}")}
