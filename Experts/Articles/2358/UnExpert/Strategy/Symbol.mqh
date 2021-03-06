//+------------------------------------------------------------------+
//|                                                       Symbol.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include "MarketBook.mqh"
#include "Series.mqh"
#include "SessionInfo.mqh"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CSymbol : public CObject
{
private:
   string   m_symbol;               // Symbol
   ENUM_TIMEFRAMES m_period;        // Timeframe
   
public:
            CSymbol(void);
            CSymbol(string symbol, ENUM_TIMEFRAMES period);
   // Based series
   CTime    Time;
   COpen    Open;
   CHigh    High;
   CLow     Low;
   CClose   Close;
   CVolume  Volume;
   CMarketBook    MarketBook;
   CSessionInfo   SessionInfo;
   // Based foo
   bool     InitSeries(string symbol,ENUM_TIMEFRAMES period);
   bool     Available(void);
   string   Name(void);
   bool     Name(string symbol);
   ENUM_TIMEFRAMES Period(void);
   bool     Period(ENUM_TIMEFRAMES period);
   // SymbolInfoInteger
   bool     SelectInMarketWatch(void);
   bool     SpreadFloat(void);
   int      Digits(void);
   int      Spread(void);
   int      StopLevel(void);
   int      FreezeLevel(void);
   int      FlagsExpirationOrders(void);
   int      FlagsExecutionOrders(void);
   int      FlagsAllowedOrders(void);
   int      IndexByTime(datetime time);
   int      BarsTotal(void);
   ENUM_SYMBOL_CALC_MODE CalcContractType(void);
   ENUM_SYMBOL_TRADE_MODE ExecuteOrderType(void);
   ENUM_SYMBOL_TRADE_EXECUTION ExecuteDealsType(void);
   ENUM_SYMBOL_SWAP_MODE CalcSwapMode(void);
   ENUM_DAY_OF_WEEK DayOfSwap3x(void);
   ENUM_SYMBOL_OPTION_MODE OptionType(void);
   ENUM_SYMBOL_OPTION_RIGHT OptionRight(void);
   datetime TimeOfLastQuote(void);
   datetime StartDate(void);
   datetime ExpirationDate(void);
   // SymbolInfoDouble
   double   Ask(void);
   double   Bid(void);
   double   Last(void);
   double   StepToPrice(int price_step);
   double   PriceStep(void);
   double   OptionStrike(void);
   double   TickValue(void);
   double   ContractSize(void);
   double   VolumeContractMin(void);
   double   VolumeContractMax(void);
   double   VolumeContractStep(void);
   double   VolumeContractLimit(void);
   double   SwapLong(void);
   double   SwapShort();
   double   MarginInit(void);
   double   MarginMaintenance(void);
   double   MarginHedged(void);
   double   NormalizePrice(double price);
   // SymbolInfoString
   string   NameBasisSymbol(void);
   string   NameBasisCurrency(void);
   string   NameCurrencyProfit(void);
   string   NameCurrencyMargin(void);
   string   NameBank(void);
   string   Description(void);
   string   NameISIN(void);
   string   SymbolPath(void);
};
//+------------------------------------------------------------------+
//| Sets OHLCV series for the current instrument and timeframe       |
//+------------------------------------------------------------------+
CSymbol::CSymbol(void)
{
   m_symbol = ::Symbol();
   m_period = ::Period();
   InitSeries(Symbol(), ::Period());
}
//+------------------------------------------------------------------+
//| Returns the total number of bars of this symbol in the current   |
//| timeframe                                                        |
//+------------------------------------------------------------------+
int CSymbol::BarsTotal(void)
{
   int bars = Bars(this.Name(), this.Period());
   return bars;
}
//+------------------------------------------------------------------+
//| Returns the bar index corresponding to the specified time        |
//+------------------------------------------------------------------+
int CSymbol::IndexByTime(datetime time)
{
   int bars = Bars(this.Name(), this.Period(), time, TimeCurrent());
   return bars-1;
}
//+------------------------------------------------------------------+
//| Sets OHLCV series for the specified instrument and timeframe     |
//+------------------------------------------------------------------+
CSymbol::CSymbol(string symbol, ENUM_TIMEFRAMES period)
{
   m_symbol = symbol;
   m_period = period;
   InitSeries(symbol, period);
}
//+------------------------------------------------------------------+
//| Returns the symbol                                               |
//+------------------------------------------------------------------+
string CSymbol::Name(void)
{
   return m_symbol;
}
//+------------------------------------------------------------------+
//| Sets the symbol                                                  |
//+------------------------------------------------------------------+
bool CSymbol::Name(string symbol)
{
   m_symbol = symbol;
   InitSeries(m_symbol, m_period);
   return Available();
}
//+------------------------------------------------------------------+
//| Returns the period of the instrument                             |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CSymbol::Period(void)
{
   return m_period;
}
//+------------------------------------------------------------------+
//| Sets the period of the instrument                                |
//+------------------------------------------------------------------+
bool CSymbol::Period(ENUM_TIMEFRAMES period)
{
   m_period = period;
   InitSeries(m_symbol, m_period);
   return Available();
}
//+------------------------------------------------------------------+
//| Sets OHLCV series for the current instrument and timeframe.      |
//| Returns true if the symbol is available and false in the opposite|
//| case                                                             |
//+------------------------------------------------------------------+
bool CSymbol::InitSeries(string symbol,ENUM_TIMEFRAMES period)
{
   m_symbol = symbol;
   Time.Symbol(symbol);
   Time.Timeframe(period);
   Open.Symbol(symbol);
   Open.Timeframe(period);
   High.Symbol(symbol);
   High.Timeframe(period);
   Low.Symbol(symbol);
   Low.Timeframe(period);
   Close.Symbol(symbol);
   Close.Timeframe(period);
   Volume.Symbol(symbol);
   Volume.Timeframe(period);
   SessionInfo.Symbol(symbol);
   return Time.Total() > 0;
}
//+------------------------------------------------------------------+
//| Returns true if the symbol is available for work and false       |
//| otherwise                                                        |
//+------------------------------------------------------------------+
bool CSymbol::Available(void)
{
   return Bars(m_symbol, m_period) > 0;
}
//+------------------------------------------------------------------+
//| An indication that the symbol exists in the terminal             |
//+------------------------------------------------------------------+
bool CSymbol::SelectInMarketWatch(void)
{
   return (bool)SymbolInfoInteger(m_symbol, SYMBOL_SELECT);
}
//+------------------------------------------------------------------+
//| An indication of the floating spread                             |
//+------------------------------------------------------------------+
bool CSymbol::SpreadFloat(void)
{
   return (bool)SymbolInfoInteger(m_symbol, SYMBOL_SPREAD_FLOAT);
}
//+------------------------------------------------------------------+
//| Spread value in points                                           |
//+------------------------------------------------------------------+
int CSymbol::Spread(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_SPREAD);
}
//+------------------------------------------------------------------+
//| Minimum distance in points from the current close price          |
//| for setting Stop orders                                          |
//+------------------------------------------------------------------+
int CSymbol::StopLevel(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
}
//+------------------------------------------------------------------+
//| Freeze distance for trading operations (in points)               |
//+------------------------------------------------------------------+
int CSymbol::FreezeLevel(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL);
}
//+------------------------------------------------------------------+
//| Flags of allowed order expiration modes                          |
//+------------------------------------------------------------------+
int CSymbol::FlagsExpirationOrders(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_EXPIRATION_MODE);
}
//+------------------------------------------------------------------+
//| Flags of allowed order execution modes                           |
//+------------------------------------------------------------------+
int CSymbol::FlagsExecutionOrders(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_FILLING_MODE);
}
//+------------------------------------------------------------------+
//| Flags of allowed order types                                     |
//+------------------------------------------------------------------+
int CSymbol::FlagsAllowedOrders(void)
{
   return (int)SymbolInfoInteger(m_symbol, SYMBOL_ORDER_MODE);
}
//+------------------------------------------------------------------+
//| An indication that the symbol is selected in Market Watch        |
//+------------------------------------------------------------------+
int CSymbol::Digits(void)
{
   int digits=(int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   return digits;
}
//+------------------------------------------------------------------+
//| Contract price calculation mode                                  |
//+------------------------------------------------------------------+
ENUM_SYMBOL_CALC_MODE CSymbol::CalcContractType(void)
{
   return (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_CALC_MODE);
}
//+------------------------------------------------------------------+
//| Order execution type                                             |
//+------------------------------------------------------------------+
ENUM_SYMBOL_TRADE_MODE CSymbol::ExecuteOrderType(void)
{
   return (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_MODE);
}
//+------------------------------------------------------------------+
//| Deal execution type                                              |
//+------------------------------------------------------------------+
ENUM_SYMBOL_TRADE_EXECUTION CSymbol::ExecuteDealsType(void)
{
   return (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_EXEMODE);
}
//+------------------------------------------------------------------+
//| Swap calculation model                                           |
//+------------------------------------------------------------------+
ENUM_SYMBOL_SWAP_MODE CSymbol::CalcSwapMode(void)
{
   return (ENUM_SYMBOL_SWAP_MODE)SymbolInfoInteger(m_symbol, SYMBOL_SWAP_MODE);
}
//+------------------------------------------------------------------+
//| Triple-day swap day                                              |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK CSymbol::DayOfSwap3x(void)
{
   return (ENUM_DAY_OF_WEEK)SymbolInfoInteger(m_symbol, SYMBOL_SWAP_ROLLOVER3DAYS);
}
//+------------------------------------------------------------------+
//| Option type                                                      |
//+------------------------------------------------------------------+
ENUM_SYMBOL_OPTION_MODE CSymbol::OptionType(void)
{
   return (ENUM_SYMBOL_OPTION_MODE)SymbolInfoInteger(m_symbol, SYMBOL_OPTION_MODE);
}
//+------------------------------------------------------------------+
//| Option right (Call/Put)                                          |
//+------------------------------------------------------------------+
ENUM_SYMBOL_OPTION_RIGHT CSymbol::OptionRight(void)
{
   return (ENUM_SYMBOL_OPTION_RIGHT)SymbolInfoInteger(m_symbol, SYMBOL_OPTION_RIGHT);
}
//+------------------------------------------------------------------+
//| Time of the last quote                                           |
//+------------------------------------------------------------------+
datetime CSymbol::TimeOfLastQuote(void)
{
   return (datetime)SymbolInfoInteger(m_symbol, SYMBOL_TIME);
}
//+------------------------------------------------------------------+
//| Trading start date for an instrument                             |
//+------------------------------------------------------------------+
datetime CSymbol::StartDate(void)
{
   return (datetime)SymbolInfoInteger(m_symbol, SYMBOL_START_TIME);
}
//+------------------------------------------------------------------+
//| Trading end date for an instrument                               |
//+------------------------------------------------------------------+
datetime CSymbol::ExpirationDate(void)
{
   return (datetime)SymbolInfoInteger(m_symbol, SYMBOL_EXPIRATION_TIME);
}
//+------------------------------------------------------------------+
//| Returns Ask price.                                               |
//+------------------------------------------------------------------+
double CSymbol::Ask(void)
  {
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   ask=NormalizeDouble(ask,digits);
   return ask;
  }
//+------------------------------------------------------------------+
//| Returns Bid price.                                               |
//+------------------------------------------------------------------+
double CSymbol::Bid(void)
  {
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   bid=NormalizeDouble(bid,digits);
   return bid;
  }
//+------------------------------------------------------------------+
//| Returns Last price.                                              |
//+------------------------------------------------------------------+
double CSymbol::Last(void)
  {
   double last= SymbolInfoDouble(m_symbol,SYMBOL_LAST);
   int digits =(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS);
   last=NormalizeDouble(last,digits);
   return last;
  }
//+------------------------------------------------------------------+
//| Returns price steps as the price. For example, passed value      |
//| 3 on 5-digit EURUSD will be converted to 0.00003                 |
//+------------------------------------------------------------------+
double CSymbol::StepToPrice(int price_step)
{
   double price = SymbolInfoDouble(m_symbol, SYMBOL_POINT)*(double)price_step;
   return price;
}
//+------------------------------------------------------------------+
//| Returns the minimum price change for the instrument, for example |
//| EURUSD 5-digit 0.00001 will be returned                          |
//+------------------------------------------------------------------+
double CSymbol::PriceStep(void)
{
   double price = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   return price;
}
//+------------------------------------------------------------------+
//| Adjusts the passed price so that its value becomes equal to the  |
//| nearest possible price of the instrument, with consideration of  |
//| its number of decimal places and price step                      |
//+------------------------------------------------------------------+
double CSymbol::NormalizePrice(double price)
{
    int steps = (int)MathFloor(price/SymbolInfoDouble(m_symbol, SYMBOL_POINT));
    return steps*SymbolInfoDouble(m_symbol, SYMBOL_POINT);
}
//+------------------------------------------------------------------+
//| Returns option execution price                                   |
//+------------------------------------------------------------------+
double CSymbol::OptionStrike(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_OPTION_STRIKE);
}
//+------------------------------------------------------------------+
//| Returns the value of one tick expressed in the deposit currency  |
//+------------------------------------------------------------------+
double CSymbol::TickValue(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
}
//+------------------------------------------------------------------+
//| The size of one contract in the base contract units              |
//+------------------------------------------------------------------+
double CSymbol::ContractSize(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
}
//+------------------------------------------------------------------+
//| Minimum volume for deal execution in contracts                   |
//+------------------------------------------------------------------+
double CSymbol::VolumeContractMin(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
}
//+-------------------------------------------------------------------+
//| Maximum volume for deal execution in contracts                    |
//+-------------------------------------------------------------------+
double CSymbol::VolumeContractMax(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
}
//+-------------------------------------------------------------------+
//| The maximum allowed for this symbol total volume of an            |
//| open position                                                     |
//+-------------------------------------------------------------------+
double CSymbol::VolumeContractLimit(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_LIMIT);
}
//+-------------------------------------------------------------------+
//| The minimum volume change step for deal execution                 |
//+-------------------------------------------------------------------+
double CSymbol::VolumeContractStep(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
}
//+-------------------------------------------------------------------+
//| The value of swap charged for holding a long position with volume |
//| of one contract                                                   |
//+-------------------------------------------------------------------+
double CSymbol::SwapLong(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SWAP_LONG);
}
//+-------------------------------------------------------------------+
//| The value of swap charged for holding a short position with volume|
//| of one contract                                                   |
//+-------------------------------------------------------------------+
double CSymbol::SwapShort(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SWAP_SHORT);
}
//+-------------------------------------------------------------------+
//| The margin required to open a one-lot position                    |
//+-------------------------------------------------------------------+
double CSymbol::MarginInit(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_MARGIN_INITIAL);
}
//+-------------------------------------------------------------------+
//| The margin required to maintain one lot of an open position       |
//+-------------------------------------------------------------------+
double CSymbol::MarginMaintenance(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_MARGIN_MAINTENANCE);
}
//+-------------------------------------------------------------------+
//| The margin required to maintain one lot of a hedged position      |
//+-------------------------------------------------------------------+
double CSymbol::MarginHedged(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_MARGIN_HEDGED);
}
//+-------------------------------------------------------------------+
//| The name of the underlaying asset for a derivative symbol         |
//+-------------------------------------------------------------------+
string CSymbol::NameBasisSymbol(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_BASIS);
}
//+-------------------------------------------------------------------+
//| The base currency of an instrument                                |
//+-------------------------------------------------------------------+
string CSymbol::NameBasisCurrency(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_CURRENCY_BASE);
}
//+-------------------------------------------------------------------+
//| Profit currency                                                   |
//+-------------------------------------------------------------------+
string CSymbol::NameCurrencyProfit(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_CURRENCY_PROFIT);
}
//+-------------------------------------------------------------------+
//|  Margin currency                                                  |
//+-------------------------------------------------------------------+
string CSymbol::NameCurrencyMargin(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_CURRENCY_MARGIN);
}
//+-------------------------------------------------------------------+
//| The source of the current quote                                   |
//+-------------------------------------------------------------------+
string CSymbol::NameBank(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_BANK);
}
//+-------------------------------------------------------------------+
//| The string description of a symbol                                |
//+-------------------------------------------------------------------+
string CSymbol::Description(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_DESCRIPTION);
}
//+-------------------------------------------------------------------+
//| The name of a trading symbol in the international                 |
//| system of securities identification numbers ISIN                   |
//+-------------------------------------------------------------------+
string CSymbol::NameISIN(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_ISIN);
}
//+-------------------------------------------------------------------+
//| Path in the symbol tree                                           |
//+-------------------------------------------------------------------+
string CSymbol::SymbolPath(void)
{
   return SymbolInfoString(m_symbol, SYMBOL_PATH);
}