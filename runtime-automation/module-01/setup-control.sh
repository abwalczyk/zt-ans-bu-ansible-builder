#!/bin/bash

# Write a new playbook to create a job template from the previous playbook
tee /tmp/template-create.yml << EOF
---
- name: Create job template for create-incident
  hosts: localhost
  connection: local
  gather_facts: false
  collections:
    - ansible.controller

  tasks:
  - name: Post create-incident job template
    ansible.controller.job_template:
      name: "1 - Create incident (incident-create.yml)"
      job_type: "run"
      organization: "Default"
      inventory: "Demo Inventory"
      project: "ServiceNow - admin"
      playbook: "student_project/incident-create.yml"
      execution_environment: "ServiceNow EE"
      use_fact_cache: false
      credentials:
        - "ServiceNow Credential"
      state: "present"
      controller_host: "https://localhost"
      controller_username: admin
      controller_password: ansible123!
      validate_certs: false
EOF

# chown above file
chown rhel:rhel /tmp/template-create.yml

ANSIBLE_COLLECTIONS_PATH="/root/.ansible/collections/ansible_collections/" \
ansible-playbook -i /tmp/inventory /tmp/template-create.yml

# Write a new playbook to grant the student access to the job template
tee /tmp/role-update.yml << EOF
---

- name: Grant 'student' execute access to job template
  hosts: localhost
  connection: local
  gather_facts: false
  collections:
    - ansible.controller

  tasks:
  - name: Create student user
    ansible.controller.user:
      username: student
      password: student123!
      email: student@example.com
      first_name: Student
      last_name: User
      is_superuser: false
      controller_username: admin
      controller_password: ansible123!
      validate_certs: false
    
  - name: Add execute role for student
    ansible.controller.role:
      user: student
      role: execute
      job_templates:
        - "1 - Create incident (incident-create.yml)"
      controller_username: admin
      controller_password: ansible123!
      validate_certs: false
EOF

# chown above file
chown rhel:rhel /tmp/template-create.yml

# Execute the playbook to assign role access
ANSIBLE_COLLECTIONS_PATH="/root/.ansible/collections/ansible_collections/" \
ansible-playbook -i /tmp/inventory /tmp/role-update.yml
