//+------------------------------------------------------------------+
//|                                                UsingTrailing.mqh |
//|                                 Copyright 2017, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "TimeSeries.mqh"
#include "Strategy.mqh"
//+------------------------------------------------------------------+
//| Integrated to the portfolio of strategies as an expert and       |
//| records the portfolio equity                                     |
//+------------------------------------------------------------------+
class CEquityListener : public CStrategy
{
private:
   //-- Recording frequency
   CTimeSeries       m_equity_list;
   double            m_prev_equity;
public:
                     CEquityListener(void);
   virtual void      OnEvent(const MarketEvent& event);
   void              GetEquityArray(double &array[]);
};
//+------------------------------------------------------------------+
//| Setting the default frequency                                    |
//+------------------------------------------------------------------+
CEquityListener::CEquityListener(void) : m_prev_equity(EMPTY_VALUE)
{
}
//+------------------------------------------------------------------+
//| Collects the portfolio equity, monitoring all possible           |
//| events                                                           |
//+------------------------------------------------------------------+
void CEquityListener::OnEvent(const MarketEvent &event)
{
   if(!IsTrackEvents(event))
      return;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity != m_prev_equity)
   {
      m_equity_list.Add(TimeCurrent(), equity);
      m_prev_equity = equity;
   }
}
//+------------------------------------------------------------------+
//| Returns the equity as an array of type double                    |
//+------------------------------------------------------------------+
void CEquityListener::GetEquityArray(double &array[])
{
   m_equity_list.ToDoubleArray(0, array);
}