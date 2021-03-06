# markets
![ScreenShot](https://github.com/mountaineerbr/markets/blob/master/git_screenshot1.png)
Fig. 1. Running scripts: binance.sh, bitfinex.sh, binfo.sh, bitstamp.sh, cgk.sh, cmc.sh, etc.

-------------------------------------------------------------------------------------------------

<b>INDEX</b>:

<b>alpha.sh</b> -- Stocks and Currency Rates from <AlphaAvantage.co> (Most popular Yahoo Finance API alternative), get your free API key.

<b>bakkt.sh --</b> Price and contract/volume tickers for Bakkt public API.

<b>binance.sh --</b>  Binance public API, crypto converter, prices, book depth, coin ticker.

<b>binfo.sh --</b> Blockchain Explorer for Bitcoin; uses Blockchain.info & BlockChair.com public APIs; shows notification on new block found for the Bitcoin blockchain.

<b>bitstamp.sh --</b> Bitstamp exchange public API for live trade prices/info.

<b>bitfinex.sh --</b> Bitfinex exchange public API for live trade prices.

<b>brasilbtc.sh --</b> Puxa cotações de Bitcoin de Agências de Câmbio Brasileiras de APIs públicas; fetches Bitcoin rates from Brazilian Exchanges public APIs.

<b>cgk.sh --</b> CoingGecko.com public API, currency converter, market ticker, cryptocurrency ticker;
This is my favorite everyday-use script for all-currency rates!

<b>clay.sh --</b> CurrencyLayer.com API, central bank currency, precious metal and cryptocurrency converter.

<b>cmc.sh --</b>  CoinMarketCap.com API, currency converter, market ticker.

<b>erates.sh --</b> ExchangeRatesAPI.io public API, currency converter (same API as Alexander Epstein's Bash-Snippets/currency).

<b>foxbit.sh --</b> FoxBit public API rates, Acesso API Público do FoxBit para cotações.

<b>hgb.sh --</b> Cotações de ações da Bovespa e índices e taxas (CDI e SELIC) do API da HG Brasil.

<b>myc.sh --</b> MyCurrency.net public API, central bank currency converter.

<b>openx.sh --</b> OpenExchangeRates.org API, central bank currency converter.

<b>ourominas.sh --</b> Pega taxas da API pública da Ouro Minas.

<b>parmetal.sh --</b> Pega taxas da API pública da Parmetal.

<b>stocks.sh --</b> Financialmodelingprep.com public API latest and historical stock rates (same API as Alexander Epstein's "stocks").

<b>uol.sh --</b> Puxa dados de páginas da API pública do UOL Economia.

<b>yahooFinanceSymbols.txt</b> -- Some Yahoo! Finance stock symbols. Alguns símbolos do yahoo! Finance.

<b>whalealert.sh --</b> Latest whale transactions from whale-alert.io API.

<i>Also check/Também veja:

My Bash Calculator Wrapper that keeps a record of results "bcalc.sh" at: https://github.com/mountaineerbr/scripts/blob/master/bcalc.sh

Alexander Epstein's "currency_bash-snipet.sh" at <https://github.com/alexanderepstein>; uses the same API as Erates.sh

MiguelMota's "Cointop" at <https://github.com/miguelmota/cointop> for crypto currency tickers;

8go's "CoinBash.sh" at <https://github.com/8go/coinbash> for CoinMarketCap simple tickers.

Brandleesee's "Mop: track stocks the hacker way" at https://github.com/mop-tracker/mop</i>

<b>IMPORTANT: None of these scripts are supposed to be used under truly professional constraints. Do your own research!

IMPORTANTE: Nenhum desses scripts deve ser usado em meio profissional sem análise prévia. Faça sua própria pesquisa!</b>

-------------------------------------------------------------------------------------------------

<b>IMPORTANT: Please create free accounts and API keys to use with scripts that require them! You can add your API key to the script source code as per help pages or set them as environment variables.</b>
  
<b>SUMMARY:</b>

Related to crypto and bank currency markets. Run them with "-h" for a Help Page. Check below for script descriptions, download and run basic instructions.

These scripts use the latest version of Bash. Other packages that may be required to run some functions are Curl, JQ, Websocat and Lolcat.

-------------------------------------------------------------------------------------------------

<b>SUMÁRIO:</b>

<b>IMPORTANTE: Crie contas e chaves de API gratuitas para usar com os scripts que as exijam! Você pode adicionar sua chave de API ao código-fonte do script de acordo com as páginas de ajuda ou configurá-las como variáveis de ambiente.</b>

ESTE REPOSITÓRIO é relacionado com mercados de cripto e de moedas de banco centrais. Rode os scripts com "-h" para ver uma página de Ajuda (em Inglês).

Esses scripts usam a última versão do Bash. Outros pacotes que precisam estar presentes no sistema para que todas as funções trabalhem corretamente são Curl, JQ, Websocat and Lolcat.

-------------------------------------------------------------------------------------------------

<b>INSTRUÇÕES BÁSICAS:</b>

No Ubuntu 19.04, pode-se instalar os pacotes curl, jq e lolcat facilmente dos repos oficiais. Já o pacote websocat pode ser um pouco mais complicado..

Para fazer o download de um script, abra-o/visualize-o no Github e depois clique com o botão direito do mouse em cima do botão "Raw" e escolha a opção "Salvar Link Como...". Depois de feito o download (por exemplo, em ~/Downloads/binance.sh), será necessário marcar o script como executável. No GNOME, clicar com o botao direito em cima do arquivo > Propriedades > Permissões e selecionar a caixa "Permitir execução do arquivo como programa", ou

<i>$ chmod +x ~/Downloads/binance.sh</i>

Então, caminhe até a pasta onde script se encontra.

<i>$ cd ~/Downloads</i>

Para executá-lo, não se esqueça de adicionar ./ antes do nome do script:

<i>$ ./binance.sh

$ bash binance.sh</i>

Alternativeamente, você pode clonar este repo inteiro.

<i>$ cd Downloads

$ git clone https://github.com/mountaineerbr/markets.git

$ chmod +x ~/Downloads/markets/*.sh</i>

Você pode fazer bash aliases individuais para os scripts ou colocar os scripts sob seu PATH.

-------------------------------------------------------------------------------------------------

<b>BASIC INSTRUCTIONS:</b>

On Ubuntu 19.04, you can install curl, jq and lolcat packages easily from the official repos. The websocat package may be a little more complicated..

To download a script, view it on Github. Then, right-click on the "Raw" button and choose "Save Link As ..." option. Once downloaded (eg ~ / Downloads / binance.sh), you will need to mark the script as executable. In GNOME, right-click on the file > Properties> Permissions and check the "Allow executing file as programme" box, or

<i>$ chmod + x ~ / Downloads / binance.sh</i>

Then cd to the folder where the script is located.

<i>$ cd ~ / Downloads</i>

To execute it, be sure to add ./ before the script name:

<i>$ ./binance.sh
  
$ bash binance.sh</i>

Alternatively, you can clone this entire repo.

<i>$ cd Downloads

$ git clone https://github.com/mountaineerbr/markets.git

$ chmod +x ~/Downloads/markets/*.sh</i>

You can use bash aliases to individual scripts or place them under your PATH.

-------------------------------------------------------------------------------------------------

<b>If useful, consider giving me a nickle! =)
  
Se foi útil, considere me lançar um trocado!</b>

bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
