#!/bin/bash
# Binance.sh  -- Bash Crypto Converter and API Access
# v0.6.20  23/nov/2019  by mountaineerbr

# Some defaults
LC_NUMERIC=en_US.UTF-8
FSTR="%.2f" 
WHICHB="com"

HELP="NAME
	\033[012;36mBinance.sh - Bash Cryptocurrency Converter\033[00m
	\033[012;36m             Binance API Access\033[00m


SYNOPSIS
	binance.sh [-fNUM|STR] [-u] [AMOUNT] [FROM_CRYPTO] [TO_CRYPTO]

	binance.sh [-fNUM|STR] [-cirsuw] [FROM_CRYPTO] [TO_CRYPTO]
	
	binance.sh [-bbbtu] [FROM_CRYPTO] [TO_CRYPTO]
	
	binance.sh [-hjlv]


	This script gets rate of any cryptocurrency pair that Binance supports
	and can convert any amount of one crypto into another. It fetches data 
	from Binance public APIs.

	Take  notice  that Binance supports  specific markets, so for example, 
	there is a market for XRPBTC but not for BTCXRP. You can get a List of 
	all supported markets running the script with the option \"-l\".

	You can get data from Binance US with the flag option \"-u\", otherwise
	defaults to Binance Exchange from Malta.

	There are a few functions/modes for watching price rolling of the latest
	trades, as well as trade quantity. You can also watch book depth of any
	supported  Binance market.  Some functions use cURL/Wget to fetch data 
	from REST APIs and some use Websocat to fetch data from websockets. If 
	no market/currency pair is given, uses BTCUSDT by defaults. If option 
	\"-u\" is used, defaults to BTCUSD.

	It is accepted to write each currency that forms a market separately or
	together. Example: \"ZEC USDT\" or \"ZECUSDT\". Case is insensitive.

	Functions that use cURL/Wget to fecth data from REST APIs update a lit-
	tle slower because they depend on reconnecting repeatedly, whereas web-
	socket streams leave an open connection so there is more frequent data
	flow.

	Default precision is unspecified for currency conversion, and defaults 
	to  two  decimal plates in price roll functions. A different number of 
	decimal plates can be supplied with the option \"-f\". See example (3).
	This  option  also  accepts printf-like	formatting. This option is spe-
	cially useful if exchange rates or amount of a crypto for conversion is 
	very large or very small. It is also possible to add \"thousands\" sepa-
	rator. See usage example (4).

  
LIMITS ON WEBSOCKET MARKET STREAMS

	\"A single connection to stream.binance.com is only valid for 24 hours; 
	expect to be disconnected at the 24 hour mark.\"

	<https://binance-docs.github.io/apidocs/spot/en/#symbol-order-book-ticker>


WARRANTY
	Licensed under the GNU Public License v3 or better and is distributed
	without support or bug corrections.
   	
	This script needs Bash, cURL or Wget, JQ , Websocat, Lolcat and Core-
	utils to work properly.

	Beware of unlimited scrollback buffers for terminal emulators. As data 
	flow is very intense, scrollback buffers should be kept small or com-
	pletely unset in order to avoid system freezes.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES
		(1) 	One Bitcoin in Tether:
			
			$ binance.sh btc usdt


			Same using Binance US rates:
			
			$ binance.sh -u btc usdt


		(2)     Half a Dash in Binance Coin:
			
			$ binance.sh 0.5 dash bnb 


		(3)     1000 Z-Cash in Paxos Standard:
			
			$ binance.sh 100 zec pax 


		(4)     Price of one XRP in USDC, four decimal plates:
			
			$ binance.sh -f4 xrp usdc 
			
		
		(5)     Price stream of BTCUSDT, group thousands; print only 
			one decimal plate:
			
			$ binance.sh -s -f\"%'.1f\" btc usdt


		(6) 	Order book depth view of ETHUSDT (20 levels on each 
			side), data from Binance US:

			$ binance.sh -bbu eth usdt


		(7)     Grep rates for all Bitcoin markets:

			$ binance.sh -l

			
			Tip: Use pipe and grep to search for specific markets:
			
			$ binance.sh -l	| grep BTC

			
			OBS: use \"^BTC\" to get markets that start with BTCxxx;
			     use \"BTC$\" to get markets that  end  with xxxBTC.

OPTIONS
	-b 	Order book depth streams; depth=10; pass twice to depth=20; pass
		three times to get some book order stats.

	-c 	Price in columns (last 250 orders); screen prices overlap in 
		each update; prices update from bottom right to top left; uses
		cURL/Wget.

	-f 	Formatting of prices (printf-like); number of decimal plates; 
		for use with options \"-c\", \"-s\" and \"-w\".

	-h 	Show this Help.

	-i 	Detailed Information of the trade stream; uses websocket.
	
	-j  	For debugging; print lines that fetch Binance raw JSON data.

	-l 	List supported markets (coin pairs and rates).
	
	-r 	Together  with  options  \"-s\", \"-w\", \"-i\", use cURL/Wget
		instead of Websocat.

	-s 	Stream of lastest trade prices; uses websocket.
	
	-t 	Rolling 24H Ticker for a currency pair/market; uses websocket.

	-u 	Use Binance.us server instead of Binance.com; Binance US has 
		lower volume (currently approx. 0.5%).
		
	-v 	Show this script version.
	
	-w 	Colored stream of latest trade prices; uses Websocket & Lolcat."


## Error Check Function
errf() {
	if grep -iq -e "err" -e "code" <<< "${JSON}"; then
		echo "${JSON}"
		UNIQ="/tmp/binance_err.log${RANDOM}${RANDOM}"
		echo "${JSON}" > ${UNIQ}
		echo "Error detected in JSON." 1>&2
		echo "${UNIQ}" 1>&2
		exit 1
	fi
}

# Functions
colf() {  # Price in columns
	while true; do
		JSON="$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/aggTrades?symbol=${2^^}${3^^}&limit=${LIMIT}")"
		errf
		jq -r '.[] | .p' <<< "${JSON}" | awk '{ printf "\n'${FSTR}'", $1 }' | column
		printf "\n"
	done
	exit 0
}
infof() {  # Price and trade info
# Note: Only with this method you can access QuoteQty!!
	curlmode() {
		printf "Rate, quantity and time (%s).\n" "${2^^}${3^^}"
	while true; do
		JSON=$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/trades?symbol=${2^^}${3^^}&limit=1")
		errf
		RATE="$(jq -r '.[] | .price' <<< "${JSON}")"
		QQT="$(jq -r '.[] | .quoteQty' <<< "${JSON}")"
		TS="$(jq -r '.[] | .time' <<< "${JSON}" | cut -c-10)"
		DATE="$(date -d@"${TS}" "+%T%Z")"
		printf "\n${FSTR} \t%'.f\t%s" "${RATE}" "${QQT}" "${DATE}"   
	done
	exit 0
	}
	# cURL Mode?
	test -n "${CURLOPT}" &&	curlmode "${@}"

	# Websocat Mode
	printf "Detailed Stream of %s%s\n" "${2^^}" "${3^^}"
	printf -- "Price, Quantity and Time.\n"
	${WEBSOCATC} "${WSSADD}${2,,}${3,,}@aggTrade" | jq --unbuffered -r '"P: \(.p|tonumber)  \tQ: \(.q)     \tPQ: \((.p|tonumber)*(.q|tonumber)|round)    \t\(if .m == true then "MAKER" else "TAKER" end)\t\(.T/1000|round | strflocaltime("%H:%M:%S%Z"))"'
	exit 0
}

socketf() {  # Stream of prices
	curlmode() { 
		printf "Rate for %s.\n" "${2^^}${3^^}"
		while true; do
			JSON="$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/aggTrades?symbol=${2^^}${3^^}&limit=1")"
	 		errf
			jq -r '.[] | .p' <<< "${JSON}" | awk '{ printf "\n'${FSTR}'", $1 }' | ${COLORC}
		done
		exit 0
		}
	# cURL Mode?
	test -n "${CURLOPT}" &&	curlmode "${@}"

	# Websocat Mode
	printf "Stream of %s%s\n" "${2^^}" "${3^^}"
	${WEBSOCATC} "${WSSADD}${2,,}${3,,}@aggTrade" | jq --unbuffered -r '.p' | xargs -n1 printf "\n${FSTR}" | ${COLORC}
	#stdbuf -i0 -o0 -e0 cut -c-8
	exit
}

bookdf() { # Depth of order book (depth=10)
	printf "Order Book Depth\n"
	printf "Price and Quantity\n"
	${WEBSOCATC} "${WSSADD}${2,,}${3,,}@depth10@100ms" |
	jq -r --arg FCUR "${2^^}" --arg TCUR "${3^^}" '
		"\nORDER BOOK DEPTH \($FCUR) \($TCUR)",
		"",
		"\t\(.asks[9]|.[0]|tonumber)    \t\(.asks[9]|.[1]|tonumber)",
		"ASKS\t\(.asks[8]|.[0]|tonumber)    \t\(.asks[8]|.[1]|tonumber)",
		"\t\(.asks[7]|.[0]|tonumber)    \t\(.asks[7]|.[1]|tonumber)",
		"\t\(.asks[6]|.[0]|tonumber)    \t\(.asks[6]|.[1]|tonumber)",
		"\t\(.asks[5]|.[0]|tonumber)    \t\(.asks[5]|.[1]|tonumber)",
		"\t\(.asks[4]|.[0]|tonumber)    \t\(.asks[4]|.[1]|tonumber)",
		"\t\(.asks[3]|.[0]|tonumber)    \t\(.asks[3]|.[1]|tonumber)",
		"\t\(.asks[2]|.[0]|tonumber)    \t\(.asks[2]|.[1]|tonumber)",
		"\t\(.asks[1]|.[0]|tonumber)    \t\(.asks[1]|.[1]|tonumber)",
		"     > \(.asks[0]|.[0]|tonumber)      \t\(.asks[0]|.[1]|tonumber)",
		"     < \(.bids[0]|.[0]|tonumber)      \t\(.bids[0]|.[1]|tonumber)",
		"\t\(.bids[1]|.[0]|tonumber)    \t\(.bids[1]|.[1]|tonumber)",
		"\t\(.bids[2]|.[0]|tonumber)    \t\(.bids[2]|.[1]|tonumber)",
		"\t\(.bids[3]|.[0]|tonumber)    \t\(.bids[3]|.[1]|tonumber)",
		"\t\(.bids[4]|.[0]|tonumber)    \t\(.bids[4]|.[1]|tonumber)",
		"\t\(.bids[5]|.[0]|tonumber)    \t\(.bids[5]|.[1]|tonumber)",
		"\t\(.bids[6]|.[0]|tonumber)    \t\(.bids[6]|.[1]|tonumber)",
		"\t\(.bids[7]|.[0]|tonumber)    \t\(.bids[7]|.[1]|tonumber)",
		"BIDS\t\(.bids[8]|.[0]|tonumber)    \t\(.bids[8]|.[1]|tonumber)",
		"\t\(.bids[9]|.[0]|tonumber)    \t\(.bids[9]|.[1]|tonumber)"'
		exit
}
bookdef() { # Depth of order book (depth=20)
	printf "Order Book Depth\n"
	printf "Price and Quantity\n"
	${WEBSOCATC} "${WSSADD}${2,,}${3,,}@depth20@100ms" |
	jq -r --arg FCUR "${2^^}" --arg TCUR "${3^^}" '
		"\nORDER BOOK DEPTH \($FCUR) \($TCUR)",
		"",
		"\t\(.asks[19]|.[0]|tonumber)    \t\(.asks[19]|.[1]|tonumber)",
		"\t\(.asks[18]|.[0]|tonumber)    \t\(.asks[18]|.[1]|tonumber)",
		"\t\(.asks[17]|.[0]|tonumber)    \t\(.asks[17]|.[1]|tonumber)",
		"\t\(.asks[16]|.[0]|tonumber)    \t\(.asks[16]|.[1]|tonumber)",
		"\t\(.asks[15]|.[0]|tonumber)    \t\(.asks[15]|.[1]|tonumber)",
		"\t\(.asks[14]|.[0]|tonumber)    \t\(.asks[14]|.[1]|tonumber)",
		"\t\(.asks[13]|.[0]|tonumber)    \t\(.asks[13]|.[1]|tonumber)",
		"\t\(.asks[12]|.[0]|tonumber)    \t\(.asks[12]|.[1]|tonumber)",
		"\t\(.asks[11]|.[0]|tonumber)    \t\(.asks[11]|.[1]|tonumber)",
		"\t\(.asks[10]|.[0]|tonumber)    \t\(.asks[10]|.[1]|tonumber)",
		"\t\(.asks[9]|.[0]|tonumber)    \t\(.asks[9]|.[1]|tonumber)",
		"ASKS\t\(.asks[8]|.[0]|tonumber)    \t\(.asks[8]|.[1]|tonumber)",
		"\t\(.asks[7]|.[0]|tonumber)    \t\(.asks[7]|.[1]|tonumber)",
		"\t\(.asks[6]|.[0]|tonumber)    \t\(.asks[6]|.[1]|tonumber)",
		"\t\(.asks[5]|.[0]|tonumber)    \t\(.asks[5]|.[1]|tonumber)",
		"\t\(.asks[4]|.[0]|tonumber)    \t\(.asks[4]|.[1]|tonumber)",
		"\t\(.asks[3]|.[0]|tonumber)    \t\(.asks[3]|.[1]|tonumber)",
		"\t\(.asks[2]|.[0]|tonumber)    \t\(.asks[2]|.[1]|tonumber)",
		"\t\(.asks[1]|.[0]|tonumber)    \t\(.asks[1]|.[1]|tonumber)",
		"     > \(.asks[0]|.[0]|tonumber)      \t\(.asks[0]|.[1]|tonumber)",
		"     < \(.bids[0]|.[0]|tonumber)      \t\(.bids[0]|.[1]|tonumber)",
		"\t\(.bids[1]|.[0]|tonumber)    \t\(.bids[1]|.[1]|tonumber)",
		"\t\(.bids[2]|.[0]|tonumber)    \t\(.bids[2]|.[1]|tonumber)",
		"\t\(.bids[3]|.[0]|tonumber)    \t\(.bids[3]|.[1]|tonumber)",
		"\t\(.bids[4]|.[0]|tonumber)    \t\(.bids[4]|.[1]|tonumber)",
		"\t\(.bids[5]|.[0]|tonumber)    \t\(.bids[5]|.[1]|tonumber)",
		"\t\(.bids[6]|.[0]|tonumber)    \t\(.bids[6]|.[1]|tonumber)",
		"\t\(.bids[7]|.[0]|tonumber)    \t\(.bids[7]|.[1]|tonumber)",
		"BIDS\t\(.bids[8]|.[0]|tonumber)    \t\(.bids[8]|.[1]|tonumber)",
		"\t\(.bids[9]|.[0]|tonumber)    \t\(.bids[9]|.[1]|tonumber)",
		"\t\(.bids[10]|.[0]|tonumber)    \t\(.bids[10]|.[1]|tonumber)",
		"\t\(.bids[11]|.[0]|tonumber)    \t\(.bids[11]|.[1]|tonumber)",
		"\t\(.bids[12]|.[0]|tonumber)    \t\(.bids[12]|.[1]|tonumber)",
		"\t\(.bids[13]|.[0]|tonumber)    \t\(.bids[13]|.[1]|tonumber)",
		"\t\(.bids[14]|.[0]|tonumber)    \t\(.bids[14]|.[1]|tonumber)",
		"\t\(.bids[15]|.[0]|tonumber)    \t\(.bids[15]|.[1]|tonumber)",
		"\t\(.bids[16]|.[0]|tonumber)    \t\(.bids[16]|.[1]|tonumber)",
		"\t\(.bids[17]|.[0]|tonumber)    \t\(.bids[17]|.[1]|tonumber)",
		"\t\(.bids[18]|.[0]|tonumber)    \t\(.bids[18]|.[1]|tonumber)",
		"\t\(.bids[19]|.[0]|tonumber)    \t\(.bids[19]|.[1]|tonumber)"'
	exit
}
booktf() {
	printf "Order Book Total Stats (%s%s).\n" "${2^^}" "${3^^}"
	BOOK="$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/depth?symbol=${2^^}${3^^}&limit=10000")"
	BIDSL="$(jq '.bids[]|.[1]' <<<"${BOOK}" | wc -l)"
	ASKSL="$(jq '.asks[]|.[1]' <<<"${BOOK}" | wc -l)"
	BIDST="$(jq -r '.bids[]|.[1]' <<<"${BOOK}" | paste -sd+ | bc -l)"
	ASKST="$(jq -r '.asks[]|.[1]' <<<"${BOOK}" | paste -sd+ | bc -l)"
	BARATE="$(bc -l <<<"scale=4;$(jq -r '.bids[]|.[1]' <<<"${BOOK}" | paste -sd+ | bc)/$(jq -r '.asks[]|.[1]' <<<"${BOOK}" | paste -sd+ | bc)")"
	column -N' ,TOTAL,LEVELS' -s'=' -t <<- TABLE
	B/A=${BARATE}
	BIDS=${BIDST}=${BIDSL}
	ASKS=${ASKST}=${ASKSL}
	TABLE
}

tickerf() { # 24-H Ticker
	${WEBSOCATC} "${WSSADD}${2,,}${3,,}@ticker" |
		jq -r '"",.s,.e,(.E/1000|round | strflocaltime("%H:%M:%S%Z")),
			"Window   :  \(((.C-.O)/1000)/(60*60)) hrs",
			"",
			"Price",
			"Change   :  \(.p|tonumber)  (\(.P|tonumber) %)",
			"W Avg    :  \(.w|tonumber)",
			"Open     :  \(.o|tonumber)",
			"High     :  \(.h|tonumber)",
			"Low      :  \(.l|tonumber)",
			"",
			"Total Volume",
			"Base     :  \(.v|tonumber)",
			"Quote    :  \(.q|tonumber)",
			"",
			"Trades",
			"N of  T  :  \(.n)",
			"First ID :  \(.F)",
			"Last  ID :  \(.L)",
			"First T-1:  \(.x)",
			"Last  T  :  \(.c|tonumber)  Qty: \(.Q)",
			"Best Bid :  \(.b|tonumber)  Qty: \(.B)",
			"Best Ask :  \(.a|tonumber)  Qty: \(.A)"'
	exit
}
# List markets and prices
lcoinsf() {
	LDATA="$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/ticker/price")"
	jq -r '.[] | "\(.symbol)=\(.price)"' <<< "${LDATA}"| sort | column -s '=' -et -N 'Market,Rate'
	printf "Markets: %s\n" "$(jq -r '.[].symbol' <<< "${LDATA}"| wc -l)"
	exit
}

# Check for no arguments or options in input
if ! [[ "${@}" =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 1
fi

# Parse options
while getopts ":bdecf:hjlistuwvr" opt; do
	case ${opt} in
		j ) # Print JSON
			printf "Check below script lines that fetch raw JSON data:\n"
			grep -e "YOURAPP" -e "WEBSOCATC" <"${0}" | sed -e 's/^[ \t]*//' | sort
			exit 0
	      		;;
		l ) # List markets (coins and respective rates)
			LOPT=1
	      		;;
		c ) # Price in columns
	      		COPT=1
	      		LIMIT=250
	      		;;
		[bde] ) # Order book depth view
	      		if [[ -z "${BOPT}" ]]; then
				BOPT=1
	      		elif [[ "${BOPT}" -eq 1 ]]; then
				BOPT=2
	      		elif [[ "${BOPT}" -eq 2 ]]; then
				BOPT=3
			fi
	      		;;
		f ) # Printf-like format numbers
	 	     	FCONVERTER=1
	      		if [[ "${OPTARG}" =~ ^[0-9]+ ]]; then
		   		FSTR="%.${OPTARG}f"
		   		else
		   		FSTR="${OPTARG}"
	      		fi
	      		;;
		i ) # Detailed latest trade information
	      		IOPT=1
	      		;;
		s ) # Stream of trade prices
			COLORC="cat"
	      		SOPT=1
	      		;;
		w ) # Coloured stream of trade prices
	      		SOPT=1
	      		COLORC="lolcat -p 2000 -F 5"
	      		;;
		t ) # Rolling Ticker 
	      		TOPT=1
	      		;;
		r ) # cURL opt instead of Websocat
	      		CURLOPT=1
	      		;;
		h ) # Help
	      		echo -e "${HELP}"
	      		exit 0
	      		;;
		v ) # Version of Script
	      		head "${0}" | grep -e '# v'
	      		exit 0
	      		;;
		u ) # Binance US
			WHICHB="us"
			;;
		\? )
	     		echo "Invalid Option: -$OPTARG" 1>&2
	     		exit 1
	     		;;
  	esac
done
shift $((OPTIND -1))

# Test for must have packages
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi
if [[ -n "${IOPT}${SOPT}${BOPT}${BEOPT}${TOPT}" ]] && [[ -z "${CURLOPT}" ]] && ! command -v websocat &>/dev/null; then
	printf "Websocat is required.\n" 1>&2
	exit 1
fi

# More defaults
WEBSOCATC="websocat -nt --ping-interval 20 -E --ping-timeout 42"
WSSADD="wss://stream.binance.${WHICHB}:9443/ws/"

# Arrange arguments
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] || [[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi

# Sets btc as "from_currency" for market code formation
# Will not set when calling the script without any option
if [[ -z ${2} ]]; then
	set -- "${1}" "BTC"
fi

# Get markets symbols and test if inputs are valid markets
MARKETS="$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/ticker/price" | jq -r '.[].symbol')"
if [[ -z ${3} ]] && ! grep -qi "^${2}$" <<< "${MARKETS}"; then
	if [[ "${WHICHB}" = "com" ]]; then
		set -- ${@:1:2} "USDT"
	else
		set -- ${@:1:2} "USD"
	fi
fi

## Check if input is a supported market 
if ! grep -qi "^${2}${3}$" <<< "${MARKETS}"; then
	printf "ERR: Market not supported: %s%s\n" "${2^^}" "${3^^}" 1>&2
	printf "List markets with option \"-l\".\n" 1>&2
	exit 1
fi

# get a list of markets/coins
test -n "${LOPT}" && lcoinsf
# Viewing/Watching Modes opts
# Detailed Trade info
test -n "${IOPT}" && infof "${@}"
# Socket Stream
test -n "${SOPT}" && socketf "${@}"
# Book Order Depth View Optios
if [[ "${BOPT}" -eq 1 ]]; then
	# Book Order Depth 10
	bookdf "${@}"
elif [[ "${BOPT}" -eq 2 ]]; then
	# Book Order Depth 20
	bookdef "${@}"
elif [[ "${BOPT}" -eq 3 ]]; then
	# Book Order total bids/asks max depth levels
	booktf "${@}"
	exit
fi
# 24-H Ticker
test -n "${TOPT}" && tickerf "${@}"
# Price in columns
test -n "${COPT}" && colf "${@}"

## Crypto conversion/market rate -- DEFAULT OPT
# Get rate
BRATE=$(${YOURAPP} "https://api.binance.${WHICHB}/api/v3/ticker/price?symbol=${2^^}${3^^}" | jq -r ".price")
# Check for floating point specs (decimal plates) and print result
if [[ -n "${FCONVERTER}" ]]; then
	bc -l <<< "${1}*${BRATE}" | xargs printf "${FSTR}\n"
else
	bc -l <<< "${1}*${BRATE}"
fi
exit 

