//+------------------------------------------------------------------+
//|                                                  SessionInfo.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Session info                                                     |
//+------------------------------------------------------------------+
class CSessionInfo
{
private:
   string   m_symbol;
public:
   void     Symbol(string symbol);
   long     DealsTotal(void);
   long     BuyOrdersTotal(void);
   long     SellOrdersTotal(void);
   long     HighVolume(void);
   long     LowVolume(void);
   double   BidHigh(void);
   double   AskHigh(void);
   double   BidLow(void);
   double   AskLow(void);
   double   LastHigh(void);
   double   LastLow(void);
   double   VolumeTotal(void);
   double   TurnoverTotal(void);
   double   OpenInterestTotal(void);
   double   BuyOrdersVolume(void);
   double   SellOrdersVolume(void);
   double   PriceSessionOpen(void);
   double   PriceSessionClose(void);
   double   PriceSessionAverage(void);
   double   PriceSettlement(void);
   double   PriceLimitMax(void);
   double   PriceLimitMin(void);
};
//+------------------------------------------------------------------+
//| Set symbol                                                       |
//+------------------------------------------------------------------+
CSessionInfo::Symbol(string symbol)
{
   m_symbol = symbol;
}
//+------------------------------------------------------------------+
//| The number of deals in the current session                       |
//+------------------------------------------------------------------+
long CSessionInfo::DealsTotal(void)
{
   return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_DEALS);
}
//+------------------------------------------------------------------+
//| The total number of Buy orders at the moment                     |
//+------------------------------------------------------------------+
long CSessionInfo::BuyOrdersTotal(void)
{
   return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_BUY_ORDERS);
}
//+------------------------------------------------------------------+
//| The total number of Sell  orders at the moment                   |
//+------------------------------------------------------------------+
long CSessionInfo::SellOrdersTotal(void)
{
   return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_SELL_ORDERS);
}
//+------------------------------------------------------------------+
//| The highest volume during the current trading session            |
//+------------------------------------------------------------------+
long CSessionInfo::HighVolume(void)
{
   return SymbolInfoInteger(m_symbol, SYMBOL_VOLUMEHIGH);
}
//+------------------------------------------------------------------+
//| The lowest volume during the current trading session             |
//+------------------------------------------------------------------+
long CSessionInfo::LowVolume(void)
{
   return SymbolInfoInteger(m_symbol, SYMBOL_VOLUMELOW);
}
//+------------------------------------------------------------------+
//| The highest Bid price of the day                                 |
//+------------------------------------------------------------------+
double CSessionInfo::BidHigh(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_BIDHIGH);
}
//+------------------------------------------------------------------+
//| The highest Ask price of the day                                 |
//+------------------------------------------------------------------+
double CSessionInfo::AskHigh(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_ASKHIGH);
}
//+------------------------------------------------------------------+
//| The lowest Bid price of the day                                  |
//+------------------------------------------------------------------+
double CSessionInfo::BidLow(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_BIDLOW);
}
//+------------------------------------------------------------------+
//| The lowest Ask price of the day                                  |
//+------------------------------------------------------------------+
double CSessionInfo::AskLow(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_ASKLOW);
}
//+------------------------------------------------------------------+
//| The highest Last price of the day                                |
//+------------------------------------------------------------------+
double CSessionInfo::LastHigh(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_LASTHIGH);
}
//+------------------------------------------------------------------+
//| The lowest Last price of the day                                 |
//+------------------------------------------------------------------+
double CSessionInfo::LastLow(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_LASTLOW);
}
//+------------------------------------------------------------------+
//| The total volume of deals in the current session                 |
//+------------------------------------------------------------------+
double CSessionInfo::VolumeTotal(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_VOLUME);
}
//+------------------------------------------------------------------+
//| The total turnover in the current session                        |
//+------------------------------------------------------------------+
double CSessionInfo::TurnoverTotal(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_TURNOVER);
}
//+------------------------------------------------------------------+
//| The total volume of open positions                               |
//+------------------------------------------------------------------+
double CSessionInfo::OpenInterestTotal(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_INTEREST);
}
//+------------------------------------------------------------------+
//| The total volume of Buy orders at the moment                     |
//+------------------------------------------------------------------+
double CSessionInfo::BuyOrdersVolume(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_BUY_ORDERS_VOLUME);
}
//+------------------------------------------------------------------+
//| The total volume of Sell orders at the moment                    |
//+------------------------------------------------------------------+
double CSessionInfo::SellOrdersVolume(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_SELL_ORDERS_VOLUME);
}
//+------------------------------------------------------------------+
//| The open price of the session                                    |
//+------------------------------------------------------------------+
double CSessionInfo::PriceSessionOpen(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_OPEN);
}
//+------------------------------------------------------------------+
//| The close price of the session                                   |
//+------------------------------------------------------------------+
double CSessionInfo::PriceSessionClose(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_CLOSE);
}
//+------------------------------------------------------------------+
//| The average weighted price of the session                        |
//+------------------------------------------------------------------+
double CSessionInfo::PriceSessionAverage(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_AW);
}
//+------------------------------------------------------------------+
//| The settlement price of the current session                      |
//+------------------------------------------------------------------+
double CSessionInfo::PriceSettlement(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_PRICE_SETTLEMENT);
}
//+------------------------------------------------------------------+
//| The maximum allowable price value for the session                |
//+------------------------------------------------------------------+
double CSessionInfo::PriceLimitMax(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_PRICE_LIMIT_MAX);
}
//+------------------------------------------------------------------+
//| The minimum allowable price value for the session                |
//+------------------------------------------------------------------+
double CSessionInfo::PriceLimitMin(void)
{
   return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_PRICE_LIMIT_MIN);
}