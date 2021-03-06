//+------------------------------------------------------------------+
//|                                                      Impulse.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include "Strategy\Strategy.mqh"

input double StopPercent = 0.05;
//+------------------------------------------------------------------+
//| Moving average indicator class (obsolete)                        |
//+------------------------------------------------------------------+
class CIndMovingAverage
  {
private:
   int               m_ma_handle;         // Indicator handle
   ENUM_TIMEFRAMES   m_timeframe;         // Timeframe
   int               m_ma_period;         // Period
   int               m_ma_shift;          // Shift
   string            m_symbol;            // Symbol
   ENUM_MA_METHOD    m_ma_method;         // Moving average method
   uint              m_applied_price;     // The handle of the indicator, on which you want to calculate the Moving Average value
                                          // or one of price values of ENUM_APPLIED_PRICE
   CLog*             m_log;               // Logging
   void              Init(void);
public:
                     CIndMovingAverage(void);

/*Params*/
   void              Timeframe(ENUM_TIMEFRAMES timeframe);
   void              MaPeriod(int ma_period);
   void              MaShift(int ma_shift);
   void              MaMethod(ENUM_MA_METHOD method);
   void              AppliedPrice(int source);
   void              Symbol(string symbol);

   ENUM_TIMEFRAMES   Timeframe(void);
   int               MaPeriod(void);
   int               MaShift(void);
   ENUM_MA_METHOD    MaMethod(void);
   uint              AppliedPrice(void);
   string            Symbol(void);

/*Out values*/
   double            OutValue(int index);
  };
//+------------------------------------------------------------------+
//| Default constructor.                                        |
//+------------------------------------------------------------------+
CIndMovingAverage::CIndMovingAverage(void) : m_ma_handle(INVALID_HANDLE),
                                             m_timeframe(PERIOD_CURRENT),
                                             m_ma_period(12),
                                             m_ma_shift(0),
                                             m_ma_method(MODE_SMA),
                                             m_applied_price(PRICE_CLOSE)
  {
   m_log=CLog::GetLog();
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
CIndMovingAverage::Init(void)
  {
   if(m_ma_handle!=INVALID_HANDLE)
     {
      bool res=IndicatorRelease(m_ma_handle);
      if(!res)
        {
         string text="Realise iMA indicator failed. Error ID: "+(string)GetLastError();
         CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         m_log.AddMessage(msg);
        }
     }
   m_ma_handle=iMA(m_symbol,m_timeframe,m_ma_period,m_ma_shift,m_ma_method,m_applied_price);
   if(m_ma_handle==INVALID_HANDLE)
     {
      string params="(Period:"+(string)m_ma_period+", Shift: "+(string)m_ma_shift+
                    ", MA Method:"+EnumToString(m_ma_method)+")";
      string text="Create iMA indicator failed"+params+". Error ID: "+(string)GetLastError();
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      m_log.AddMessage(msg);
     }
  }
//+------------------------------------------------------------------+
//| Setting timeframe.                                               |
//+------------------------------------------------------------------+
void CIndMovingAverage::Timeframe(ENUM_TIMEFRAMES tf)
  {
   m_timeframe=tf;
   if(m_ma_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the current timeframe                                    |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CIndMovingAverage::Timeframe(void)
  {
   return m_timeframe;
  }
//+------------------------------------------------------------------+
//| Sets the Moving Average averaging period.                        |
//+------------------------------------------------------------------+
void CIndMovingAverage::MaPeriod(int ma_period)
  {
   m_ma_period=ma_period;
   if(m_ma_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the current averaging period of Moving Average.          |
//+------------------------------------------------------------------+
int CIndMovingAverage::MaPeriod(void)
  {
   return m_ma_period;
  }
//+------------------------------------------------------------------+
//| Sets the Moving Average type.                                    |
//+------------------------------------------------------------------+
void CIndMovingAverage::MaMethod(ENUM_MA_METHOD method)
  {
   m_ma_method=method;
   if(m_ma_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the Moving Average type.                                 |
//+------------------------------------------------------------------+
ENUM_MA_METHOD CIndMovingAverage::MaMethod(void)
  {
   return m_ma_method;
  }
//+------------------------------------------------------------------+
//| Returns the Moving Average shift.                                |
//+------------------------------------------------------------------+
int CIndMovingAverage::MaShift(void)
  {
   return m_ma_shift;
  }
//+------------------------------------------------------------------+
//| Sets the Moving Average shhift.                                  |
//+------------------------------------------------------------------+
void CIndMovingAverage::MaShift(int ma_shift)
  {
   m_ma_shift=ma_shift;
   if(m_ma_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Sets the type of the price used for MA calculation.              |
//+------------------------------------------------------------------+
void CIndMovingAverage::AppliedPrice(int price)
  {
   m_applied_price = price;
   if(m_ma_handle != INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the type of the price used for MA calculation.           |
//+------------------------------------------------------------------+
uint CIndMovingAverage::AppliedPrice(void)
  {
   return m_applied_price;
  }
//+------------------------------------------------------------------+
//| Sets the symbol to calculate the indicator for                   |
//+------------------------------------------------------------------+
void CIndMovingAverage::Symbol(string symbol)
  {
   m_symbol=symbol;
   if(m_ma_handle!=INVALID_HANDLE)
      Init();
  }
//+------------------------------------------------------------------+
//| Returns the symbol the indicator is calculated for               |
//+------------------------------------------------------------------+
string CIndMovingAverage::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Returns the value of the MA with index 'index'                   |
//+------------------------------------------------------------------+
double CIndMovingAverage::OutValue(int index)
  {
   if(m_ma_handle==INVALID_HANDLE)
      Init();
   double values[];
   if(CopyBuffer(m_ma_handle,0,index,1,values))
      return values[0];
   return EMPTY_VALUE;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Defines the actions that need to be performed with a pending     |
//| order.                                                           |
//+------------------------------------------------------------------+
enum ENUM_ORDER_TASK
{
   ORDER_TASK_DELETE,   // Delete a pending order
   ORDER_TASK_MODIFY    // Modify a pending order
};
//+------------------------------------------------------------------+
//| The CImpulse Strategy                                            |
//+------------------------------------------------------------------+
class CImpulse : public CStrategy
{
private:
   double            m_percent;        // Percent value for the level of a pending order
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnSymbolChanged(string new_symbol);
   virtual void      OnTimeframeChanged(ENUM_TIMEFRAMES new_tf);
public:
   double            GetPercent(void);
   void              SetPercent(double percent);
   CIndMovingAverage Moving;
};
//+------------------------------------------------------------------+
//| Working with the pending BuyStop orders for opening a long       |
//| position                                                         |
//+------------------------------------------------------------------+
void CImpulse::InitBuy(const MarketEvent &event)
{
   if(!IsTrackEvents(event))return;                      
   if(positions.open_buy > 0) return;                    
   int buy_stop_total = 0;
   ENUM_ORDER_TASK task;
   double target = WS.Ask() + WS.Ask()*(m_percent/100.0);
   if(target < Moving.OutValue(0))                    // The order trigger price must be above the Moving Average
      task = ORDER_TASK_DELETE;
   else
      task = ORDER_TASK_MODIFY;
   for(int i = PendingOrders.Total()-1; i >= 0; i--)
   {
      CPendingOrder* Order = PendingOrders.GetOrder(i);
      if(Order == NULL || !Order.IsMain(ExpertSymbol(), ExpertMagic()))
         continue;
      if(Order.Type() == ORDER_TYPE_BUY_STOP)
      {
         if(task == ORDER_TASK_MODIFY)
         {
            buy_stop_total++;
            Order.Modify(target);
         }
         else
            Order.Delete();
      }
   }
   if(buy_stop_total == 0 && task == ORDER_TASK_MODIFY)
      Trade.BuyStop(MM.GetLotFixed(), target, ExpertSymbol(), 0, 0, NULL);
}
//+------------------------------------------------------------------+
//| Working with the pending SellStop orders for opening a short     |
//| position                                                         |
//+------------------------------------------------------------------+
void CImpulse::InitSell(const MarketEvent &event)
{
   if(!IsTrackEvents(event))return;                      
   if(positions.open_sell > 0) return;                    
   int sell_stop_total = 0;
   ENUM_ORDER_TASK task;
   double target = WS.Bid() - WS.Bid()*(m_percent/100.0);
   if(target > Moving.OutValue(0))                    // The order trigger price must be above the Moving Average
      task = ORDER_TASK_DELETE;
   else
      task = ORDER_TASK_MODIFY;
   for(int i = PendingOrders.Total()-1; i >= 0; i--)
   {
      CPendingOrder* Order = PendingOrders.GetOrder(i);
      if(Order == NULL || !Order.IsMain(ExpertSymbol(), ExpertMagic()))
         continue;
      if(Order.Type() == ORDER_TYPE_SELL_STOP)
      {
         if(task == ORDER_TASK_MODIFY)
         {
            sell_stop_total++;
            Order.Modify(target);
         }
         else
            Order.Delete();
      }
   }
   if(sell_stop_total == 0 && task == ORDER_TASK_MODIFY)
      Trade.SellStop(MM.GetLotFixed(), target, ExpertSymbol(), 0, 0, NULL);
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
      if(target < Moving.OutValue(0))
         pos.StopLossValue(target);
      else
         pos.StopLossValue(0.0);
   }
   if(WS.Bid() < Moving.OutValue(0))
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
      if(target > Moving.OutValue(0))
         pos.StopLossValue(target);
      else
         pos.StopLossValue(0.0);
   }
   if(WS.Ask() > Moving.OutValue(0))
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Filters incoming events. If the passed event is not              |
//| processed by the strategy, returns false; if it is processed     |
//| returns true.                                                    |
//+------------------------------------------------------------------+
bool CImpulse::IsTrackEvents(const MarketEvent &event)
  {
//We handle only opening of a new bar on the working symbol and timeframe
   if(event.type != MARKET_EVENT_BAR_OPEN)return false;
   if(event.period != Timeframe())return false;
   if(event.symbol != ExpertSymbol())return false;
   return true;
  }
//+------------------------------------------------------------------+
//| React to symbol change                                           |
//+------------------------------------------------------------------+
void CImpulse::OnSymbolChanged(string new_symbol)
  {
   Moving.Symbol(new_symbol);
  }
//+------------------------------------------------------------------+
//| React to timeframe change                                        |
//+------------------------------------------------------------------+
void CImpulse::OnTimeframeChanged(ENUM_TIMEFRAMES new_tf)
  {
   Moving.Timeframe(new_tf);
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