# For security to work, we rely on a KDC to be available in this stack.
# Your blueprint should include the KDC role on one machine, and it's
# generally recommended that KDC be installed on a machine by itself
{% set kdc_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:krb5.kdc', 'grains.items', 'compound').keys()[0] %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
# load admin keytab from the master fileserver
load_admin_keytab:
  module:
    - run
    - name: cp.get_file
    - path: salt://{{ kdc_host }}/root/admin.keytab
    - dest: /root/admin.keytab
    - user: root
    - group: root
    - mode: 600
    - require:
      - file: krb5_conf_file

generate_http_keytab:
  cmd:
    - script
    - source: salt://cdh5/security/generate_http_keytab.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /root
    - unless: test -f /root/HTTP.keytab
    - require:
      - module: load_admin_keytab
      - pkg: krb5-workstation
{% endif %}
