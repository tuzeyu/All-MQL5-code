//+------------------------------------------------------------------+
//|                                                      Samples.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Strategy\Indicators\MovingAverage.mqh>
//+------------------------------------------------------------------+
//| An example of a classical strategy based on two Moving Averages. |
//| If the fast MA crosses the slow one from upside down             |
//| we buy, if from top bottom - we sell.                            |
//+------------------------------------------------------------------+
class CMovingAverage : public CStrategy
  {
private:
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnSymbolChanged(string new_symbol);
   virtual void      OnTimeframeChanged(ENUM_TIMEFRAMES new_tf);
   virtual string    ExpertNameFull(void);
   virtual bool      ParseXmlParams(CXmlElement *params);
public:
   CIndMovingAverage FastMA;        // Fast moving average
   CIndMovingAverage SlowMA;        // Slow moving average
                     CMovingAverage(void);
  };
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
CMovingAverage::CMovingAverage(void)
  {
  }
//+------------------------------------------------------------------+
//| React to symbol change                                           |
//+------------------------------------------------------------------+
void CMovingAverage::OnSymbolChanged(string new_symbol)
  {
   FastMA.Symbol(new_symbol);
   SlowMA.Symbol(new_symbol);
  }
//+------------------------------------------------------------------+
//| React to timeframe change                                        |
//+------------------------------------------------------------------+
void CMovingAverage::OnTimeframeChanged(ENUM_TIMEFRAMES new_tf)
  {
   FastMA.Timeframe(new_tf);
   SlowMA.Timeframe(new_tf);
  }
//+------------------------------------------------------------------+
//| The full unique name of the EA                                   |
//+------------------------------------------------------------------+
string CMovingAverage::ExpertNameFull(void)
  {
   string name=ExpertName();
   name += "[" + ExpertSymbol();
   name += "-" + StringSubstr(EnumToString(Timeframe()), 7);
   name += "-" + (string)FastMA.MaPeriod();
   name += "-" + (string)SlowMA.MaPeriod();
   name += "-" + StringSubstr(EnumToString(SlowMA.MaMethod()), 5);
   name += "]";
   return name;
  }
//+------------------------------------------------------------------+
//| We buy when the fast MA is above the slow one.                   |
//+------------------------------------------------------------------+
void CMovingAverage::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event))return;                      // Handling only the required event!
   if(positions.open_buy > 0) return;                    // If there is at least one open position, no need to buy, as we've already bought!
   if(FastMA.OutValue(1) > SlowMA.OutValue(1))           // If no open buy positions, check if the fast MA is above the slow one:          
      Trade.Buy(MM.GetLotFixed(), ExpertSymbol(), "");   // If above, buy.
  }
//+------------------------------------------------------------------+
//| Close the long position when the fast MA is below the            |
//| slow one.                                                        |
//+------------------------------------------------------------------+
void CMovingAverage::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(!IsTrackEvents(event))return;                // Handling only the required event!
   if(FastMA.OutValue(1) < SlowMA.OutValue(1))     // If the fast MA is below the slow one -   
      pos.CloseAtMarket("Exit by cross over");     // Close the position.
  }
//+------------------------------------------------------------------+
//| We buy when the fast MA is above the slow one.                   |
//+------------------------------------------------------------------+
void CMovingAverage::InitSell(const MarketEvent &event)
  {
   if(!IsTrackEvents(event))return;                // Handling only the required event!
   if(positions.open_sell > 0) return;             //  If there is at least one short position, no need to sell, as we've already sold!
   if(FastMA.OutValue(1) < SlowMA.OutValue(1))     // If no open buy positions, check if the fast MA is above the slow one:
      Trade.Sell(1.0,ExpertSymbol(),"");           // If above that , we buy.
  }
//+------------------------------------------------------------------+
//| Close the short position when the fast MA is above the           |
//| slow one.                                                        |
//+------------------------------------------------------------------+
void CMovingAverage::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(!IsTrackEvents(event))return;                // Handling only the required event!
   if(FastMA.OutValue(1) > SlowMA.OutValue(1))     // If the fast MA is above the slow one -    
      pos.CloseAtMarket("Exit by cross under");    // Close the position.
  }
//+------------------------------------------------------------------+
//| Filters incoming events. If the passed event is not              |
//| processed by the strategy, returns false; if it is processed     |
//| returns true.                                                    |
//+------------------------------------------------------------------+
bool CMovingAverage::IsTrackEvents(const MarketEvent &event)
  {
//We handle only opening of a new bar on the working symbol and timeframe
   if(event.type != MARKET_EVENT_BAR_OPEN)return false;
   if(event.period != Timeframe())return false;
   if(event.symbol != ExpertSymbol())return false;
   return true;
  }
//+------------------------------------------------------------------+
//| The strategy's specific parameters are parsed inside it in       |
//| this method overridden from CStrategy                            |
//+------------------------------------------------------------------+
bool CMovingAverage::ParseXmlParams(CXmlElement *params)
  {
   bool res=true;
   for(int i=0; i<params.GetChildCount(); i++)
     {
      CXmlElement *param=params.GetChild(i);
      string name=param.GetName();
      if(name=="FastMA")
        {
         int fastMA=(int)param.GetText();
         if(fastMA == 0)
           {
            string text="Parameter 'FastMA' must be a number";
            CMessage *msg=new CMessage(MESSAGE_WARNING,SOURCE,text);
            Log.AddMessage(msg);
            res=false;
           }
         else
            FastMA.MaPeriod(fastMA);
        }
      else if(name=="SlowMA")
        {
         int slowMA=(int)param.GetText();
         if(slowMA == 0)
           {
            string text="Parameter 'SlowMA' must be a number";
            CMessage *msg=new CMessage(MESSAGE_WARNING,SOURCE,text);
            Log.AddMessage(msg);
            res=false;
           }
         else
            SlowMA.MaPeriod(slowMA);
        }
      else if(name=="Shift")
        {
         FastMA.MaShift((int)param.GetText());
         SlowMA.MaShift((int)param.GetText());
        }
      else if(name=="Method")
        {
         string smethod=param.GetText();
         ENUM_MA_METHOD method=MODE_SMA;
         if(smethod== "MODE_SMA")
            method = MODE_SMA;
         else if(smethod=="MODE_EMA")
            method=MODE_EMA;
         else if(smethod=="MODE_SMMA")
            method=MODE_SMMA;
         else if(smethod=="MODE_LWMA")
            method=MODE_LWMA;
         else
           {
            string text="Parameter 'Method' must be type of ENUM_MA_METHOD";
            CMessage *msg=new CMessage(MESSAGE_WARNING,SOURCE,text);
            Log.AddMessage(msg);
            res=false;
           }
         FastMA.MaMethod(method);
         SlowMA.MaMethod(method);
        }
      else if(name=="AppliedPrice")
        {
         string price=param.GetText();
         ENUM_APPLIED_PRICE a_price=PRICE_CLOSE;
         if(price=="PRICE_CLOSE")
            a_price=PRICE_CLOSE;
         else if(price=="PRICE_OPEN")
            a_price=PRICE_OPEN;
         else if(price=="PRICE_HIGH")
            a_price=PRICE_HIGH;
         else if(price=="PRICE_LOW")
            a_price=PRICE_LOW;
         else if(price=="PRICE_MEDIAN")
            a_price=PRICE_MEDIAN;
         else if(price=="PRICE_TYPICAL")
            a_price=PRICE_TYPICAL;
         else if(price=="PRICE_WEIGHTED")
            a_price=PRICE_WEIGHTED;
         else
           {
            string text="Parameter 'AppliedPrice' must be type of ENUM_APPLIED_PRICE";
            CMessage *msg=new CMessage(MESSAGE_WARNING,SOURCE,text);
            Log.AddMessage(msg);
            res=false;
           }
         FastMA.AppliedPrice(a_price);
         SlowMA.AppliedPrice(a_price);
        }

     }
   return res;
  }
//+------------------------------------------------------------------+
