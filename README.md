# Google Calender Notification to Telegram
Retrieve Google Calendar appointments and notify Telegram groups

# Requirement (Dockerfile)
* Rocky Linux 8.5
* Python > 3.6.8

## Installation
```
sudo yum update
sudo yum install epel-release
sudo yum install git
sudo yum install jq
sudo yum install langpacks-ja
sudo pip3 install google-api-python-client google-auth gspread oauth2client
sudo localectl set-locale LANG=ja_JP.UTF-8
sudo timedatectl set-timezone Asia/Tokyo
sudo reboot
```

# Preparation
1. Create Google Cloud Platform Account
2. Enable Google Calendar Drive and Sheets API
3. Create Service account
4. Create Service account key (type json)
5. Add Service account in google calender and sheet
6. Create Telegram bot account
7. Create Telegram group


## GCP Compute Engine Setup with Container-Optimized OS

This guide details the steps to set up a Docker container running `pannakoota/telegram_bot2` on a GCP Compute Engine instance using Container-Optimized OS.

### Step 1: Launch the VM Instance
- Choose the `pannakoota/telegram_bot2` for the instance startup.
- Set the reboot policy to "Do not delete".

### Step 2: Check Running Containers
- Once the instance is up, check the running Docker containers:
  ```
  kawamurashingo@instance-1 ~ $ docker ps
  ```

### Step 3: Access the Docker Container
- Access the running container using the following command:
  ```
  docker exec -it [CONTAINER ID] /bin/bash
  ```

### Step 4: Inside the Docker Container
- Verify that cron is running:
  ```
  ps -ef | grep cron
  ```
- Check the current cron jobs:
  ```
  crontab -l
  ```

### Step 5: Edit Configurations
- Navigate to the `telegram_bot2` directory:
  ```
  cd telegram_bot2
  ```
- Edit the necessary configuration files (`credentials.json`, `get_events.py`, `main.sh`) as per your requirements.

### Step 6: Update Crontab
- Update the crontab to enable or disable specific cron jobs:
  ```
  crontab -e
  ```
- Save and exit the editor.

### Step 7: Save Changes to Docker Image
- After exiting the Docker container, save the changes made to a new Docker image:
  ```
  docker commit [CONTAINER ID] telegram_custom
  ```

### Step 8: Stop Original Container
- Stop the original Docker container:
  ```
  docker kill [CONTAINER ID]
  ```

### Step 9: Launch Custom Container
- Launch the customized Docker container:
  ```
  docker run --name telegram_custom -d telegram_custom
  ```

### Step 10: Set Container to Auto-restart
- Ensure the custom container automatically restarts, especially after VM reboots:
  ```
  docker update --restart=always telegram_custom
  ```
- Verify the auto-restart setting:
  ```
  docker inspect -f "{{.Name}} {{.HostConfig.RestartPolicy.Name}}" $(docker ps -aq) | grep always
  ```

### Step 11: Reboot Test
- Perform a reboot test to ensure everything is set up correctly:
  ```
  sudo reboot
  ```


# detail usage
```
# docker
docker run -i -t pannakoota/telegram_bot2 /bin/bash
or
# git clone
git clone https://github.com/kawamurashingo/telegram_bot2.git

# get telegram group
BOT_ID="XXXXXXX"
curl -s -X GET https://api.telegram.org/bot${BOT_ID}/getUpdates | jq -r '.result[] | .message.chat.id, .message.chat.title'

# or blowser access
# add addon json formatter https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa/related
https://api.telegram.org/bot######/getUpdates

# edit BOT_ID in main.sh

# edit {SHEET NAME} in spredsheet_client.py(default "client") and spredsheet_member.py(default "member")
cd ./telegram_bot2
#vi spreadsheet_client.py
#vi spreadsheet_member.py

# edit calendar_id(calendar account(mail address)) in get_events.py
vi get_events.py

# edit credentials.json
vi credentials.json

# edit env of BOT_ID
vi ./main.sh

# run
chmod 755 ./main.sh
sh ./main.sh

# set cron
*/10 8-23 * * * sh /home/xxxx/telegram_bot2/main.sh

```

# Note
docker image
 - <https://hub.docker.com/repository/docker/pannakoota/telegram_bot2>

how to use google api 
 - <https://zuqqhi2.com/how-to-get-my-plans-using-google-calendar-api>

how to create telegram bot account
 - <https://www.youtube.com/watch?v=NwBWW8cNCP4>
 - <https://yuis-programming.com/?p=1241>

how to get group chat id
 - <https://stackoverflow.com/questions/32423837/telegram-bot-how-to-get-a-group-chat-id>

how to edit google sheets
 - <https://www.twilio.com/blog/an-easy-way-to-read-and-write-to-a-google-spreadsheet-in-python-jp>

