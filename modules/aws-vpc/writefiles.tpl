write_files:
%{ for f in files ~}
  - path: "${f.path}"
    permissions: "${f.mode}"
    content: |
      ${indent(6,"${f.content}")}
%{ endfor ~}
