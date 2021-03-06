#!/bin/bash
# v0.2.33  13/nov/2019

# You can create a blockchair.com API key for more requests/min
#CHAIRKEY="?key=MYSECRETKEY"

# Help -- run with -h
HELP="WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.


SYNOPSIS

	searchbtc.sh [-abcdghv] [-sNUM] [-o\"FILE_PATH\"]


	This script uses Vanitygen to generate an address and its private key.
	It then checks for at least one received transaction at the public ad-
	dress. If a transaction is detected, even if the balance is currently 
	zero (current balance is not checked), a copy of the generated private 
	key and its public address will be printed in the screen and logged 
	to ~/ADDRESS. You can change record file path with option \"-o\".

	The fastest way of brute forcing a bitcoin address collision is to have 
	your own full-node set up. However, that may not be feasible size-wise.
	Also, it may be easier to use internet APIs than to learn how to build 
	a full-node.

	Defaults to Blockchain.info API, but you can choose which servers to 
	query. Beware of rate limits for each server!

	Required packages are: Bash, cURL or Wget, Tee and Vanitygen (OpenSSL 
	and Pcre are required dependencies of Vanitygen).


COLLISION PROBABILITIES

	How to find a collision (ref 1)

		try 2^130 randomly chosen inputs
		99.8% chance that two of them will collide
	

	Number Of Unique Addresses Used (ref 2)
	
		456,579 (2019/10/17)


	If you find a wallet with balance, send the owner the smallest signal 
	that wallet security was breached. Also, unless it is one of Satoshi 
	addresses, you ought not to keep the bitcoins.


	A nice page about cryptographic hash functions is (3).
	Check those jokes!


References:
	(1) <https://www.youtube.com/watch?v=fOMVZXLjKYo>
	(2) <https://www.blockchain.com/en/charts/n-unique-addresses>
	(3) <http://valerieaurora.org/hash.html>

RATE LIMITS
	Blockchain.info, from Twitter 2013:
	
	\"Developers: API request limits increased to 28,000 requests per 8 hour
	period and 600 requests per 5 minute period.\"


	Blockchair.com API docs and message from server:
	
	\"Since the introduction of our API more than two years ago it has been
	free to use in both non-commercial and commercial cases with a limit of 
	30 requests per minute.\"

	\"Code 402: Current limits are 30 requests per minute and 1800 per hour.\"

	\"Limit of 1440 queries per day.\"


	BTC.com API docs:
	
	\"Developer accounts are limited to 432,000 API requests per 24 hours, 
	at a rate of 300 request per minute. When you reach the rate limit you 
	will get an error response with the 429 status code. We will send you a
	notification when you're getting close to the rate limit, so you can up-
	grade in time or contact us to request an extension. If you don't back-
	off when 429 responses are being returned you can get banned.\"


	Blockcypher.com API docs:
	
	\"Classic requests, up to 3 requests/sec and 200 requests/hr.\"


	Error 429 may not be a problem. Perhaps error 430 is.


USAGE EXAMPLES
	(1) Use defaults, sleep time between queries is nought and check
	    response from server.

		$ searchbtc.sh -s0 -g


	(2) Use BTC.com and Blockchain.info APIs and sleep 20 seconds
	    between queries:
		
		$ searchbtc.sh -ab -s20


	(3) Use all servers, default sleep time:

		$ searchbtc.sh -abcd


OPTIONS
	-a 		Use BTC.com API.
	
	-b 		Use Blockchain.info APIs (defaults if no 
			server opt is given).

	-c 		Use Blockchair.com API.
	
	-d 		Use Blocypher.com API.

	-g 		Debug, prints server response on error.

	-h 		Show this help.

	-o [FILE_PATH] 	File path to record positive match results;
			defaults=\"~/ADDRESS\"

	-s [NUM] 	Sleep time (seconds) between new queries; 
			reccomended>=2; defaults=10.

	-v 		Print script version."

# DEFAULTS
# Pay attention to rate limits
SLEEPTIME="10"
RECFILE="${HOME}/ADDRESS"
TIMEOUT="6"

# Must have vanitygen
if ! command -v vanitygen >/dev/null; then
	printf "Vanitygen is required.\n" 1>&2
	exit 1
fi
# Must have cURL or Wget
if command -v curl >/dev/null; then
	MYAPP="curl -s --retry 1 -m${TIMEOUT}"
elif command -v wget >dev/null; then
	MYAPP="wget  -t1 -T${TIMEOUT} -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi
if ! command -v jq >/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi

# Parse options
while getopts ":cbadghs:vo:" opt; do
	case ${opt} in
		a ) # Use BTC.com
			BTCOPT=1
			SERVERSET=1
			;;
		b ) # Use Blockchain.info
			BINFOOPT=1
			SERVERSET=1
			;;
		c ) # Use Blockchair.com
			CHAIROPT=1
			SERVERSET=1
			;;
		d ) # Use Blockcypher.com
			CYPHEROPT=1
			SERVERSET=1
			;;
		h ) # Help
			head "${0}" | grep -e '# v'
			echo -e "${HELP}"
			exit 0
			;;
		o ) # Record file path
			RECFILE="${OPTARG}"
			;;
		v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		s ) # Sleep time
			SLEEPTIME="${OPTARG}"
			;;
		g ) # Debug
			DEBUG=1
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	 esac
done
shift $((OPTIND -1))
# Use only Blockchain.com by defaults
if [[ -z "${SERVERSET}" ]]; then
	BINFOOPT=1
fi

#Which function
whichf() {
	test "${PASS}" = "1" && printf "Blockchain.info\n" 
	test "${PASS}" = "2" && printf "Blockchair.com\n"
	test "${PASS}" = "3" && printf "BTC.com\n"
	test "${PASS}" = "4" && printf "Blockcypher.com\n"
	#test "${PASS}" = "" && printf " "
}

#Functions
PASS=0
queryf() {
	# Choose resquest server
	if [[ -n "${BINFOOPT}" ]] && [[ "${PASS}" -eq "0" ]] ; then
		# Binfo.com
		QUERY="$(${MYAPP} "https://blockchain.info/balance?active=$address")"
		PASS=1
	elif [[ -n "${CHAIROPT}" ]] && [[ "${PASS}" -le "1" ]]; then
		# Blockchair.com
		QUERY="$(${MYAPP} "https://api.blockchair.com/bitcoin/dashboards/address/${address}${CHAIRKEY}")"
		PASS=2
	elif [[ -n "${BTCOPT}" ]] && [[ "${PASS}" -le "2" ]]; then
		# BTC.com
		# OBS : BTC.com returns null if no tx in address
		QUERY="$(${MYAPP} "https://chain.api.btc.com/v3/address/${address}")"
		PASS=3
	elif [[ -n "${CYPHEROPT}" ]] && [[ "${PASS}" -le "3" ]]; then
		#Blockcypher.com
		QUERY="$(${MYAPP} "https://api.blockcypher.com/v1/btc/main/addrs/${address}/balance")"
		PASS=4
	else
		PASS=0
		queryf
	fi
}

#Get RECEIVED TOTAL (not really balance)
SA=0
getbal() {
	# Test for rate limit error
	if grep -iq -e "Please try again shortly" -e "Quota exceeded" -e "Servlet Limit" -e "rate limit" -e "exceeded" -e "limited" -e "not found" -e "429 Too Many Requests" -e "Error 402" -e "Error 429" -e "too many requests" -e "banned" -e "Maximum concurrent requests" -e "Please try again shor" -e "\"error\":" -e "upgrade your plan" -e "extend your limits" <<< "${QUERY}"; then
		SA="$((SA+1))"
		printf "\nRate limit warning/error: %s.\n" "$(whichf)" 1>&2
		printf "Skipped: %s\n" "${SA}" 1>&2
		#Debug Verbose
		if [[ -n "${DEBUG}" ]]; then
			printf "Addr: %s\n" "${address}" 1>&2
			printf "Processing: PASS %s.\n" "${PASS}" 1>&2
			date 1>&2
			printf "%s\n" "${QUERY}" 1>&2
			printf "\n.............." 1>&2
		fi
		#continue...
	elif grep -iq -e "Invalid API token" -e "invalid api" -e "wrong api" -e "wrong key" -e "api key" <<< "${QUERY}"; then
		printf "\nInvalid API token.\n" 1>&2
		exit 1
	fi
	# Choose processing between 
	if [[ "${PASS}" -eq "1" ]]; then
		# Binfo.com
		jq -er '.["'"${address}"'"].total_received' <<< "${QUERY}" 2>/dev/null || return 1
		return 0
	elif [[ "${PASS}" -eq "2" ]]; then
		# Blockchair.com
		jq -er '.data[].address.received' <<< "${QUERY}" 2>/dev/null || return 1
		return 0
	elif [[ "${PASS}" -eq "3" ]]; then
		# BTC.com
		# OBS : BTC.com returns null if no tx in address
		# Option -e deactivated
		jq -r '.data.received' <<< "${QUERY}" 2>/dev/null || return 1
		return 0
	elif [[ "${PASS}" -eq "4" ]]; then
		#Blockcypher.com
		jq -er '.total_received' <<< "${QUERY}" 2>/dev/null || return 1
		return 0
	fi
	}

# Heading
date 
# Loop
# Start count
N=1
while :; do
	printf "\rAddrs: %07d" "${N}" 1>&2
	VANITY="$(vanitygen -q 1)"
	address="$(grep -e "Address:" <<< "${VANITY}" | cut -d' ' -f2)"
	queryf
	# If JQ detects an error, skip address
	if ! getbal >/dev/null; then
		sleep 15
		continue
	fi
	# Get received amount for further processing
	REC="$(getbal)"
	if [[ -n "${REC}" ]] && [[ "${REC}" != "0" ]] && [[ "${REC}" != "null" ]] ; then
		{ date
		  printf 'Check this address! \n'
		  printf "%s\n" "${VANITY}"
		  printf "Received? %s\n" "${REC}"
		  printf "Addrs checked: %s.\n" "${N}"
		} | tee -a "${RECFILE}"
	fi
	sleep "${SLEEPTIME}"
	N=$((N+1))
done

exit

#Dead code

