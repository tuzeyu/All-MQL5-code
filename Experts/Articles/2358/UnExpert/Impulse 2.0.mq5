//+------------------------------------------------------------------+
//|                                                  Impulse 2.0.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include "Strategy\Strategy.mqh"
#include "Strategy\Indicators.mqh"

input int PeriodMA = 12;
input double StopPercent = 0.05;

//+------------------------------------------------------------------+
//| The CImpulse Strategy                                            |
//+------------------------------------------------------------------+
class CImpulse : public CStrategy
{
private:
   double            m_percent;        // Percent value for the level of a pending order
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      SupportPendingBuy(const MarketEvent &event,CPendingOrder *order);
   virtual void      SupportPendingSell(const MarketEvent &event,CPendingOrder* order);
   virtual bool      OnInit(void);
public:
   double            GetPercent(void);
   void              SetPercent(double percent);
   CUnIndicator      UnMA;
};
//+------------------------------------------------------------------+
//| Initialize the moving average                                    |
//+------------------------------------------------------------------+
bool CImpulse::OnInit(void)
{
   UnMA.SetParameter(PeriodMA);
   UnMA.SetParameter(0);
   UnMA.SetParameter(MODE_SMA);
   UnMA.SetParameter(PRICE_CLOSE);
   m_percent = StopPercent;
   if(UnMA.Create(Symbol(), Period(), IND_MA) != INVALID_HANDLE)
      return true;
   return false;
}
//+------------------------------------------------------------------+
//| Placing pending BuyStop orders                                   |
//+------------------------------------------------------------------+
void CImpulse::InitBuy(const MarketEvent &event)
{
   if(!IsTrackEvents(event))return;                                           // Create pending only at the opening of a new bar
   if(PositionsTotal(POSITION_TYPE_BUY, ExpertSymbol(), ExpertMagic()) > 0)   // There must be no open long positions present
      return;
   if(OrdersTotal(POSITION_TYPE_BUY, ExpertSymbol(), ExpertMagic()) > 0)      // There must be no pending buy order present
      return;
   double target = WS.Ask() + WS.Ask()*(m_percent/100.0);                     // Calculate the level of the new pending order
   if(target < UnMA[0])                                                       // The order trigger price must be above the Moving Average
      return;
   Trade.BuyStop(MM.GetLotFixed(), target, ExpertSymbol(), 0, 0, NULL);       // Place the new BuyStop order
}
//+------------------------------------------------------------------+
//| Working with the pending BuyStop orders for opening a long       |
//| position                                                         |
//+------------------------------------------------------------------+
void CImpulse::SupportPendingBuy(const MarketEvent &event,CPendingOrder *order)
{
   if(!IsTrackEvents(event))return;
   double target = WS.Ask() + WS.Ask()*(m_percent/100.0);                     // Calculate the level of the new pending order
   if(UnMA[0] > target)                                                       // If the new level is lower than the current Moving Average
      order.Delete();                                                         // - delete it
   else                                                                       // Otherwise, modify it with the new price
      order.Modify(target);
}
//+------------------------------------------------------------------+
//| Working with the pending SellStop orders for opening a short     |
//| position                                                         |
//+------------------------------------------------------------------+
void CImpulse::SupportPendingSell(const MarketEvent &event,CPendingOrder* order)
{
   if(!IsTrackEvents(event))return;
   double target = WS.Ask() - WS.Ask()*(m_percent/100.0);                     // Calculate the level of the new pending order
   if(UnMA[0] < target)                                                       // If the new level is higher than the current Moving Average
      order.Delete();                                                         // - delete it
   else                                                                       // Otherwise, modify it with the new price
      order.Modify(target);
}
//+------------------------------------------------------------------+
//| Placing pending SellStop orders                                  |
//+------------------------------------------------------------------+
void CImpulse::InitSell(const MarketEvent &event)
{
   if(!IsTrackEvents(event))return;                                           // Create pending only at the opening of a new bar
   if(PositionsTotal(POSITION_TYPE_SELL, ExpertSymbol(), ExpertMagic()) > 0)  // There must be no open short positions present
      return;
   if(OrdersTotal(POSITION_TYPE_SELL, ExpertSymbol(), ExpertMagic()) > 0)     // There must be no pending sell order present
      return;
   double target = WS.Bid() - WS.Bid()*(m_percent/100.0);                     // Calculate the level of the new pending order
   if(target > UnMA[0])                                                       // The order trigger price must be below the Moving Average
      return;  
   Trade.SellStop(MM.GetLotFixed(), target, ExpertSymbol(), 0, 0, NULL);      // Place the new BuyStop order
}
//+------------------------------------------------------------------+
//| Managing a long position in accordance with the Moving Average   |
//+------------------------------------------------------------------+
void CImpulse::SupportBuy(const MarketEvent &event,CPosition *pos)
{
   int bar_open = WS.IndexByTime(pos.TimeOpen());
   if(!IsTrackEvents(event))return;
   ENUM_ACCOUNT_MARGIN_MODE mode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      double target = WS.Bid() - WS.Bid()*(m_percent/100.0);
      if(target < UnMA[0])
         pos.StopLossValue(target);
      else
         pos.StopLossValue(0.0);
   }
   if(WS.Bid() < UnMA[0])
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Managing a short position in accordance with the Moving Average  |
//+------------------------------------------------------------------+
void CImpulse::SupportSell(const MarketEvent &event,CPosition *pos)
{
   if(!IsTrackEvents(event))return;
   ENUM_ACCOUNT_MARGIN_MODE mode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      double target = WS.Ask() + WS.Ask()*(m_percent/100.0);
      if(target > UnMA[0])
         pos.StopLossValue(target);
      else
         pos.StopLossValue(0.0);
   }
   if(WS.Ask() > UnMA[0])
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Returns the percent of the breakthrough level                    |
//+------------------------------------------------------------------+  
double CImpulse::GetPercent(void)
{
   return m_percent;
}
//+------------------------------------------------------------------+
//| Sets percent of the breakthrough level                           |
//+------------------------------------------------------------------+  
void CImpulse::SetPercent(double percent)
{
   m_percent = percent;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   CImpulse* impulse = new CImpulse();
   impulse.ExpertMagic(140578);
   impulse.ExpertName("Impulse 2.0");
   impulse.Timeframe(Period());
   impulse.ExpertSymbol(Symbol());
   Manager.AddStrategy(impulse);
   Manager.SetCustomOptimizeR2Equity(CORR_SPEARMAN);
   return(INIT_SUCCEEDED);
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   Manager.OnTick();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
{
   Manager.OnChartEvent(id, lparam, dparam, sparam);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
//| Tester event                                                     |
//+------------------------------------------------------------------+
double OnTester()
{
   Manager.SetCustomOptimizeR2Balance(CORR_PEARSON);
   return Manager.OnTester();
}