# Capstone-Doc-Automation


### Get Ansible facts

To get ansible facts in a neat tree run from cmd:

`ansible localhost -m setup --tree facts.d/`


### Docker Test to start 4 container

!!Make sure you have Docker desktop running and opened beforehand!!

To run the docker test playbook do:

`ansible-playbook dockerTest.yml`

This will start 4 containers in Docker 




### Test to connect to Confluence

To run confluence test playbook do:

`ansible-playbook --ask-vault-password confluence.yml `

This will attemot to run 4 tasks

REF: 
 - https://opensource.com/article/21/9/ansible-rest-apis
 - https://phoenixnap.com/kb/ansible-create-file
 - https://stackoverflow.com/questions/67885939/writing-ansible-facts-to-a-file-from-a-playbook 
 - https://docs.atlassian.com/atlassian-confluence/REST/6.6.0/#content-update 

- create and save facts to a CSV
- get token and password from vault

1. Get necessary files (ansible-vaults)

2. Can connect to website(GET)
> this will connect and auth to confluence and lists the pages (with info of creation and etc) already created in our confluence website 

3. Check if Confluence page exists
> this connect and auth to confluence and checks if a page in our "Test' sapce called "testPage" already exist and will output the result info

4. create Confluence page
> can create a new page and push text to page

5. Update Confluence page
> update confluence page and the version number



### Ansible-Lint

To run ansible-lint do:

`ansible-lint`

This will check for any errors in any of our yml playbook files. Just make sure playbook yml file is included within the playbook directory so it can get tested

### gitignore

To untrack every file that is added to gitignore do: (this will updat e the files being pushed to repo)

```
git rm -r --cached .
git add .
git commit -m ".gitignore is now working"
```

### experiment plugins
``` ANSIBLE_STDOUT_CALLBACK=<name of plugin> ansible-playbook --ask-vault-password ../confluence.yml ```

### Run code
``` ANSIBLE_STDOUT_CALLBACK=default ansible-playbook -i ./inventory.yml --ask-vault-password ./confluence.yml```

### w/ defined mapping for custom points:
``` ANSIBLE_STDOUT_CALLBACK=default ansible-playbook -i ./inventory.yml --ask-vault-password ./confluence.yml --tags "create_page" ```
