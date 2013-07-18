import requests 
from pprint import pprint
import pickle
import time
from getpass import getpass

AUTH = ()


def get_messages():
	url = 'https://api.github.com/events'
	resp = requests.get(url, auth=AUTH)
	if resp.status_code != 200:
		print 'Received bad status code for %s : %r ' % (url, resp.status_code)
		return []
	payloads = [event['payload'] for event in resp.json()]
	commits = [payload['commits'] for payload in payloads if 'commits' in payload.keys()]
	messages = [commit[0]['message'] for commit in commits]
	return messages

if __name__ == '__main__':
	user = raw_input('Enter github username: ')
	AUTH = (user, getpass('Enter github password: '))
	num_requests = raw_input('How many commit messages should be obtained? ')
	num_requests = int(num_requests) / 10  # Fuzzy, fuzzy math.
	all_messages = []
	for i in range(num_requests):
		all_messages += get_messages()

	# Filter out any that failed (e.g. http status code was not 200)
	all_messages = filter(lambda x: x != [], all_messages)

	# Dump that shih tzu.
	with open('commit_messages.pickle', 'w+') as fh:
		pickle.dump(all_messages, fh)
	with open('commit_messages.txt', 'w+') as fh:
		fh.write('\n$$$\n'.join(all_messages))

	pprint(all_messages, indent=4)
