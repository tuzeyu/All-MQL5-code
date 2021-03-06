//+------------------------------------------------------------------+
//|                                                EventListener.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Strategy\Strategy.mqh>
#include <Strategy\SignalAdapter.mqh>

//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class CAdapterMACD : public CStrategy
{
private:
   CSignalAdapter    m_signal;
   MqlSignalParams   m_params;
public:
                     CAdapterMACD(void);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent& event, CPosition* pos);
   virtual void      SupportSell(const MarketEvent& event, CPosition* pos);
};
//+------------------------------------------------------------------+
//| Конфигурируем адапет                                             |
//+------------------------------------------------------------------+
CAdapterMACD::CAdapterMACD(void)
{
   m_params.symbol = Symbol();
   m_params.period = Period();
   m_params.every_tick = false;
   m_params.signal_type = SIGNAL_MACD;
   m_params.magic = 1234;
   m_params.point = 1.0;
   m_params.usage_pattern = 2;
   CSignalMACD* macd = m_signal.CreateSignal(m_params);
   macd.PeriodFast(15);
   macd.PeriodSlow(32);
   macd.PeriodSignal(6);
}
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
void CAdapterMACD::InitBuy(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(m_signal.LongSignal())
      Trade.Buy(1.0);
}
//+------------------------------------------------------------------+
//| Closing buy trades                                               |
//+------------------------------------------------------------------+
void CAdapterMACD::SupportBuy(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(m_signal.ShortSignal())
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
void CAdapterMACD::InitSell(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(m_signal.ShortSignal())
      Trade.Sell(1.0);
}
//+------------------------------------------------------------------+
//| Closing buy trades                                               |
//+------------------------------------------------------------------+
void CAdapterMACD::SupportSell(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   if(m_signal.LongSignal())
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
