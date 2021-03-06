//+------------------------------------------------------------------+
//|                                                EventListener.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class CListener : public CStrategy
  {
public:
                     CListener(void);
   virtual void      InitBuy(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//| Subscribe to changes in the depth of market of most liquid       |
//| instruments.                                                     |
//+------------------------------------------------------------------+
CListener::CListener(void)
  {
   ExpertSymbol("Si-12.15");
   ExpertMagic(123728);
   ExpertName("ListenerExpert");
   Timeframe(PERIOD_M1);
  }
//+------------------------------------------------------------------+
//| Receive event and print it to terminal.                          |
//+------------------------------------------------------------------+
void CListener::InitBuy(const MarketEvent &event)
  {
   if(event.symbol != ExpertSymbol())return;
   if(/*event.type != MARKET_EVENT_TICK &&*/ event.type != MARKET_EVENT_BAR_OPEN)return;
   printf("Event: "+EnumToString(event.type)+"; Symbol: "+event.symbol+"; Period: "+EnumToString(event.period));
   string str=TimeToString(Time[0])+" "+DoubleToString(Open[0],0);
   printf(str);
  }
//+------------------------------------------------------------------+
