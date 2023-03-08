import requests
from bs4 import BeautifulSoup
import csv
import time

# define function to handle reconnecting
def reconnect(url):
    while True:
        try:
            response = requests.get(url)
            return response
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout):
            print("Connection error or timeout, retrying...")
            time.sleep(5)
            continue

# specify the URL to scrape
url = 'https://www.yellowpages.com/norman-ok/restaurants'

# send an HTTP request to the URL
response = reconnect(url)

# create a BeautifulSoup object to parse the HTML content
soup = BeautifulSoup(response.content, 'html.parser')

# create a CSV file to store the data
csv_file = open('restaurants1.csv', 'w', newline='', encoding='utf-8')
writer = csv.writer(csv_file)

# write the header row to the CSV file
writer.writerow(['Name', 'Address', 'Phone'])

# loop through all pages of search results
while True:
    # find all listings on the current page
    listings = soup.find_all('div', {'class': 'result'})

    # loop through all listings on the current page
    for listing in listings:
        # extract the name, address, and phone number
        name = listing.find('a', {'class': 'business-name'})
        if name:
            name = name.text.strip()
        else:
            name = ''
        address = listing.find('div', {'class': 'street-address'})
        if address:
            address = address.text.strip()
        else:
            address = ''
        phone = listing.find('div', {'class': 'phones'})
        if phone:
            phone = phone.text.strip()
        else:
            phone = ''

        # write the data to the CSV file
        writer.writerow([name, address, phone])

    # find the link to the next page of search results
    next_page = soup.find('a', {'class': 'next'})

    if next_page:
        # construct the URL for the next page
        next_page_url = 'https://www.yellowpages.com' + next_page['href']
        print(next_page_url)
        # scrape the next page
        response = reconnect(next_page_url)
        soup = BeautifulSoup(response.content, 'html.parser')
    else:
        # we have reached the last page of search results
        break

# close the CSV file
csv_file.close()
print('Scraping complete!')
