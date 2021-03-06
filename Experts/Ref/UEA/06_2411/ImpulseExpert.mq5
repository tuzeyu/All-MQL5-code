//+------------------------------------------------------------------+
//|                                                ImpulseExpert.mq5 |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Strategy\Samples\ImpulseTrailingManual.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CImpulseTrailing* impulse = new CImpulseTrailing();
   impulse.ExpertMagic(1218);
   impulse.Timeframe(Period());
   impulse.ExpertSymbol(Symbol());
   impulse.ExpertName("Impulse");
   impulse.Moving.MaPeriod(28);                      
   impulse.SetPercent(StopPercent);
   //impulse.TradeState(TRADE_BUY_ONLY);
   if(!Manager.AddStrategy(impulse))
      delete impulse;
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   Manager.OnChartEvent(id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
