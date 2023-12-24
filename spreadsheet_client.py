import gspread
from oauth2client.service_account import ServiceAccountCredentials
import os

# get path
dir_path = os.path.dirname(os.path.abspath(__file__))

# use creds to create a client to interact with the Google Drive API
scope =['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name(dir_path + '/credentials.json', scope)
client = gspread.authorize(creds)

# Find a workbook by name and open the first sheet
# Make sure you use the right name here.
sheet = client.open("client").sheet1

# Extract and print all of the values
list_of_hashes = sheet.get_all_values()
print(list_of_hashes)
